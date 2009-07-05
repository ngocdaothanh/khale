-module(c_content).

-compile(export_all).

routes() -> [
    get, "",                    search,
    get, "cagegories/UnixName", search_by_category,
    get, "keywords/Keyword",    search_by_keyword,

    get, "new", new
].

search(_Arg) ->
    ContentForLayout = v_content_search:render(),
    Script = [],
    Ehtml = l_default:render(ContentForLayout, Script),
    {ehtml, Ehtml}.

search_by_category(_Arg, UnixName) ->
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword(_Arg, Keyword) ->
    [].

new() ->
    Instructions = m_content:instructions(),
    v_content_new:render(Instructions).
