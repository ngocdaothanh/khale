-module(b_categories).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Categories = m_category:all(),
    Body = {ul, [],
        [{li, [], {a, [{href, ["/cagegories/", C#category.unix_name]}], C#category.name}} || C <- Categories]
    },
    {?T("Categories"), Body}.
