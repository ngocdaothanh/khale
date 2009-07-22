-module(v_about_about).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("About")),
    About = m_about:find(),
    [
        About#about.long,
        {p, [], ?T("If you have any comment about this site (bug report, idea etc.), please write it here.")},
        h_application:comments()
    ].
