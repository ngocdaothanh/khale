-module(m_discussion).

-compile(export_all).

-include("sticky.hrl").

%-------------------------------------------------------------------------------

migrate() -> m_helper:create_table(discussion, record_info(fields, discussion)).

%-------------------------------------------------------------------------------

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(discussion), R#discussion.id == Id]),
    case qlc:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

count(ContentType, ContentId) ->
    {atomic, L} = mnesia:transaction(fun() ->
        Q = qlc:q([undefined || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]),
        qlc:e(Q)
    end),
    length(L).

last(ContentType, ContentId) ->
    {atomic, Discussion} = mnesia:transaction(fun() ->
        Q1 = qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]),
        Q2 = qlc:keysort(2, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Discussion2 = case qlc:next_answers(QC, 1) of
            [Discussion3] -> Discussion3;
            _          -> undefined
        end,
        qlc:delete_cursor(QC),
        Discussion2
    end),
    Discussion.

more(ContentType, ContentId, LastDiscussionId) ->
    %more(ContentType, ContentId, LastDiscussionId, ?ITEMS_PER_PAGE).
    more(ContentType, ContentId, LastDiscussionId, all_remaining).

% LastDiscussionId: last id of the last more.
more(ContentType, ContentId, LastDiscussionId, NumberOfAnswers) ->
    % OPTIMIZE: sort by updated at ~ sort by id
    {atomic, Discussions} = mnesia:transaction(fun() ->
        Q1 = case LastDiscussionId of
            undefined -> qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId]);
            _         -> qlc:q([R || R <- mnesia:table(discussion), R#discussion.content_type == ContentType, R#discussion.content_id == ContentId, R#discussion.id < LastDiscussionId])
        end,
        %Q2 = qlc:keysort(1 + 1, Q1, [{order, descending}]),
        Q2 = qlc:keysort(1 + 1, Q1, [{order, ascending}]),
        QC = qlc:cursor(Q2),
        Discussions2 = qlc:next_answers(QC, NumberOfAnswers),
        qlc:delete_cursor(QC),
        Discussions2
    end),
    Discussions.

%-------------------------------------------------------------------------------

validate(Discussion) ->
    % Make sure that ContentType and ContentId is valid
    case is_existing(Discussion#discussion.content_type, Discussion#discussion.content_id) of
        false -> {error, ?T("Invalid input")};

        true ->
            case Discussion#discussion.body of
                undefined -> {error, ?T("Discussion body must not be empty.")};

                Body ->
                    case esan:san(Body) of
                        {error, _}  -> {error, ?T("Body contains invalid HTML.")};
                        {ok, Body2} -> {ok, Discussion#discussion{body = Body2}}
                    end
            end
    end.

%% Returns {error, Error} | {atomic, Discusstion}.
create(Discussion) ->
    case validate(Discussion) of
        {error, Error} -> {error, Error};

        {ok, Discussion2} ->
            mnesia:transaction(fun() ->
                Id = m_helper:next_id(discussion),
                CreatedAt = erlang:universaltime(),
                Discussion3 = Discussion2#discussion{
                    id = Id,
                    created_at = CreatedAt, updated_at = CreatedAt
                },
                mnesia:write(Discussion3),

                Thread = #thread{
                    content_type_id = {Discussion3#discussion.content_type, Discussion3#discussion.content_id},
                    updated_at = CreatedAt
                },
                mnesia:write(Thread),

                Discussion3
            end)
    end.

delete(Id) ->
    mnesia:transaction(fun() ->
        Q = qlc:q([R || R <- mnesia:table(discussion), R#discussion.id == Id]),
        [Discussion] = qlc:e(Q),

        mnesia:delete({discussion, Id}),

        ContentType = Discussion#discussion.content_type,
        ContentId   = Discussion#discussion.content_id,
        mnesia:write(#thread{content_type_id = {ContentType, ContentId}, updated_at = erlang:universaltime()})
    end).

%-------------------------------------------------------------------------------

is_existing(Type, Id) ->
    case lists:member(Type, m_content:types()) of
        false -> false;

        true ->
            M = m_content:m_module(Type),
            case M:find(Id) of
                undefined -> false;
                _         -> true
            end
    end.
