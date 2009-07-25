-module(m_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

content() -> [{public_creatable, true}].

create(UserId, CategoryIds, Question, Context, Choices) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Votes = lists:duplicate(length(Choices), 0),
    Data = #poll{question = Question, context = Context, choices = Choices, votes = Votes},
    Poll = #content{
        id = Id, user_id = UserId,
        data = Data,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Poll, CategoryIds).
