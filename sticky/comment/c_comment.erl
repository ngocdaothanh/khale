-module(c_comment).

-routes([
    get,  "/comments/:content_type/:content_id/:last_comment_id", more,
    post, "/comments/:content_type/:content_id",                  create
]).

-compile(export_all).

more() ->
    ContentType = ale:params(content_type),
    ContentId   = list_to_integer(ale:params(content_id)),
    LastCommentId = list_to_integer(ale:params(last_comment_id)),
    Comments = m_comment:more(ContentType, ContentId, LastCommentId),
    ale:app(comments, Comments).
