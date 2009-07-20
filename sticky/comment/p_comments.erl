-module(p_comments).

-compile(export_all).

-include("sticky.hrl").

%% Render all comments for a content.
render(Content) ->
    Comments = m_comment:all(Content#content.id),
    [
        {h2, [], ?T("Comments")},
        {ul, [{class, comments}], cycle(Comments)}
    ].

cycle(Comments) ->
    {_, Ret} = lists:foldl(
        fun
            (C, {"odd", Acc}) ->
                {"even", [Acc, {li, [{class, "comment odd"}],  p_comment:render(C, true)}]};

            (C, {"even", Acc}) ->
                {"odd",  [Acc, {li, [{class, "comment even"}], p_comment:render(C, true)}]}
        end,
        {"odd", []},
        Comments
    ),
    Ret.
