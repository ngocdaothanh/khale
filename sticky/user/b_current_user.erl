-module(b_current_user).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Profile = [
        case ale:session(user) of
            undefined -> h_user:login_links();

            User ->
                UserModule = m_user:type_to_module(User#user.type),
                p_user:render(User, [UserModule:logout_link()])
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
        {a, [{href, ale:path(content, new, [Type])}], ContentModule:name()}
    ].
