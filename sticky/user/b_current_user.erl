-module(b_current_user).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
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
                    h_facebook:logout_link()
                ]
        end
    ],
    Content = [
        {p, [], ?T("Create new content")},
        {ul, [], [{li, [], new_content_link(M)} || M <- m_content:modules()]}
    ],

    Body = [Profile, Content],
    {?T("User"), Body}.

new_content_link(ContentModule) ->
    [$m, $_ | Type] = atom_to_list(ContentModule),
    [
        {a, [{href, ale:url_for(content, new, [Type])}], ContentModule:name()}
    ].
