-module(v_comment_more).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Comments    = ale:app(comments),
    AComment    = hd(Comments),
    ContentType = AComment#comment.content_type,
    ContentId   = AComment#comment.content_id,
    h_application:more(
        Comments, comments, comment,
        fun(Comment)     -> h_comment:render_one(Comment, true) end,
        fun(LastComment) -> ale:path(comment, more, [ContentType, ContentId, LastComment#comment.id]) end
    ).
