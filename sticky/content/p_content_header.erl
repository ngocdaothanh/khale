-module(p_content_header).

-compile(export_all).

-include("sticky.hrl").

render(Content, Linked)->
    User = m_user:find(Content#content.user_id),
    Uri = ale:url_for(content, show, integer_to_list(Content#content.id)),
    [
        {h1, [], 
            case Linked of
                false -> yaws_api:htmlize(Content#content.title);

                true  -> {a, [{href, Uri}], yaws_api:htmlize(Content#content.title)}
            end
        },
        p_user:render(User)
    ].
