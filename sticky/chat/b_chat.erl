-module(b_chat).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    {NumUsers, Msgs, Now} = s_chat:msgs(),
    NumUsers2             = NumUsers + 1,  % 1: this user
    Now2                  = h_app:now_to_string(Now),

    ale:app_add_js("chatMore('" ++ Now2 ++ "');"),
    Body = [
        {p, [], [
            ?T("Users"), ": ",
            {span, [{id, chat_users}], io_lib:format("~p", [NumUsers2])}
        ]},
        {'div', [{id, chat_output}], h_chat:render_msgs(Msgs)},
        {input, [{id, chat_input}, {type, text}, {class, textbox}]}
    ],
    {?T("Chat"), Body}.
