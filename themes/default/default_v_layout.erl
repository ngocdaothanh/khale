-module(default_v_layout).

-compile(export_all).

render() ->
    [
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
        {html, [{xmlns, "http://www.w3.org/1999/xhtml"}, {'xml:lang', "en"}, {lang, "en"}], [
            {head, [], [
                {meta, [{'http-equiv', "content-type"}, {content, "text/html; charset=utf-8"}]},
                {meta, [{name, "description"}, {content, "CMS based on Ale based on Yaws"}]},
                {meta, [{name, "keywords"}, {content, "ale, erlang, yaws, web"}]},

                {link, [{rel, "icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},
                {link, [{rel, "shortcut icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},

                {title, [], h_theme:title_in_head()},

                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/reset.css"}]},
                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/page.css"}]},

                {script, [{type, "text/javascript"}, {src, "/static/js/jquery.js"}]}
            ]},

            {body, [], [
                {'div', [{id, container}], [
                    {'div', [{id, content_for_layout}], [
                        {'div', [{id, header}],
                            {h1, [], {a, [{href, "/"}], "Khale"}}
                        },

                        h_theme:title_in_body(),

                        ale:content_for_layout()
                    ]},

                    h_theme:region(sidebar),

                    {br, [{class, clear}]},

                    {'div', [{id, footer}], [
                        "Powered by ",
                        {a, [{href, "http://github.com/ngocdaothanh/khale"}], "Khale"}
                    ]}
                ]},

                ale:script()
            ]}
        ]}
    ].
