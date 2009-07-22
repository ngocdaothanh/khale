-module(c_comment).

-routes([
    get, "/comments/:content_id/:last_comment_created_at", more
]).

-compile(export_all).

more() ->
    ContentId = list_to_integer(ale:params(content_id)),
    LastCommentCreatedAt = case ale:params(last_comment_created_at) of
        undefined -> undefined;
        YMDHMiS   -> h_content:string_to_timestamp(YMDHMiS)
    end,

    Comments = m_comment:more(ContentId, LastCommentCreatedAt),
    ale:app(content_id, ContentId),
    ale:app(comments, Comments).
