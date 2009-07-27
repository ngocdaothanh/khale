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

    % Link to discussions is always displayed, so that the first one can be created
    DiscussionsLinkText = case m_discussion:count(about, undefined) of
        0           -> ?T("Discussions about this site");
        NumDiscussions -> ?TF("~p discussions about this site", [NumDiscussions])
    end,
    DiscussionsLink = {li, [], {a, [{href, ale:path(about, about)}], DiscussionsLinkText}},

    Body = [
        About#about.short,

        {ul, [], [
            UsersLink,
            DiscussionsLink
        ]}
    ],
    {"About", Body}.
