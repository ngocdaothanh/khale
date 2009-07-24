-module(h_user).

-compile(export_all).

-include("sticky.hrl").

login_links() -> login_links(undefined).

%% Bookmark: after logging in, the user should be redirected to the current
%% path of path#Bookmark.
login_links(Bookmark) ->
    Target = ale:path() ++ case Bookmark of
        undefined -> "";
        _         -> "#" ++ Bookmark
    end,
    Base64Target = base64:encode_to_string(Target),

    [
        {p, [], ?T("Login with")},
        {ul, [],
            [{li, [], M:login_link(Base64Target)} || M <- m_user:modules()]
        }
    ].
