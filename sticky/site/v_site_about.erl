-module(v_site_about).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Title = ?T("About"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),

    Site = ale:app(site),
    [
        Site#site.about_long,
        {p, [], ?T("If you have any discussion about this site (bug report, idea etc.), please write it here.")},
        h_discussion:render_all(about, undefined)
    ].
