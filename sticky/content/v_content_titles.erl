-module(v_content_titles).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("Recently Updated Titles"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Contents = ale:app(contents),
    h_application:more(
        Contents, undefined, undefined,
        fun(Content) ->
            HModule = h_content:h_module(Content),
            {a, [{href, HModule:show_path(Content)}], HModule:render_title(Content)}
        end,
        fun(LastContent) ->
            PrevThreadUpdatedAt1 = m_content:thread_updated_at(LastContent),
            PrevThreadUpdatedAt2 = h_application:timestamp_to_string(PrevThreadUpdatedAt1),
            ale:path(content, titles_more, [PrevThreadUpdatedAt2])
        end
    ).
