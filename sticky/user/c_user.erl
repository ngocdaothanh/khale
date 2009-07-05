-module(c_user).

-compile(export_all).

routes() -> [
    get, "users", index,
    get, "login", login
].

index(_Arg) ->
    Users = m_user:all(),
    v_user_index:render(Users).

login(_Arg) ->
    v_user_login:render().
