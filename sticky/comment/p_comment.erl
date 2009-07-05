-module(p_comment).

-compile(export_all).

-include("sticky.hrl").

render(Comment, Editable) ->
    User = user:find(Comment#comment.user_id),
    [
        p_user:render(User),
        Comment#comment.body
    ].
