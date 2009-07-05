-module(b_current_user).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    UserInfo = case ale:user() of
        undefined -> {a, [{href, "/login"}], ?T("Login")};
        User      -> p_user:render(User)
    end,
    CreateContentLink = {a, [{href, "/new"}], ?T("Create new content")},
    UsersLink = {a, [{href, "/users"}], ?T("User list")},

    Body = {ul, [], [
        {li, [], UserInfo},
        {li, [], UsersLink},
        {li, [], CreateContentLink}
    ]},
    {?T("User"), Body}.
