-module(view_user_index).

-compile(export_all).

render(Users) ->
    {ul, [],
        [{li, [], partial_user:render(U)} || U <- Users]
    }.
