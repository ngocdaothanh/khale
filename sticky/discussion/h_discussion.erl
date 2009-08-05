-module(h_discussion).

-compile(export_all).

-include("sticky.hrl").

render_last(ContentType, ContentId) ->
    case m_discussion:last(ContentType, ContentId) of
        undefined   -> "";
        LastDiscussion -> {ul, [{class, discussions}], {li, [{class, "discussion odd"}], render_one(LastDiscussion, false)}}
    end.

render_all(ContentType, ContentId) ->
    User = ale:session(user),
    Composer1 = case User of
        undefined ->
            [
                {p, [{class, flash}], ?T("Please login so that we know who you are.")},
                h_user:login_links("discussions")  % See below
            ];

        _ ->
            [
                {textarea, [{name, body}]},
                {input, [{type, submit}, {value, ?T("Save")}]}
            ]
    end,

    Discussions = m_discussion:more(ContentType, ContentId, undefined),

    Note = case (length(Discussions) > 1) andalso (User == undefined) of
        true  -> {p, [], {em, [], ["(", ?T("The latest discussion is displayed first"), ")"]}};
        false -> ""
    end,
    Composer2 = {'div', [{id, discussion_composer}], [Composer1, Note]},

    ale:app(content_type, ContentType),
    ale:app(content_id, ContentId),
    ale:app(discussions, Discussions),
    [
        {hr},
        {a, [{name, discussions}]},
        {h2, [], ?T("Discussions")},
        Composer2,
        v_discussion_more:render()
    ].

%-------------------------------------------------------------------------------

render_one(Discussion, Editable) ->
    User = m_user:find(Discussion#discussion.user_id),
    [
        h_user:render(User),
        Discussion#discussion.body
    ].
