-module(m_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

migrate() -> m_helper:create_table(qa, record_info(fields, qa)).

content() -> [{public_creatable, true}].

create(Question, Detail, UserId, Ip, CategoryIds) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Qa = #qa{
        id = Id,
        question = Question, detail = Detail,
        user_id = UserId, ip = Ip,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Qa, CategoryIds).

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(qa), R#qa.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.
