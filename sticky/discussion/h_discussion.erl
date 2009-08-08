-module(h_discussion).

-compile(export_all).

-include("sticky.hrl").

render_last(ContentType, ContentId) ->
    case m_discussion:last(ContentType, ContentId) of
        undefined   -> "";
        LastDiscussion -> {ul, [{class, discussions}], {li, [{class, "discussion odd"}], render_one(LastDiscussion, false)}}
    end.

render_all(ContentType, ContentId) ->
    Discussions = m_discussion:more(ContentType, ContentId, undefined),

    {Question, EcryptedAnswer} = ale:mathcha(),
    Composer = {'div', [{id, discussion_composer}], [
        {textarea, [{name, body}]},

        {span, [{class, label}], Question},
        {input, [{type, text}, {class, textbox}, {name, captcha}]},
        {input, [{type, hidden}, {name, captcha_encrypted}, {value, EcryptedAnswer}]},

        {input, [{type, submit}, {class, button}, {value, ?T("Save")}]}
    ]},

    ale:app(content_type, ContentType),
    ale:app(content_id, ContentId),
    ale:app(discussions, Discussions),
    [
        {hr},
        {a, [{name, discussions}]},
        {h2, [], ?T("Discussions")},
        v_discussion_more:render(),
        Composer
    ].

%-------------------------------------------------------------------------------

render_one(Discussion, Editable) ->
    User = m_user:find(Discussion#discussion.user_id),
    [
        h_user:render(User),
        Discussion#discussion.body
    ].
