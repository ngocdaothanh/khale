-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Body = ale:cache("b_titles/body", fun() ->
        Contents = m_content:more(undefined, undefined),
        {ul, [], 
            [{li, [], {a, [{href, ale:path(content, show, [C#content.id])}], C#content.title}} || C <- Contents]
        }
    end, ehtml),
    {?T("Recently Updated Titles"), Body}.
