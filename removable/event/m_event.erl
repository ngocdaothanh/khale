-module(m_event).

-compile(export_all).

-include("sticky.hrl").
-include("event.hrl").

migrate() -> m_helper:create_table(event, record_info(fields, event)).

content() -> [{public_creatable, true}].

create(Name, Invitation, Deadline, UserId, Ip, Tags) ->
    Id = m_helper:next_id(event),
    CreatedAt = erlang:universaltime(),
    Event = #event{
        id = Id,
        name = Name, invitation = Invitation, deadline = Deadline, participants = [],
        user_id = UserId, ip = Ip, created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Event, Tags).

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#event.id, R#event.name, R#event.invitation} ||
        R <- mnesia:table(event)
    ]),
    m_helper:do(Q).
