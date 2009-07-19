-module(p_user).

-compile(export_all).

-include("sticky.hrl").

render(User) ->
    UserModule = m_user:type_to_module(User#user.type),
    UserModule:render(User).

avatar_size() -> 50.
