-module(c_content).

-routes([
    get, "/",                    previews,
    get, "/cagegories/UnixName", search_by_category,
    get, "/keywords/Keyword",    search_by_keyword,

    get,    "/show/Id", show,
    delete, "/show/Id", delete,

    get, "/edit/Id", edit,
    put, "/edit/Id", update,

    get,  "/new",      instructions,
    get,  "/new/Type", new,
    post, "/new/Type", new
]).

-caches([
    action_without_layout, [previews, instructions]
]).

-compile(export_all).

-include("sticky.hrl").

%-------------------------------------------------------------------------------

previews() ->
    Contents = m_content:all(),
    ale:app(contents, Contents).

search_by_category(UnixName) ->
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword(Keyword) ->
    [].

%-------------------------------------------------------------------------------

show(Id) ->
    Content = m_content:find(list_to_integer(Id)),
    Module = m_content:type_to_module(Content#content.type),
    ale:app(title, Module:name()),
    ale:app(content, Content).

delete(Id) ->
    "delete" ++ Id.

%-------------------------------------------------------------------------------

instructions() ->
    ale:app(title, ?T("Create new content")),
    ale:app(content_modules, m_content:modules()).

new(Type) ->
    check_type(Type).

create(Type) ->
    check_type(Type),
    ale:put(ale, view, v_content_new).

check_type(Type) ->
    % Avoid list_to_atom hack
    case lists:member(Type, m_content:type_strings()) of
        false -> erlang:error(invalid_content_type);

        true  ->
            ale:app(type, Type),
            ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new"))
    end.

%-------------------------------------------------------------------------------

edit(Id) ->
    "edit" ++ Id.

update(Id) ->
    "update" ++ Id.
