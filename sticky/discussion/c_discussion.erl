-module(c_discussion).

-routes([
    get,  "/discussions/:content_type/:content_id/:prev_discussion_id", more,
    post, "/discussions/:content_type/:content_id",                     create
]).

-compile(export_all).

more() ->
    ContentType = ale:params(content_type),
    ContentId   = list_to_integer(ale:params(content_id)),
    PrevDiscussionId = list_to_integer(ale:params(prev_discussion_id)),
    Discussions = m_discussion:more(ContentType, ContentId, PrevDiscussionId),

    ale:app(content_type, ContentType),
    ale:app(content_id, ContentId),
    ale:app(discussions, Discussions).

create() ->
    ok.