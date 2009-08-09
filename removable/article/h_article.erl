-module(h_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render_name() -> yaws_api:htmlize(?T("Article")).

render_title(Article) -> yaws_api:htmlize(Article#article.title).

render_preview(Article) ->
    User = m_user:find(Article#article.user_id),
    [
        {h1, [], {a, [{href, ale:path(article, show, [Article#article.id])}], render_title(Article)}},
        h_user:render(User, [httpd_util:rfc1123_date(Article#article.updated_at)]),
        {'div', [], Article#article.abstract}
    ].
