-module(p_content_header).

-compile(export_all).

-include("sticky.hrl").

render(Content, Linked)->
    User = m_user:find(Content#content.user_id),
    Url = io_lib:format("/show/~p", [Content#content.id]),
    [
        {h1, [], 
            case Linked of
                false -> yaws_api:htmlize(Content#content.title);

                true  -> {a, [{href, Url}], yaws_api:htmlize(Content#content.title)}
            end
        },
        p_user:render(User)
    ].
