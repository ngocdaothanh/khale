-module(layout_default).

-compile(export_all).

render(ContentForLayout, Scripts) ->
    [
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
        {html, [{xmlns, "http://www.w3.org/1999/xhtml"}, {'xml:lang', "en"}, {lang, "en"}], [
            {head, [], [
                {meta, [{'http-equiv', "content-type"}, {content, "text/html; charset=utf-8"}]},
                {meta, [{name, "description"}, {content, "CMS based on Ale based on Yaws"}]},
                {meta, [{name, "keywords"}, {content, "ale, erlang, yaws, web"}]},

                {link, [{rel, "icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},
                {link, [{rel, "shortcut icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},

                {title, [], "Khale"},

                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/reset.css"}]},
                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/page.css"}]},

                {script, [{type, "text/javascript"}, {src, "/static/js/jquery.js"}]}
            ]},

            {body, [], [
                {'div', [{id, "container"}], [
                    {'div', [{id, "header"}], "Khale"},
                    ContentForLayout
                ]},

                Scripts
            ]}
        ]}
    ].
