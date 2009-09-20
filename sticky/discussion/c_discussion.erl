-module(c_discussion).

-routes([
    get,    "/discussions/:content_type/:content_id/:prev_discussion_id", more,
    post,   "/discussions/:content_type/:content_id",                     create,
    delete, "/discussions/:id", delete
]).

-compile(export_all).

-include("sticky.hrl").

more() ->
    ContentType = ale:params(content_type),
    ContentId   = list_to_integer(ale:params(content_id)),
    PrevDiscussionId = list_to_integer(ale:params(prev_discussion_id)),
    Discussions = m_discussion:more(ContentType, ContentId, PrevDiscussionId),

    ale:app(content_type, ContentType),
    ale:app(content_id, ContentId),
    ale:app(discussions, Discussions).

create() ->
    Answer = ale:params(answer),
    EncryptedAnswer = ale:params(encrypted_answer),
    Data = case ale:mathcha(Answer, EncryptedAnswer) of
        false -> {struct, [{error, ?WRONG_MATHCHA}]};

        true ->
            ContentType = list_to_existing_atom(ale:params(content_type)),
            ContentId   = list_to_integer(ale:params(content_id)),
            Body        = esan:san(ale:params(body)),
            UserId      = h_app:user_id(),
            Ip          = ale:ip(),

            Discussion = #discussion{
                user_id = UserId, ip = Ip,
                content_type = ContentType, content_id = ContentId, body = Body
            },

            case m_discussion:create(Discussion) of
                {error, Error} -> {struct, [{error, Error}]};

                {atomic, Discussion2} ->
                    Ehtml = h_discussion:render_one(Discussion2, true),
                    Html = yaws_api:ehtml_expand(Ehtml),
                    {struct, [{atomic, lists:flatten(Html)}]}  % Must be plain list
            end
    end,
    ale:view(undefined),
    ale:yaws(content, "application/json", json:encode(Data)).

delete() ->
    ale:view(undefined),
    Id = list_to_integer(ale:params(id)),
    m_discussion:delete(Id).
