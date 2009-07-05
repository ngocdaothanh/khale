-module(b_current_user).

-compile(export_all).

render(_Id, _Config) ->
    % UserInfo = case wf:user() of
    %     undefined -> #link{url = "/login", text = ?T("Login")};
    %     User      -> helper_user:info(User)
    % end,
    % CreateContentLink = #link{url = "/new", text = ?T("Create new content")},
    % UsersLink = #link{url = "/users", text = ?T("User list")},
    % 
    % Body = #list{body = [
    %     #listitem{body = UserInfo},
    %     #listitem{body = UsersLink},
    %     #listitem{body = CreateContentLink}
    % ]},
    % {?T("User"), Body}.
    [].
