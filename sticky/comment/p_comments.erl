-module(p_comments).

-compile(export_all).

-include("sticky.hrl").

%% Render all comments for a content.
render(Content) ->
    User = ale:session(user),
    Composer1 = case User of
        undefined ->
            {
                'div', [{class, flash}],
                {a, [{href, "#login"}], ?T("You need to login to write comment.")}
            };

        _ ->
            [
                {textarea, [{name, body}]},
                {input, [{type, submit}, {value, ?T("Save")}]}
            ]
    end,

    Comments = m_comment:more(Content#content.id, undefined),

    Note = case (length(Comments) > 1) andalso (User == undefined) of
        true  -> {p, [], {em, [], ["(", ?T("The latest comment is displayed first"), ")"]}};
        false -> ""
    end,
    Composer2 = {'div', [{id, comment_composer}], [Composer1, Note]},

    ale:app(content_id, Content#content.id),
    ale:app(comments, Comments),
    [
        {h2, [], ?T("Comments")},
        Composer2,
        v_comment_more:render()
    ].
