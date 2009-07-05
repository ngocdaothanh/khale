-module(c_user).

-compile(export_all).

routes() -> [
    get, "users", index,
    get, "login", login
].

index(_Arg) ->
    ale:put(app, users, m_user:all()).

login(_Arg) ->
    ok.
