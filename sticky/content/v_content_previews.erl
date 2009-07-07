-module(v_content_previews).

-compile(export_all).

-include("sticky.hrl").

render() ->
    {ul, [{class, previews}], [{li, [{class, preview}], render_one(C)} || C <- ale:app(contents)]}.

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
