-module(m_openid).

-compile(export_all).

-include("sticky.hrl").

create(Email, OpenId) ->
    Id = m_helper:next_id(user),
    ShortOpenId = to_short(OpenId),
    User = #user{id = Id, type = openid, email = Email, data = ShortOpenId},
    mnesia:transaction(fun() -> mnesia:write(User) end).

fake() ->
    lists:foreach(
        fun(Args) -> apply(?MODULE, create, Args) end,
        [
            ["ngocdaothanh@gmail.com", "ngocdaothanh.myopenid.com"],
            ["gplinh@gmail.com",       "alide.myopenid.com"]
        ]
    ).

%% http://ngocdaothanh.myopenid.com/  -> ngocdaothanh.myopenid.com
%% https://ngocdaothanh.myopenid.com/ -> ngocdaothanh.myopenid.com
%% http://ngocdaothanh.myopenid.com   -> ngocdaothanh.myopenid.com
to_short(OpenId) ->
    OpenId.
