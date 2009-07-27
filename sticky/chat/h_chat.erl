-module(h_chat).

-compile(export_all).

render_name_msg_list(NameMsgList, PrevNow) ->
    RenderedNameMsgList = [{li, [], [{em, [], yaws_api:htmlize(Name)}, ": ", yaws_api:htmlize(Msg)]} || {Name, Msg} <- NameMsgList],
    RenderedPrevNow     = {input, [{type, hidden}, {value, h_application:now_to_string(PrevNow)}]},
    {ul, [], RenderedNameMsgList ++ RenderedPrevNow}.
