-module(h_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render_name() -> yaws_api:htmlize(?T("Q/A")).

render_title(Qa) -> yaws_api:htmlize(Qa#qa.question).

render_preview(Qa) ->
    User = m_user:find(Qa#qa.user_id),
    [
        render_header(User, Qa, true),
        {'div', [], Qa#qa.detail}
    ].

render_header(User, Qa, Linked) ->
    Title = case Linked of
        false -> render_title(Qa);
        true  -> {a, [{href, ale:path(qa, show, [Qa#qa.id])}], render_title(Qa)}
    end,
    Views = case Qa#qa.views > 1 of
        true  -> ?TF("~p views", [Qa#qa.views]);
        false -> undefined
    end,
    Edit = case h_application:editable(Qa) of
        true  -> {a, [{href, ale:path(qa, edit, [Qa#qa.id])}], ?T("Edit")};
        false -> undefined
    end,
    [
        {h1, [], Title},
        h_user:render(User, [
            h_tag:render_tags(qa, Qa#qa.id),
            h_application:render_timestamp(Qa#qa.created_at, Qa#qa.updated_at),
            Views,
            Edit
        ])
    ].
