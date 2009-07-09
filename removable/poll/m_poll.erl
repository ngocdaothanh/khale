-module(m_poll).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").

name() ->
    ?T("Poll").

instruction() ->
    ?T("A poll is a question with a set of selectable responses. Select if you want to ask a short question and limit the number of responses.").

create(UserId, CategoryIds, Title, AbstractAndQuestion, Selections) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Votes = lists:duplicate(length(Selections), 0),
    Poll = #content{
        id = Id, user_id = UserId, type = poll,
        title = Title, data = {AbstractAndQuestion, Selections, Votes},
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Poll, CategoryIds).
