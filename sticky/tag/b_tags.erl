-module(b_tags).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Body = ale:cache("b_tags", fun() ->
        Tags = m_tag:all(),
        {ul, [],
            [{li, [], {a, [{href, ale:path(content, tag, [T#tag.name])}], yaws_api:htmlize(T#tag.name)}} || T <- Tags]
        }
    end, ehtml),
    {?T("Tags"), Body}.
