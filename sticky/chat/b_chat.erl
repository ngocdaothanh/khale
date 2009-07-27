-module(b_chat).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    {NameMsgList, PrevNow} = s_chat:msgs({0, 0, 0}),
    Body = [
        {'div', [{id, chat_output}], h_chat:render_name_msg_list(NameMsgList, PrevNow)},
        {input, [{id, chat_input}, {type, text}]}
    ],
    {?T("Chat"), Body}.
