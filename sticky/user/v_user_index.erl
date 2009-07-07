-module(v_user_index).

-compile(export_all).

render() ->
    {ul, [],
        [{li, [], p_user:render(U)} || U <- ale:app(users)]
    }.
