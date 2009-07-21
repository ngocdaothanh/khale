-module(v_content_titles).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Contents = ale:app(contents),

    More = case length(Contents) < ?ITEMS_PER_PAGE of
        true -> [];

        false ->
            LastContent = lists:last(Contents),
            LastContentUpdatedAt = h_content:timestamp_to_string(LastContent#content.updated_at),
            {a, [{onclick, "return more(this)"}, {href, ale:path(content, titles_more, [LastContentUpdatedAt])}], ?T("More...")}
    end,

    [
        {ul, [], [{li, [], {a, [{href, ale:path(content, show, [C#content.id])}], yaws_api:htmlize(C#content.title)}} || C <- Contents]},
        More
    ].
