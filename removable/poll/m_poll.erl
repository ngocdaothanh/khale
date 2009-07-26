-module(m_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

migrate() -> m_helper:create_table(poll, record_info(fields, poll)).

content() -> [{public_creatable, true}].

create(Question, Context, Choices, UserId, Ip, CategoryIds) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Votes = lists:duplicate(length(Choices), 0),
    Poll = #poll{
        id = Id,
        question = Question, context = Context, choices = Choices, votes = Votes,
        user_id = UserId, ip = Ip,
        created_at = CreatedAt
    },
    m_content:save(Poll, CategoryIds).
