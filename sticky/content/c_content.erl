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
    get, "/",                      previews,
    get, "/cagegories/:unix_name", previews_by_category,

    get, "/previews_more/:thread_updated_at",         previews_more,
    get, "/cagegories/:unix_name/:thread_updated_at", previews_more_by_category,

    get, "/titles_more/:thread_updated_at", titles_more,

    get, "/search/:keyword",       search,
    get, "/search/:keyword/:page", search
]).

-caches([
    action_without_layout, [previews]
]).

-compile(export_all).

-include("sticky.hrl").

previews()                  -> previews_or_titles(previews).
previews_by_category()      -> previews_or_titles(previews).
previews_more()             -> previews_or_titles(previews).
previews_more_by_category() -> previews_or_titles(previews).
titles_more()               -> previews_or_titles(titles).

previews_or_titles(View) ->
    UnixName = case ale:params(unix_name) of
        undefined -> undefined;
        Name -> Name
    end,

    ThreadUpdatedAt = case ale:params(thread_updated_at) of
        undefined -> undefined;
        YMDHMiS   -> h_application:string_to_timestamp(YMDHMiS)
    end,

    Contents = m_content:more(UnixName, ThreadUpdatedAt),
    ale:app(contents, Contents),
    ale:view(View).

search() ->
    Contents = case ale:params(keyword) of
        undefined -> [];

        Keyword ->
            Q1 = giza_query:new("article", Keyword),
            Q2 = giza_query:limit(Q1, ?ITEMS_PER_PAGE),
            Q3 = case ale:params(page) of
                undefined ->
                    ale:app(next_page, 2),
                    Q2;

                PageS ->
                    Page = list_to_integer(PageS),
                    ale:app(next_page, Page + 1),
                    giza_query:offset(Q2, ?ITEMS_PER_PAGE*(Page - 1))  % 20: Sphinx default
            end,
            {ok, L} = giza_request:send(Q3),
            lists:foldr(
                fun({Id, _}, Acc) ->
                    case m_article:find(Id) of
                        undefined -> Acc;
                        R         -> [R | Acc]
                    end
                end,
                [],
                L
            )
    end,
    ale:app(contents, Contents).
