-module(m_poll).

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

fake() ->
    lists:foreach(
        fun(Args) -> apply(?MODULE, create, Args) end,
        [
            [1, [1, 2], "How good is Erlang?", "Erlang is becoming warm. What do you think about it?", ["Cool", "Not cool", "Sucks"]],
            [2, [2, 3], "How good is Ruby?",   "Ruby has become hot. What do you think?", ["It's cool", "It sucks", "I will study it"]],
            [2, [1, 3], "Is Java dead?",       "Are you using Java?", ["Absolutely", "I have not used it for years, it sucks", "I have not used it for years, miss it"]]
        ]
    ).
