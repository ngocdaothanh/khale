-module(v_user_index).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Users")),
    {ul, [],
        [{li, [], p_user:render(U)} || U <- ale:app(users)]
    }.
