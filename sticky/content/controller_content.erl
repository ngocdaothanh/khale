-module(controller_content).

-compile(export_all).

routes() -> [
    get, "", recent_contents
].

recent_contents() ->
    ale:a(description, "CMS based on Ale based on Yaws"),
    ale:a(keywords, "ale, erlang, yaws, web"),
    ale:a(main_panel, "Recent contents"),
    ale:a(scripts,    []),

    {ok, T} = file:consult("themes/default/layout.ehtml"),
    CT = yaws_api:ehtml_expander(T),
    E = ale:build_template_environment(),
    R = yaws_api:ehtml_apply(CT, E),

    ale:y(html, R).
