-module(v_user_index).

-compile(export_all).

render() ->
    Users = ale:get(app, users),
    {ul, [],
        [{li, [], p_user:render(U)} || U <- Users]
    }.
