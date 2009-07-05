-module(controller_user).

-compile(export_all).

routes() -> [
    get, "users", index,
    get, "login", login
].

index(_Arg) ->
    Users = model_user:all(),
    view_user_index:render(Users).

login(_Arg) ->
    view_user_login:render().
