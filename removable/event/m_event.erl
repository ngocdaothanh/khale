-module(m_event).

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

fake() ->
    lists:foreach(
        fun(Args) -> apply(?MODULE, create, Args) end,
        [
            [1, [1, 2], "Erlang workshop in Tokyo",  "We will organize a workshop about Erlang in Tokyo. Feel free to come.", {2009, 6, 25}],
            [1, [2, 3], "Cucumber talk in Yokohama", "I will talk about BDD and Cucumber. There are only 20 seats.", {2009, 8, 3}],
            [2, [1, 3], "Mac party in Tsukuba",      "Party to celerate new version of MacOS. Free beer.", {2009, 11, 20}]
        ]
    ).
