%%% xxx_content_xxx are modules that just aggregate contents of all types to
%%% display them as a list reverse sorted by updated_at property of the threads
%%% that contains the contents.
%%%
%%% View-related modules provide useful things that specific content modules
%%% can use to build their user interfaces.
%%%
%%% Features:
%%% * Pagination
%%% * ATOM
%%% * Search
-module(c_content).

-routes([
    get, "/",                                      previews,  % site's index
    get, "/tags/:tag_name",                        tag,       % different name to differentiate with "/titles/:thread_updated_at"

    % More
    get, "/previews/:thread_updated_at",           previews,
    get, "/previews/:tag_name/:thread_updated_at", previews,

    % More, thread_updated_at is always included because of b_titles
    get, "/titles/:thread_updated_at",           titles,
    get, "/titles/:tag_name/:thread_updated_at", titles,

    get, "/search/:keyword",       search,

    % More
    get, "/search/:keyword/:page", search,

    get, "/feed.atom", feed
]).

-caches([
    action_without_layout, [previews]
]).

-compile(export_all).

-include("sticky.hrl").

%-------------------------------------------------------------------------------

tag()      -> titles().
previews() -> previews_or_titles(previews).
titles()   -> previews_or_titles(titles).

previews_or_titles(View) ->
    TagName = ale:params(tag_name),
    ThreadUpdatedAt = case ale:params(thread_updated_at) of
        undefined -> undefined;
        YMDHMiS   -> h_app:string_to_timestamp(YMDHMiS)
    end,

    Contents = m_content:more(TagName, ThreadUpdatedAt),
    ale:app(contents, Contents),
    ale:view(View).

search() ->
    Contents = case ale:params(keyword) of
        undefined -> [];

        Keyword ->
            Q1 = giza_query:new("content", Keyword),
            Q2 = giza_query:limit(Q1, ?ITEMS_PER_PAGE),
            Q3 = case ale:params(page) of
                undefined ->
                    ale:app(next_page, 2),
                    Q2;

                PageS ->
                    Page = list_to_integer(PageS),
                    ale:app(next_page, Page + 1),
                    giza_query:offset(Q2, ?ITEMS_PER_PAGE*(Page - 1))
            end,
            {ok, L} = giza_request:send(Q3),
            lists:foldr(
                fun({SegmentedId, _}, Acc) ->
                    case m_content:sphinx_find(SegmentedId) of
                        undefined -> Acc;
                        R         -> [R | Acc]
                    end
                end,
                [],
                L
            )
    end,
    ale:app(contents, Contents).

%-------------------------------------------------------------------------------

feed() ->
    ale:view(undefined),
    Xml = feed_xml(),
    ale:yaws(content, "application/atom+xml", Xml).

%% See http://www.atomenabled.org/developers/syndication/
feed_xml() ->
    Site = ale:app(site),
    Head = [
        {id, [Site#site.name]},
        {title, [Site#site.name]},
        {subtitle, [Site#site.subtitle]}
    ],
    Entries = lists:map(
        fun(Content) ->
            {entry, [], [
                {id, [h_content:show_path(Content)]},
                {title, [h_content:render_title(Content)]},
                {link, [h_content:show_path(Content)]},
                {updated, [rfc3339(m_content:thread_updated_at(Content))]},
                {content, [{type, html}], [yaws_api:ehtml_expand(h_content:render_preview_without_title(Content))]}
            ]}
        end,
        m_content:more(undefined, undefined)
    ),
    Feed = #xmlElement{name = 'feed', attributes = [{xmlns, "http://www.w3.org/2005/Atom"}], content = Head ++ Entries},
    xmerl:export_simple([Feed], xmerl_xml).

rfc3339({{Y, M, D}, {H, Mi, S}}) ->
    io_lib:format("~p-~p-~pT~p:~p:~pZ", [Y, M, D, H, Mi, S]).
