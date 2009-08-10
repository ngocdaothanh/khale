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
    ale:view(undefined),

    Answer = ale:params(answer),
    EncryptedAnswer = ale:params(encrypted_answer),
    case ale:mathcha(Answer, EncryptedAnswer) of
        false ->
            Data = {struct, [{error, ?T("Wrong math result!")}]},
            ale:yaws(content, "application/json", json:encode(Data));

        true ->
            ContentType = list_to_existing_atom(ale:params(content_type)),
            ContentId   = list_to_integer(ale:params(content_id)),
            {ok, Body}  = esan:san(ale:params(body)),
            Body2       = binary_to_list(unicode:characters_to_binary(Body)),  % Must be plain list of 0-255 for ehtml_expand to work
            UserId      = case ale:session(user) of
                undefined -> undefined;
                User      -> User#user.id
            end,
            Ip          = ale:ip(),

            Data = case m_discussion:create(UserId, Ip, ContentType, ContentId, Body2) of
                {error, Error} -> {struct, [{error, Error}]};

                {atomic, Discussion} ->
                    Ehtml = h_discussion:render_one(Discussion, true),
                    Html = yaws_api:ehtml_expand(Ehtml),
                    {struct, [{atomic, lists:flatten(Html)}]}  % Must be plain list
            end,
            ale:yaws(content, "application/json", json:encode(Data))
    end.

delete() ->
    ale:view(undefined),
    Id = list_to_integer(ale:params(id)),
    m_discussion:delete(Id).
