-module(v_article_show).

-compile(export_all).

-include("article.hrl").

render() ->
    ale:app(title, h_article:render_name()),
    Article = ale:app(article),
    User = m_user:find(Article#article.user_id),
    [
        {h1, [], h_article:render_title(Article)},
        h_user:render(User),
        {'div', [], [Article#article.abstract, Article#article.body]},
        h_comment:render_all(article, Article#article.id)
    ].
