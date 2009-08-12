-module(m_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

migrate() -> m_helper:create_table(qa, record_info(fields, qa)).

content() -> [{public_creatable, true}].

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

create(UserId, Ip, Question, Detail, Tags) ->
    F = fun() ->
        Id = m_helper:next_id(qa),
        CreatedAt = erlang:universaltime(),
        Qa = #qa{
            id = Id,
            question = Question, detail = Detail,
            user_id = UserId, ip = Ip,
            created_at = CreatedAt, updated_at = CreatedAt
        },
        Thread = #thread{content_type_id = {qa, Id}, updated_at = CreatedAt},

        mnesia:write(Qa),
        m_tag:tag(qa, Id, Tags),
        mnesia:write(Thread),
        Qa
    end,
    mnesia:transaction(F).

update(Id, Ip, Question, Detail, Tags) ->
    F = fun() ->
        Qa = find(Id),
        UpdatedAt = erlang:universaltime(),
        Qa2 = Qa#qa{
            question = Question, detail = Detail,
            ip = Ip,
            updated_at = UpdatedAt
        },
        Thread = #thread{content_type_id = {qa, Id}, updated_at = UpdatedAt},

        mnesia:write(Qa2),
        m_tag:tag(article, Id, Tags),
        mnesia:write(Thread),
        Qa2
    end,
    mnesia:transaction(F).

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([{R#qa.id, R#qa.question, R#qa.detail} || R <- mnesia:table(qa)]),
    m_helper:do(Q).
