-module(v_content_show).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Content = ale:app(content),
    Type = m_content:type(Content),
    DetailPartial = list_to_atom("p_" ++ atom_to_list(Type) ++ "_detail"),
    [
        p_content_header:render(Content, false),
        DetailPartial:render(Content),
        p_comments:render(Content)
    ].
