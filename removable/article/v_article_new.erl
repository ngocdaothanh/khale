-module(v_article_new).

-compile(export_all).

-include("sticky.hrl").
-include("article.hrl").

render() ->
    Title = ?T("Create new article"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    [
        {p, [], ?T("You can create content of type article to post a notice, a tutorial etc.")},
        p_article_form:render(post, ale:path(create), #article{title = "", abstract = "", body = ""}, [])
    ].
