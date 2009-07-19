-module(m_openid).

-compile(export_all).

-include("sticky.hrl").

%% Returns a user record.
%%
%% If the user table already has this Uid, this function returns the corresponding
%% record, otherwise it creates a new record.
login(OpenId, Email, Fullname) ->
    F = fun() ->
        Q = qlc:q([R || R <- mnesia:table(user), R#user.type == openid, R#user.indexed_data == OpenId]),
        case m_helper:do(Q) of
            [R] ->
                R2 = R#user{extra_data = {Email, Fullname}},
                mnesia:write(R2),
                R2;

            [] ->
                Id = m_helper:next_id(user),
                R = #user{id = Id, type = openid, indexed_data = OpenId, extra_data = {Email, Fullname}},
                mnesia:write(R),
                R
        end
    end,

    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.


%% Remove http(s):// and trailing slash.
%%
%% May be useful when migrating old data.
shorten(OpenId) ->
    WithoutScheme = case OpenId of
        "http://"  ++ Rest -> Rest;
        "https://" ++ Rest -> Rest;
        _                  -> OpenId
    end,
    string:strip(WithoutScheme, right, $/).
