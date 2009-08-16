-module(b_about).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Data) ->
    Site = ale:app(site),

    % Link to users is hidden if there is no user
    UsersLink = case mnesia:table_info(user, size) of
        0 -> [];

        NumUsers ->
            {li, [], [
                {img, [{src, "/static/img/user.png"}]}, " ",
                {a, [{href, ale:path(user,  index)}], ?TF("~p users", [NumUsers])}
            ]}
    end,

    FeedLink = {li, [], [
        {img, [{src, "/static/img/feed.png"}]}, " ",
        {a, [{href, ale:path(content, feed)}], ?TF("~p contents", [mnesia:table_info(thread, size)])}
    ]},

    % Link to discussions is always displayed, so that the first one can be created
    DiscussionsLinkText = case m_discussion:count(site, undefined) of
        0              -> ?T("Discuss about this site");
        NumDiscussions -> ?TF("~p discussions about this site", [NumDiscussions])
    end,
    DiscussionsLink = {li, [], [
        {img, [{src, "/static/img/about.png"}]}, " ",
        {a, [{href, ale:path(site, about)}], DiscussionsLinkText}
    ]},

    Body = [
        Site#site.about,

        {ul, [], [
            UsersLink,
            FeedLink,
            DiscussionsLink
        ]}
    ],
    {"About", Body}.
