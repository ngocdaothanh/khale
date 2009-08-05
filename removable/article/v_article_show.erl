-module(v_article_show).

-compile(export_all).

-include("article.hrl").

render() ->
    ale:app(title_in_body, h_article:render_name()),

    Article = ale:app(article),
    TitleInHead = h_article:render_title(Article),
    ale:app(title_in_head, TitleInHead),

    User = m_user:find(Article#article.user_id),
    [
        {h1, [], TitleInHead},
        h_user:render(User),
        {'div', [], [Article#article.abstract, Article#article.body]},
        h_discussion:render_all(article, Article#article.id)
    ].
