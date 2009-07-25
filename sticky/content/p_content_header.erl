-module(p_content_header).

-compile(export_all).

-include("sticky.hrl").

render(Content, Linked)->
    User = m_user:find(Content#content.user_id),
    Path = ale:path(content, show, [Content#content.id]),
    [
        {h1, [], 
            case Linked of
                false -> h_content:title(Content);
                true  -> {a, [{href, Path}], h_content:title(Content)}
            end
        },
        p_user:render(User)
    ].
