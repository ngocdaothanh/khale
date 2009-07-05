-module(c_content).

-compile(export_all).

-include_lib("ale/include/ale.hrl").

routes() ->
    Routes = [
        get, "",                    previews,
        get, "cagegories/UnixName", search_by_category,
        get, "keywords/Keyword",    search_by_keyword,

        get,    "show/Id", show,
        delete, "show/Id", delete,

        get,  "new",      instructions,

        get, "edit/Id", edit,
        put, "edit/Id", update
    ],

    lists:foldl(
        fun(Type, Acc) ->
            Uri = "new/" ++ atom_to_list(Type),
            [
                get,  Uri, new,
                post, Uri, create | Acc
            ]
        end,
        Routes,
        m_content:types()
    ).

previews(_Arg) ->
    Contents = m_content:all(),
    ale:put(app, contents, Contents).

search_by_category(_Arg, UnixName) ->
    Category = m_category:find_by_unix_name(UnixName),
    [].

search_by_keyword(_Arg, Keyword) ->
    [].

%-------------------------------------------------------------------------------

show(_Arg, Id) ->
    Content = m_content:find(list_to_integer(Id)),
    ale:put(app, content, Content).

delete(_Arg, Id) ->
    "delete" ++ Id.

%-------------------------------------------------------------------------------

instructions(_Arg) ->
    ale:put(app, content_modules, m_content:modules()).

new(Arg) ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(Arg),
    ale:put(app, type, Type),
    ale:put(app, partial_new, list_to_atom("p_" ++ Type ++ "_new")).

create(Arg) ->
    % Security has been checked in routes()

    Type = type_for_new_or_create(Arg),
    ale:put(app, type, Type),
    ale:put(app, partial_new, list_to_atom("p_" ++ Type ++ "_new")),
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
