-module(v_content_search).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Search"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Contents = ale:app(contents),
    h_application:more(
        Contents, undefined,
        fun(Content) ->
            {li, [], {a, [{href, h_content:show_path(Content)}], h_content:render_title(Content)}}
        end,
        fun(_LastContent) ->
            ale:path(content, search, [ale:params(keyword), ale:app(next_page)])
        end
    ).
