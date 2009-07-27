-module(v_about_about).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("About")),
    About = m_about:find(undefined),
    [
        About#about.long,
        {p, [], ?T("If you have any discussion about this site (bug report, idea etc.), please write it here.")},
        h_discussion:render_all(about, undefined)
    ].
