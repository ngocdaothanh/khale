-module(h_openid).

-compile(export_all).

-include("sticky.hrl").

username(User) ->
    User#user.data.

url(User) ->
    ShortOpenId = User#user.data,
    "http://" ++ ShortOpenId.
