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

                {title, [], '$title_in_head'},

                {link, [{rel, alternate}, {type, "application/atom+xml"}, {href, ale:path(content, feed)}]},
                {link, [{rel, icon}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},
                {link, [{rel, "shortcut icon"}, {type, "img/x-icon"}, {href, "/favicon.ico"}]},

                {link, [{rel, stylesheet}, {type, "text/css"}, {media, "screen, projection"}, {href, "/static/css/screen.css"}]},
                {link, [{rel, stylesheet}, {type, "text/css"}, {media, "screen, projection"}, {href, "/static/css/fancy-type/screen.css"}]},
                {link, [{rel, stylesheet}, {type, "text/css"}, {media, "print"}, {href, "/static/css/print.css"}]},
%                "<!--[if lt IE 8]>",
%                {link, [{rel, stylesheet}, {type, "text/css"}, {media, "screen, projection"}, {href, "/static/css/ie.css"}]},
%                "<![endif]-->",
                {link, [{rel, stylesheet}, {type, "text/css"}, {href, "/static/date_picker/date_picker.css"}]},
                {link, [{rel, stylesheet}, {type, "text/css"}, {href, "/static/css/page.css"}]},

                {script, [{type, "text/javascript"}, {src, "/static/js/jquery.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/date_picker/date.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/date_picker/date_picker.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/tiny_mce/tiny_mce.js"}]},
                {script, [{type, "text/javascript"}, {src, "/static/js/app.js"}]},

                '$heads'
            ]},

            {body, [], [
                {'div', [{id, container}, {class, "container"}], [
                    {'div', [{id, header}, {class, "span-24"}], [
                        {h1, [], {a, [{href, "/"}], Name}},
                        {h3, [{class, "alt quiet"}], Subtitle}
                    ]},

                    {hr},

                    {'div', [{id, left1}, {class, "span-4 quiet"}], '$left1'},
                    {'div', [{id, main}, {class, "span-15"}], [
                            '$flash',
                            '$title_in_body',
                            '$content_for_layout'
                    ]},
                    {'div', [{id, right1}, {class, "span-5 last"}], '$right1'},

                    {'div', [{id, bottom}, {class, "clear prepend-top span-24"}], [
                        {'div', [{id, left2},  {class, "span-12"}],      '$left2'},
                        {'div', [{id, right2}, {class, "span-12 last"}], '$right2'}
                    ]},

                    {'div', [{id, footer}, {class, "span-24"}], [
                        "Powered by ", {a, [{href, "http://github.com/ngocdaothanh/khale"}], "Khale"}
                    ]}
                ]},

                '$scripts'
            ]}
        ]}
    end, ehtmle),

    T = yaws_api:ehtml_apply(E, [
        {title_in_head,      h_app:title_in_head()},
        {heads,              ale:app(heads)},
        {flash,              h_app:flash()},
        {title_in_body,      h_app:title_in_body()},
        {content_for_layout, ale:app(content_for_layout)},
        {left1,              h_app:region(left1)},
        {right1,             h_app:region(right1)},
        {left2,              h_app:region(left2)},
        {right2,             h_app:region(right2)},
        {scripts,            ale:app(scripts)}
    ]),
    [
        "<!DOCTYPE html PUBLIC \"-//W3C//DTD XHTML 1.0 Transitional//EN\" \"http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd\">",
        T
    ].
