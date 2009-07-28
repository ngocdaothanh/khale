-module(v_chat_index).

-compile(export_all).

render() ->
    {Msgs, PrevNow} = ale:app(msgs_prev_now),
    h_chat:render_msgs(Msgs, PrevNow).
