-module(v_content_show).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Content = ale:app(content),
    DetailPartial = list_to_atom(
        "p_" ++
        atom_to_list(Content#content.type) ++
        "_detail"
    ),

    [
        p_content_header:render(Content, false),
        DetailPartial:render(Content),
        p_comments:render(Content)
    ].
