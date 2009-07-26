-module(v_content_titles).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Recently Updated Titles")),

    Contents = ale:app(contents),
    h_application:more(
        Contents, undefined, undefined,
        fun(Content) ->
            HModule = h_content:h_module(Content),
            {a, [{href, HModule:show_path(Content)}], HModule:render_title(Content)}
        end,
        fun(LastContent) ->
            PrevThreadUpdatedAt1 = m_content:thread_updated_at(LastContent),
            PrevThreadUpdatedAt2 = h_content:timestamp_to_string(PrevThreadUpdatedAt1),
            ale:path(content, titles_more, [PrevThreadUpdatedAt2])
        end
    ).
