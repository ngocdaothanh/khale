-module(m_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

content() -> [{public_creatable, true}].

create(UserId, CategoryIds, Name, Invitation, Deadline) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Data = #event{name = Name, invitation = Invitation, deadline = Deadline, participants = []},
    Event = #content{
        id = Id, user_id = UserId,
        data = Data,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Event, CategoryIds).
