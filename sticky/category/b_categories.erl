-module(b_categories).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Body = ale:cache("b_categories", fun() ->
        Categories = m_category:all(),
        {ul, [],
            [{li, [], {a, [{href, ale:url_for(content, search_by_category, [C#category.unix_name])}], yaws_api:htmlize(C#category.name)}} || C <- Categories]
        }
    end, ehtml),
    {?T("Categories"), Body}.
