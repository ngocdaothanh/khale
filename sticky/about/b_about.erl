-module(b_about).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Data) ->
    About = m_about:find(undefined),

    % Link to users is hidden if there is no user
    UsersLink = case mnesia:table_info(user, size) of
        0        -> [];
        NumUsers -> {li, [], {a, [{href, ale:path(user,  index)}], ?TF("~p users", [NumUsers])}}
    end,

    % Link to comments is always displayed, so that the first one can be created
    CommentsLinkText = case mnesia:table_info(comment, size) of
        0           -> ?T("Comments about this site");
        NumComments -> ?TF("~p comments about this site", [NumComments])
    end,
    CommentsLink = {li, [], {a, [{href, ale:path(about, about)}], CommentsLinkText}},

    Body = [
        About#about.short,

        {ul, [], [
            UsersLink,
            CommentsLink
        ]}
    ],
    {"About", Body}.
