-module(h_chat).

-compile(export_all).

render_msgs(Msgs, PrevNow) ->
    RenderedMsgs = [{li, [], ["- ", yaws_api:htmlize(Msg)]} || Msg <- Msgs],
    RenderedPrevNow     = {input, [{type, hidden}, {value, h_application:now_to_string(PrevNow)}]},
    {ul, [], RenderedMsgs ++ RenderedPrevNow}.
