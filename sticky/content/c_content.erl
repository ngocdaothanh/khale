-module(c_content).

-routes([
    get, "/",                      previews,
    get, "/cagegories/:unix_name", search_by_category,
    get, "/keywords/:keyword",     search_by_keyword,

    get,    "/show/:id", show,
    delete, "/show/:id", delete,

    get, "/edit/:id", edit,
    put, "/edit/:id", update,

    get,  "/new/:content_type", new,
    post, "/new/:content_type", create
]).

-caches([
    action_without_layout, [previews]
]).

-compile(export_all).

-include("sticky.hrl").

%-------------------------------------------------------------------------------

previews() ->
    Contents = m_content:more(undefined),
    ale:app(contents, Contents).

search_by_category() ->
    UnixName = ale:params(unix_name),
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword() ->
    Keyword = ale:params(keyword),
    [].

%-------------------------------------------------------------------------------

show() ->
    Id = list_to_integer(ale:params(id)),
    Content = m_content:find(Id),
    Module = m_content:type_to_module(Content#content.type),
    ale:app(title, Module:name()),
    ale:app(content, Content).

delete() ->
    Id = list_to_integer(ale:params(id)),
    "delete" ++ Id.

%-------------------------------------------------------------------------------

new() -> check_type().

create(Type) ->
    check_type(),
    Type = ale:params(content_type),
    Controller = list_to_atom("c_" ++ Type),
    Controller:create().

% Checks to avoid list_to_atom hack.
check_type() ->
    Type = ale:params(content_type),
    case lists:member(Type, m_content:type_strings()) of
        false -> erlang:error(invalid_content_type);
        true  -> ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new"))
    end.

%-------------------------------------------------------------------------------

edit() ->
    Id = list_to_integer(ale:params(id)),
    "edit" ++ Id.

update() ->
    Id = list_to_integer(ale:params(id)),
    "update" ++ Id.
