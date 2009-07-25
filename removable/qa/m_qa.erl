-module(m_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

content() -> [{public_creatable, true}].

create(UserId, CategoryIds, Question, Context) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Data = #qa{question = Question, context = Context},
    Qa = #content{
        id = Id, user_id = UserId,
        data = Data,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Qa, CategoryIds).
