-module(default_v_layout).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Site     = ale:app(site),
    Name     = yaws_api:htmlize(Site#site.name),
    Subtitle = yaws_api:htmlize(Site#site.subtitle),
    E = ale:cache("default_v_layout", fun() ->
        {html, [{xmlns, "http://www.w3.org/1999/xhtml"}, {'xmlns:fb', "http://www.facebook.com/2008/fbml"}], [
            {head, [], [
                {meta, [{'http-equiv', "content-type"}, {content, "text/html; charset=utf-8"}]},
                {meta, [{name, "description"}, {content, "CMS based on Ale based on Yaws"}]},
                {meta, [{name, "keywords"}, {content, "ale, erlang, yaws, web"}]},

                {link, [{rel, "icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},
                {link, [{rel, "shortcut icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},

                {title, [], '$title_in_head'},

                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/reset.css"}]},
                {link, [{rel, "stylesheet"}, {type, "text/css"}, {href, "/static/css/page.css"}]},

                {script, [{type, "text/javascript"}, {src, "/static/js/jquery.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/tiny_mce/tiny_mce.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/js/application.js"}]},

                '$heads'
            ]},

            {body, [], [
                {'div', [{id, container}], [
                    {'div', [{id, header}, {class, padding}], [
                        {h1, [], {a, [{href, "/"}], Name}},
                        {h2, [], Subtitle}
                    ]},

                    {'div', [{id, left_column}], {'div', [{class, padding}], '$left_column'}},

                    {'div', [{id, main_and_right}], [
                        {'div', [{id, main}], {'div', [{class, padding}], [
                            '$flash',
                            '$title_in_body',
                            '$content_for_layout'
                        ]}},

                        {'div', [{id, right_column}], {'div', [{class, padding}], '$right_column'}}
                    ]},

                    {br, [{class, clear}]}
                ]},

                {'div', [{id, footer}], [
                    "Powered by ", {a, [{href, "http://github.com/ngocdaothanh/khale"}], "Khale"}
                ]},

                '$scripts'
            ]}
        ]}
    end, ehtmle),

    T = yaws_api:ehtml_apply(E, [
        {title_in_head,      h_application:title_in_head()},
        {heads,              ale:app(heads)},
        {flash,              h_application:flash()},
        {title_in_body,      h_application:title_in_body()},
        {content_for_layout, ale:app(content_for_layout)},
        {left_column,        h_application:region(left_column)},
        {right_column,       h_application:region(right_column)},
        {scripts,            ale:app(scripts)}
    ]),
    [
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
        T
    ].
