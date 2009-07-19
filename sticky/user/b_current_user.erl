-module(b_current_user).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    % Not easy to update profile after the user logs in/out, because fb:login-button
    % only has onlogin, no onlogout
    % http://wiki.developers.facebook.com/index.php/Detecting_Connect_Status

    Profile = [
        case ale:session(user) of
            undefined ->
                [
                    {p, [], ?T("Login with")},
                    {ul, [], [
                        {li, [], h_facebook:login_link()}
                    ]}
                ];

            User ->
                [
                    p_user:render(User), {br},
                    {a, [{href, ale:url_for(user, logout)}], ?T("Logout")}
                ]
        end
    ],

    Body = [
        Profile,

        {p, [], ?T("Create new content")},
        {ul, [], [{li, [], new_content_link(M)} || M <- m_content:modules()]}
    ],
    {?T("User"), Body}.

new_content_link(ContentModule) ->
    [$m, $_ | Type] = atom_to_list(ContentModule),
    [
        {a, [{href, ale:url_for(content, new, [Type])}], ContentModule:name()}
    ].
