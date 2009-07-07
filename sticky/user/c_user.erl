-module(c_user).

-compile(export_all).

-include_lib("ale/include/ale.hrl").

routes() -> [
    get, "/users", index,
    get, "/login", login
].

index(_Arg) ->
    ale:app(title, ?T("User list")),
    ale:app(users, m_user:all()).

login(_Arg) ->
    ale:app(title, ?T("Login")).
