-module(m_facebook).

-compile(export_all).

-include("sticky.hrl").

%% Returns a user record.
%%
%% If the user table already has this Uid, this function returns the corresponding
%% record, otherwise it creates a new record.
login(Uid) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(user), R#user.type == facebook, R#user.indexed_data == Uid]),
        case m_helper:do(Q) of
            [R] -> R;

            [] ->
                Id = m_helper:next_id(user),
                R = #user{id = Id, type = facebook, indexed_data = Uid},
                mnesia:write(R),
                R
        end
    end,

    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.
