-module(h_chat).

-compile(export_all).

render_msgs(Msgs) ->
    RenderedMsgs = [{li, [], yaws_api:htmlize(Msg)} || Msg <- Msgs],
    {ul, [], RenderedMsgs}.
