-module(c_user).

-routes([
    get, "/users",               index,
    get, "/users_more/:last_id", more,
    get, "/logout",              logout,
    get, "/users/:id",           show
]).

-compile(export_all).

-include_lib("sticky.hrl").

index() -> ale:app(users, m_user:more(undefined)).

more() ->
    LastId = list_to_integer(ale:params(last_id)),
    ale:app(users, m_user:more(LastId)),
    ale:view(index).

logout() ->
    ale:view(undefined),
    ale:clear_session(),

    ale:flash(?T("You have successfully logged out.")),
    ale:yaws(redirect_local, "/").

%% Called by login modules.
login(User) ->
    ale:session(user, User),
    ale:flash(?T("You have successfully logged in.")),
    ale:yaws(redirect_local, "/"),
    ale:view(undefined).

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(user, m_user:find(Id)).
