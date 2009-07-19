-module(m_openid).

-compile(export_all).

-include("sticky.hrl").

%% Returns a user record.
%%
%% If the user table already has this Uid, this function returns the corresponding
%% record, otherwise it creates a new record.
login(OpenId) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(user), R#user.type == openid, R#user.data == OpenId]),
        case m_helper:do(Q) of
            [R] -> R;

            [] ->
                Id = m_helper:next_id(user),
                R = #user{id = Id, type = openid, data = OpenId},
                mnesia:write(R),
                R
        end
    end,

    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.
