-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Contents = m_content:more(undefined, undefined),
    Body = h_content:render_titles_with_more(Contents),
    {?T("Recent Updates"), Body}.
