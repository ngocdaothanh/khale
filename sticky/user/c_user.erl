-module(c_user).

-routes([
    get, "/users",  index,
    get, "/logout", logout
]).

-compile(export_all).

-include_lib("sticky.hrl").

index() ->
    ale:app(title, ?T("User list")),
    ale:app(users, m_user:all()).

logout() ->
    ale:view(undefined),
    ale:clear_session(),
    ale:yaws(redirect_local, "/").
