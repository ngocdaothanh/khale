-module(b_titles).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    case ale:app(contents) of
        undefined ->
            Contents = m_content:more(undefined, undefined),
            ale:app(contents, Contents);

        _ -> ok
    end,
    Body = v_content_titles:render(),
    {?T("Recently Updated Titles"), Body}.
