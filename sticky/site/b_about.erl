-module(b_about).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Data) ->
    Site = ale:app(site),

    % Link to users is hidden if there is no user
    UsersLink = case mnesia:table_info(user, size) of
        0        -> [];
        NumUsers -> {li, [], {a, [{href, ale:path(user,  index)}], ?TF("~p users", [NumUsers])}}
    end,

    % Link to discussions is always displayed, so that the first one can be created
    DiscussionsLinkText = case m_discussion:count(site, undefined) of
        0              -> ?T("Discuss about this site");
        NumDiscussions -> ?TF("~p discussions about this site", [NumDiscussions])
    end,
    DiscussionsLink = {li, [], {a, [{href, ale:path(site, about)}], DiscussionsLinkText}},

    Body = [
        Site#site.about,

        {ul, [], [
            UsersLink,
            DiscussionsLink
        ]}
    ],
    {"About", Body}.
