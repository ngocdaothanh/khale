-module(v_qa_show).

-compile(export_all).

-include("qa.hrl").

render() ->
    ale:app(title_in_body, h_qa:render_name()),

    Qa = ale:app(qa),
    TitleInHead = h_qa:render_title(Qa),
    ale:app(title_in_head, TitleInHead),

    User = m_user:find(Qa#qa.user_id),
    [
        {h1, [], TitleInHead},
        h_user:render(User, [
            h_tag:render_tags(qa, Qa#qa.id),
            h_application:render_timestamp(Qa#qa.created_at, Qa#qa.updated_at)
        ]),
        {'div', [], Qa#qa.detail},
        h_discussion:render_all(qa, Qa#qa.id)
    ].
