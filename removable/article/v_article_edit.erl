-module(v_article_edit).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render() ->
    Title = ?T("Edit article"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Article = ale:app(article),
    case h_application:editable(Article) of
        false -> {p, [], ?T("Please login.")};

        true ->
            Id = Article#article.id,
            Tags = m_tag:all(article, Id),
            p_article_form:render(put, ale:path(update, [Id]), Article, Tags)
    end.
