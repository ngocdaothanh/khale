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
            [
                get,  Uri, new,
                post, Uri, create | Acc
            ]
        end,
        Routes,
        m_content:types()
    ).

cached_actions_without_layout() -> [previews, instructions].

%-------------------------------------------------------------------------------

previews(_Arg) ->
    Contents = m_content:all(),
    ale:app(contents, Contents).

search_by_category(_Arg, UnixName) ->
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword(_Arg, Keyword) ->
    [].

%-------------------------------------------------------------------------------

show(_Arg, Id) ->
    Content = m_content:find(list_to_integer(Id)),
    Module = m_content:type_to_module(Content#content.type),
    ale:app(title, Module:name()),
    ale:app(content, Content).

delete(_Arg, Id) ->
    "delete" ++ Id.

%-------------------------------------------------------------------------------

instructions(_Arg) ->
    ale:app(title, ?T("Create new content")),
    ale:app(content_modules, m_content:modules()).

new(Arg) ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(Arg),
    ale:app(type, Type),
    ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new")).

create(Arg) ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(Arg),
    ale:app(type, Type),
    ale:app(partial_new, list_to_atom("p_" ++ Type ++ "_new")),
    ale:put(ale, view, v_content_new).

type_for_new_or_create(Arg) ->
    Uri = Arg#arg.appmoddata,
    "new/" ++ Type = Uri,
    Type.

%-------------------------------------------------------------------------------

edit(_Arg, Id) ->
    "edit" ++ Id.

update(_Arg, Id) ->
    "update" ++ Id.
