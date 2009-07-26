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

    get, "/previews_more/:prev_thread_updated_at",         previews_more,
    get, "/cagegories/:unix_name/:prev_thread_updated_at", previews_more_by_category,

    get, "/titles_more/:prev_thread_updated_at", titles_more
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

    PrevThreadUpdatedAt = case ale:params(prev_thread_updated_at) of
        undefined -> undefined;
        YMDHMiS   -> h_content:string_to_timestamp(YMDHMiS)
    end,

    Contents = m_content:more(UnixName, PrevThreadUpdatedAt),
    ale:app(contents, Contents),
    ale:view(View).
