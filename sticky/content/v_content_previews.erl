-module(v_content_previews).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Contents = ale:app(contents),
    NumContents = length(Contents),
    More = case NumContents < ?ITEMS_PER_PAGE of
        true -> [];

        false ->
            LastContent = lists:last(Contents),
            LastContentUpdatedAt = h_content:timestamp_to_string(LastContent#content.updated_at),
            {a, [{id, previews_more}, {href, ale:path(previews_more, [LastContentUpdatedAt])}], ?T("More...")}
    end,

    [
        {ul, [{class, previews}], [{li, [{class, preview}], render_one(C)} || C <- Contents]},
        More
    ].

render_one(Content) ->
    LastComment = m_comment:last(Content#content.id),
    PreviewPartial = list_to_atom(
        "p_" ++
        atom_to_list(Content#content.type) ++
        "_preview"
    ),
    [
        p_content_header:render(Content, true),
        PreviewPartial:render(Content),
        case LastComment of
            undefined -> "";
            _         -> p_comment:render(LastComment, false)
        end
    ].
