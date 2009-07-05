-module(v_content_new).

-compile(export_all).

-include_lib("sticky.hrl").

render(Instructions) ->
    [
        {p, [], ?T("Which type of content do you want to create?")},
        {ul, [],
            [{li, [], I} || I <- Instructions]
        },
        {p, [], ?T("To avoid duplicate contents, before creating please search to check if similar thing has already existed.")}
    ].
