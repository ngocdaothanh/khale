-module(c_content).

-compile(export_all).

-include("sticky.hrl").

routes() ->
    Routes = [
        get, "/",                    previews,
        get, "/cagegories/UnixName", search_by_category,
        get, "/keywords/Keyword",    search_by_keyword,

        get,    "/show/Id", show,
        delete, "/show/Id", delete,

        get, "/edit/Id", edit,
        put, "/edit/Id", update,

        get, "/new", instructions
    ],

    lists:foldl(
        fun(Type, Acc) ->
            Uri = "/new/" ++ atom_to_list(Type),
            % The order of Routes may be important
            Acc ++ [
                get,  Uri, new,
                post, Uri, create
            ]
        end,
        Routes,
        m_content:types()
    ).

cached_actions_without_layout() -> [previews, instructions].

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

new() ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(),
    ale:app(type, Type),
    ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new")).

create() ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(),
    ale:app(type, Type),
    ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new")),
    ale:put(ale, view, v_content_new).

type_for_new_or_create() ->
    Arg = ale:arg(),
    Uri = Arg#arg.server_path,
    "/new/" ++ Type = Uri,
    Type.

%-------------------------------------------------------------------------------

edit(Id) ->
    "edit" ++ Id.

update(Id) ->
    "update" ++ Id.
