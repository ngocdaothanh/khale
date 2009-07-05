-module(block_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Contents = model_content:all(),
    Body = {ul, [], 
        [{li, [], {a, [{href, "/contents/" ++ integer_to_list(C#content.id)}], C#content.title}} || C <- Contents]
    },
    {?T("Recent titles"), Body}.
