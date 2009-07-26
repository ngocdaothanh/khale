-module(v_qa_show).

-compile(export_all).

-include("qa.hrl").

render() ->
    ale:app(title, h_qa:render_name()),
    Qa = ale:app(qa),
    User = m_user:find(Qa#qa.user_id),
    [
        {h1, [], h_qa:render_title(Qa)},
        h_user:render(User),
        {'div', [], Qa#qa.detail},
        h_comment:render_all(qa, Qa#qa.id)
    ].
