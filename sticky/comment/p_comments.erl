-module(p_comments).

-compile(export_all).

-include("sticky.hrl").

%% Render all comments for a content.
render(Comments) ->
    [
        {h2, [], ?T("Comments")},
        "TODO"
    ].
