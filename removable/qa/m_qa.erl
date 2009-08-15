-module(m_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

migrate() -> m_helper:create_table(qa, record_info(fields, qa)).

content() -> [{public_creatable, true}].

%-------------------------------------------------------------------------------

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(qa), R#qa.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

find_and_inc_views(Id) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(qa), R#qa.id == Id]),
        case qlc:e(Q) of
            [Qa] ->
                Views = Qa#qa.views,
                Qa2 = Qa#qa{views = Views + 1},
                mnesia:write(Qa2),
                Qa2;

            _ -> undefined
        end
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

%-------------------------------------------------------------------------------

validate(Qa) ->
    Q1 = Qa#qa.question,
    D1 = Qa#qa.detail,
    case (Q1 == undefined) orelse (D1 == undefined) of
        true -> {error, ?T("Q/A question and detail must not be empty.")};

        false ->
            case esan:san(string:strip(D1)) of
                {error, _} -> {error, ?T("Detail contains invalid HTML.")};

                {ok, D2} ->
                    Q2 = string:strip(Q1),
                    case (Q2 == "") orelse (D2 == "") of
                        true  -> {error, ?T("Q/A question and detail must not be empty.")};
                        false -> {ok, Qa#qa{question = Q2, detail = D2}}
                    end
            end
    end.

create(Qa, TagNames) ->
    case validate(Qa) of
        {error, Error} -> {error, Error};

        {ok, Qa2} ->
            F = fun() ->
                Id = m_helper:next_id(qa),
                CreatedAt = erlang:universaltime(),
                Qa3 = Qa2#qa{
                    id = Id,
                    created_at = CreatedAt, updated_at = CreatedAt
                },
                mnesia:write(Qa3),

                m_tag:tag(qa, Id, TagNames),
                Thread = #thread{content_type_id = {qa, Id}, updated_at = CreatedAt},
                mnesia:write(Thread),

                Qa3
            end,
            mnesia:transaction(F)
    end.

update(Qa, Tags) ->
    case validate(Qa) of
        {error, Error} -> {error, Error};

        {ok, Qa2} ->
            F = fun() ->
                UpdatedAt = erlang:universaltime(),
                Qa3 = Qa2#qa{updated_at = UpdatedAt},
                mnesia:write(Qa3),

                Id = Qa3#qa.id,
                m_tag:tag(article, Id, Tags),
                Thread = #thread{content_type_id = {qa, Id}, updated_at = UpdatedAt},
                mnesia:write(Thread),

                Qa3
            end,
            mnesia:transaction(F)
    end.

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([{R#qa.id, R#qa.question, R#qa.detail} || R <- mnesia:table(qa)]),
    m_helper:do(Q).
