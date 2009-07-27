-module(v_chat_index).

-compile(export_all).

render() ->
    {NameMsgList, PrevNow} = ale:app(name_msg_list_and_prev_now),
    h_chat:render_name_msg_list(NameMsgList, PrevNow).
