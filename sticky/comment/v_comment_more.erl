-module(v_comment_more).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ContentId = ale:app(content_id),
    Comments  = ale:app(comments),
    h_application:more(
        Comments, comments, comment,
        fun(Comment) -> p_comment:render(Comment, true) end,
        fun(LastComment) ->
            ale:path(comment, more, [ContentId, LastComment#comment.id])
        end
    ).
