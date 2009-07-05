-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Contents = m_content:all(),
    Body = {ul, [], 
        [{li, [], {a, [{href, "/show/" ++ integer_to_list(C#content.id)}], C#content.title}} || C <- Contents]
    },
    {?T("Recent titles"), Body}.
