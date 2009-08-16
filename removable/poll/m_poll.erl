%% Voters are identified by user ID so that a user can only vote once. For
%% anonymous user, IP is used instead of user ID.
-module(m_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

%-------------------------------------------------------------------------------

migrate() -> m_helper:create_table(poll, record_info(fields, poll)).

content() -> [{public_creatable, true}].

%-------------------------------------------------------------------------------

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(poll), R#poll.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

%-------------------------------------------------------------------------------

validate(Poll) ->
    Q1 = Poll#poll.question,
    C1 = Poll#poll.choices,
    case (Q1 == undefined) orelse (C1 == undefined) of
        true -> {error, ?T("Poll question and choices must not be empty.")};

        false ->
            % Make sure C1 is list of at least 2 strings
            case (length(C1) > 1) andalso (is_list(hd(C1))) of
                false -> {error, ?T("There should be at least 2 choices.")};

                true ->
                    % Strip choices and remove empty ones
                    C2 = lists:foldr(
                        fun(Choice, Acc) ->
                            case string:strip(Choice) of
                                ""      -> Acc;
                                Choice2 -> [Choice2 | Acc]
                            end
                        end,
                        [],
                        C1
                    ),
                    case length(C2) < 2 of
                        true  -> {error, ?T("There should be at least 2 choices.")};

                        false ->
                            Q2 = string:strip(Q1),
                            {ok, Poll#poll{question = Q2, choices = C2}}
                    end
            end
    end.

create(Poll, TagNames) ->
    case validate(Poll) of
        {error, Error} -> {error, Error};

        {ok, Poll2} ->
            F = fun() ->
                Id = m_helper:next_id(poll),
                CreatedAt = erlang:universaltime(),
                Votes  = lists:duplicate(length(Poll2#poll.choices), 0),
                Voters = [],
                Poll3 = Poll2#poll{
                    id = Id,
                    created_at = CreatedAt,
                    votes = Votes, voters = Voters
                },
                Thread = #thread{content_type_id = {poll, Id}, updated_at = CreatedAt},

                mnesia:write(Poll3),
                m_tag:tag(poll, Id, TagNames),
                mnesia:write(Thread),
                Poll3
            end,
            mnesia:transaction(F)
    end.

vote(Id, UserId, Choice) ->
    Poll = find(Id),
    F = fun() ->  % Both check and write must be run in a transaction
        case votable(Poll, UserId) of
            false -> ok;  % voted

            true ->
                case (Choice > 0) andalso (Choice =< length(Poll#poll.choices)) of
                    false -> ok;  % Invalid choice

                    true ->
                        Votes  = Poll#poll.votes,
                        Length = length(Votes),

                        Left  = case Choice > 1 of
                            true  -> lists:sublist(Votes, 1, Choice - 1);
                            false -> []
                        end,
                        Right = case Choice < Length of
                            true  -> lists:sublist(Votes, Choice + 1, Length - Choice);
                            false -> []
                        end,
                        Votes2 = Left ++ [lists:nth(Choice, Votes) + 1] ++ Right,

                        Voters  = Poll#poll.voters,
                        Voters2 = [UserId | Voters],

                        Poll2 = Poll#poll{votes = Votes2, voters = Voters2},
                        mnesia:write(Poll2)
                end
        end
    end,
    mnesia:transaction(F).

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#poll.id, R#poll.question} ||
        R <- mnesia:table(poll)
    ]),
    m_helper:do(Q).

votable(Poll, UserId) ->
    case Poll#poll.deadline_on of
        undefined -> not lists:member(UserId, Poll#poll.voters);

        D ->
            {Date, _Time} = erlang:universaltime(),
            (not lists:member(UserId, Poll#poll.voters)) andalso (Date =< D)
    end.
