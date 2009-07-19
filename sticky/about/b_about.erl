-module(b_about).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Data) ->
    About = m_about:find(),

    CommentsLinkText = case mnesia:table_info(comment, size) of
        0 -> ?T("Comments");
        NumComments -> ?TF("~p comments", [NumComments])
    end,

    UsersLinkText = case mnesia:table_info(user, size) of
        0 -> ?T("Users");
        NumUsers -> ?TF("~p users", [NumUsers])
    end,

    Body = [
        About#about.short,

        {ul, [], [
            {li, [], {a, [{href, ale:url_for(user,  index)}], UsersLinkText}},
            {li, [], {a, [{href, ale:url_for(about, about)}], CommentsLinkText}}
        ]}
    ],
    {"About", Body}.
