-module(h_article).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render_name() -> yaws_api:htmlize(?T("Article")).

render_title(Article) -> yaws_api:htmlize(Article#article.title).

show_path(Article) -> ale:path(article, show, [Article#article.id]).

render_preview(Article) ->
    User = m_user:find(Article#article.user_id),
    [
        {h1, [], {a, [{href, show_path(Article)}], render_title(Article)}},
        h_user:render(User),
        {'div', [], Article#article.abstract},
        h_comment:render_last(article, Article#article.id)
    ].
