-module(m_event).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").

name() ->
    ?T("Event").

instruction() ->
    ?T("Select if you want to invite people to participate in an event such as a party, AND you want to create a list of participants so that you know the exact number.").

create(UserId, CategoryIds, Title, Invitation, DeadLine) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Participants = [],
    Event = #content{
        id = Id, user_id = UserId, type = event,
        title = Title, data = {Invitation, DeadLine, Participants},
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Event, CategoryIds).
