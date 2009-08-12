-module(h_discussion).

-compile(export_all).

-include("sticky.hrl").

render_last(ContentType, ContentId) ->
    case m_discussion:last(ContentType, ContentId) of
        undefined  -> "";
        Discussion -> {ul, [{class, "discussions last_discussion"}], render_one(Discussion, false)}
    end.

render_all(ContentType, ContentId) ->
    Discussions = m_discussion:more(ContentType, ContentId, undefined),

    {Question, EcryptedAnswer} = ale:mathcha(),
    Composer = {'div', [{id, discussion_composer}], [
        {input, [{type, hidden}, {name, content_type}, {value, ContentType}]},
        {input, [{type, hidden}, {name, content_id}, {value, ContentId}]},

        {textarea, [{name, body}]},

        {span, [{class, label}], Question},
        {input, [{type, text}, {class, textbox}, {name, answer}]},
        {input, [{type, hidden}, {name, encrypted_answer}, {value, EcryptedAnswer}]},

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

render_one(Discussion, Editable) ->
    Id = integer_to_list(Discussion#discussion.id),
    Edit = case Editable andalso h_application:editable(Discussion) of
        false -> [];
        true  -> [{a, [{href, "#"}, {onclick, ["discussionDelete(", Id, "); return false"]}], ?T("Delete")}]
    end,

    User = m_user:find(Discussion#discussion.user_id),
    {li, [{id, ["discussion_", Id]}, {class, discussion}], [
        h_user:render(User, [
            h_application:render_timestamp(Discussion#discussion.created_at, Discussion#discussion.updated_at) |
            Edit
        ]),
        Discussion#discussion.body
    ]}.
