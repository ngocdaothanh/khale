-module(v_content_titles).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Recently Updated Titles"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Contents = ale:app(contents),
    h_content:render_titles_with_more(Contents).
