-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Body = ale:c("b_titles/body", fun() ->
        Contents = m_content:all(),
        {ul, [], 
            [{li, [], {a, [{href, ale:url_for(content, show, integer_to_list(C#content.id))}], C#content.title}} || C <- Contents]
        }
    end, ehtml),
    {?T("Recently Updated Titles"), Body}.
