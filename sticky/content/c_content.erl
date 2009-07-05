-module(c_content).

-compile(export_all).

routes() -> [
    get, "",                    previews,
    get, "cagegories/UnixName", search_by_category,
    get, "keywords/Keyword",    search_by_keyword,

    get,    "show/Id", show,
    delete, "show/Id", delete,

    get,  "new",      instructions,
    get,  "new/Type", new,
    post, "new/Type", create,

    get, "edit/Id", edit,
    put, "edit/Id", update
].

previews(_Arg) ->
    ale:put(ale, layout, default_v_layout),
    Contents = m_content:all(),
    ale:put(app, contents, Contents).

search_by_category(_Arg, UnixName) ->
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword(_Arg, Keyword) ->
    [].

%-------------------------------------------------------------------------------

show(_Arg, Id) ->
    ale:put(ale, layout, default_v_layout),
    Content = m_content:find(list_to_integer(Id)),
    ale:put(app, content, Content).

delete(_Arg, Id) ->
    "delete" ++ Id.

%-------------------------------------------------------------------------------

instructions() ->
    Instructions = m_content:instructions(),
    v_content_new:render(Instructions).

new(_Arg, Type) ->
    "new".

create(_Arg) ->
    "create".

%-------------------------------------------------------------------------------

edit(_Arg, Id) ->
    "edit" ++ Id.

update(_Arg, Id) ->
    "update" ++ Id.
