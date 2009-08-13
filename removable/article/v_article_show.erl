-module(v_article_show).

-compile(export_all).

-include("article.hrl").

render() ->
    ale:app(title_in_body, h_article:render_name()),

    Article = ale:app(article),
    ale:app(title_in_head, h_article:render_title(Article)),

    User = m_user:find(Article#article.user_id),
    [
        {h1, [], h_article:render_title(Article)},
        h_article:render_header(User, Article),
        {'div', [], [Article#article.abstract, Article#article.body]},
        h_discussion:render_all(article, Article#article.id)
    ].
