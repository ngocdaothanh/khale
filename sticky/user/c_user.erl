-module(c_user).

-routes([
    get, "/users", index,
    get, "/login", login
]).

-compile(export_all).

-include_lib("ale/include/ale.hrl").

index() ->
    ale:app(title, ?T("User list")),
    ale:app(users, m_user:all()).

login() ->
    ale:app(title, ?T("Login")).
