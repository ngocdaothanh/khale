-module(c_comment).

-routes([
    get,  "/comments/:content_id/:last_comment_id", more,
    post, "/comments/:content_id", create
]).

-compile(export_all).

more() ->
    ContentId     = list_to_integer(ale:params(content_id)),
    LastCommentId = list_to_integer(ale:params(last_comment_created_at)),

    Comments = m_comment:more(ContentId, LastCommentId),
    ale:app(content_id, ContentId),
    ale:app(comments, Comments).
