%%% There's not much need to search by content type.

-module(c_content).

-routes([
    get, "/",                      previews,
    get, "/cagegories/:unix_name", previews_by_category,

    get, "/previews_more/:last_content_updated_at",         previews_more,
    get, "/cagegories/:unix_name/:last_content_updated_at", previews_more_by_category,

    get, "/titles_more/:last_content_updated_at", titles_more,

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

previews()                  -> previews_or_titles(previews).
previews_by_category()      -> previews_or_titles(previews).
previews_more()             -> previews_or_titles(previews).
previews_more_by_category() -> previews_or_titles(previews).
titles_more()               -> previews_or_titles(titles).

previews_or_titles(View) ->
    UnixName = case ale:params(unix_name) of
        undefined -> undefined;
        Name -> Name
    end,

    LastContentUpdatedAt = case ale:params(last_content_updated_at) of
        undefined -> undefined;
        YMDHMiS   -> h_content:string_to_timestamp(YMDHMiS)
    end,

    Contents = m_content:more(UnixName, LastContentUpdatedAt),
    ale:app(contents, Contents),
    ale:view(View).

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
