-module(h_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render_name() -> yaws_api:htmlize(?T("Article")).

render_title(Article) -> yaws_api:htmlize(Article#article.title).

render_preview(Article) ->
    User = m_user:find(Article#article.user_id),
    [
        render_header(User, Article),
        {'div', [], Article#article.abstract}
    ].

render_header(User, Article) ->
    Views = case Article#article.views > 1 of
        true  -> ?TF("~p views", [Article#article.views]);
        false -> undefined
    end,
    Edit = case h_app:editable(Article) of
        true  -> {a, [{href, ale:path(article, edit, [Article#article.id])}], ?T("Edit")};
        false -> undefined
    end,
    [
        h_user:render(User, [
            h_tag:render_tags(article, Article#article.id),
            h_app:render_timestamp(Article#article.created_at, Article#article.updated_at),
            Views,
            Edit
        ])
    ].
