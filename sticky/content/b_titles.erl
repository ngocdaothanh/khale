-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    TagName = ale:params(tag_name),
    Contents = m_content:more(TagName, undefined),
    Body = h_content:render_titles_with_more(Contents),
    {?T("Recently Updated Titles"), Body}.
