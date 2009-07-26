-module(h_comment).

-compile(export_all).

-include("sticky.hrl").

render_last(ContentType, ContentId) ->
    case m_comment:last(ContentType, ContentId) of
        undefined   -> "";
        LastComment -> {ul, [{class, comments}], {li, [{class, "comment odd"}], render_one(LastComment, false)}}
    end.

render_all(ContentType, ContentId) ->
    User = ale:session(user),
    Composer1 = case User of
        undefined ->
            [
                {p, [{class, flash}], ?T("You need to login to write comment.")},
                h_user:login_links("comments")  % See below
            ];

        _ ->
            [
                {textarea, [{name, body}]},
                {input, [{type, submit}, {value, ?T("Save")}]}
            ]
    end,

    Comments = m_comment:more(ContentType, ContentId, undefined),

    Note = case (length(Comments) > 1) andalso (User == undefined) of
        true  -> {p, [], {em, [], ["(", ?T("The latest comment is displayed first"), ")"]}};
        false -> ""
    end,
    Composer2 = {'div', [{id, comment_composer}], [Composer1, Note]},

    ale:app(comments, Comments),
    [
        {a, [{name, comments}]},
        {h2, [], ?T("Comments")},
        Composer2,
        v_comment_more:render()
    ].

%-------------------------------------------------------------------------------

render_one(Comment, Editable) ->
    User = m_user:find(Comment#comment.user_id),
    [
        h_user:render(User),
        Comment#comment.body
    ].
