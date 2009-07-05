-module(v_user_index).

-compile(export_all).

render(Users) ->
    {ul, [],
        [{li, [], p_user:render(U)} || U <- Users]
    }.
