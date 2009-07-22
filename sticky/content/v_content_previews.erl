-module(v_content_previews).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Contents = ale:app(contents),
    h_application:more(
        Contents, previews, preview,
        fun render_content_preview/1,
        fun(LastContent) ->
            LastContentUpdatedAt = h_content:timestamp_to_string(LastContent#content.updated_at),
            ale:path(previews_more, [LastContentUpdatedAt])
        end
    ).

render_content_preview(Content) ->
    PreviewPartial = list_to_atom(
        "p_" ++
        atom_to_list(Content#content.type) ++
        "_preview"
    ),

    [
        p_content_header:render(Content, true),
        PreviewPartial:render(Content),
        case m_comment:last(Content#content.id) of
            undefined   -> "";
            LastComment -> {ul, [{class, comments}], {li, [{class, "comment odd"}], p_comment:render(LastComment, false)}}
        end
    ].
