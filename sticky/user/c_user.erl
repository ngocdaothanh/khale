-module(c_user).

-routes([
    get, "/users",                    index,
    get, "/users_more/:last_user_id", index,
    get, "/logout",                   logout,
    get, "/users/:id",                show
]).

-compile(export_all).

-include_lib("sticky.hrl").

index() ->
    case ale:params(last_user_id) of
        undefined   -> ale:app(users, m_user:more(undefined));
        LastUserIdS -> ale:app(users, m_user:more(list_to_integer(LastUserIdS)))
    end.

logout() ->
    ale:view(undefined),
    ale:clear_session(),

    ale:flash(?T("You have successfully logged out.")),
    ale:yaws(redirect_local, "/").

%% Called by login modules.
login(User) ->
    ale:session(user, User),
    ale:flash(?T("You have successfully logged in.")),

    Target = base64:decode_to_string(ale:session(base64_target)),
    ale:yaws(redirect_local, Target),
    ale:session(base64_target, undefined),  % OPTIMIZE: delete unused session variable
    ale:view(undefined).

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(user, m_user:find(Id)).
