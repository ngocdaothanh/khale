-module(v_qa_edit).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render() ->
    Title = ?T("Edit Q/A"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Qa = ale:app(qa),
    case h_app:editable(Qa) of
        false -> {p, [], ?T("Please login.")};

        true ->
            Id = Qa#qa.id,
            Tags = m_tag:all(qa, Id),
            p_qa_form:render(put, ale:path(update, [Id]), Qa, Tags)
    end.
