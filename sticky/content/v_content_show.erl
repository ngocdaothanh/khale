-module(v_content_show).

-compile(export_all).

render() ->
    Content = ale:get(app, content),
    [
        p_content_header:render(Content, false)
    ].
