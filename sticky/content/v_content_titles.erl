-module(v_content_titles).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Recently Updated Titles")),

    Contents = ale:app(contents),
    h_application:more(
        Contents, undefined, undefined,
        fun(Content) ->
            {a, [{href, ale:path(content, show, [Content#content.id])}], yaws_api:htmlize(Content#content.title)}
        end,
        fun(LastContent) ->
            LastContentUpdatedAt = h_content:timestamp_to_string(LastContent#content.updated_at),
            ale:path(content, titles_more, [LastContentUpdatedAt])
        end
    ).
