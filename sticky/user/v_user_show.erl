-module(v_user_show).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("User")),

    User = ale:app(user),
    Contents = m_user:contents(User),
    [
        p_user:render(User),
        {ul, [],
            lists:map(
                fun(Content) ->
                    HModule = h_content:h_module(Content),
                    {li, [], {a, [{href, "ale:path(content, show, [Content#content.id])"}], HModule:title(Content)}}
                end,
                Contents
            )
        }
    ].
