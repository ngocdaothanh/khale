-module(v_content_instructions).

-compile(export_all).

-include_lib("sticky.hrl").

render() ->
    [
        {p, [], ?T("Which type of content do you want to create?")},
        {ul, [],
            [{li, [], render_one(M)} || M <- ale:app(content_modules)]
        },
        {p, [], ?T("To avoid duplicate contents, before creating please search to check if similar thing has already existed.")}
    ].

render_one(ContentModule) ->
    [$m, $_ | Type] = atom_to_list(ContentModule),
    [
        {a, [{href, ["/new/", Type]}], ContentModule:name()}, ": ",
        ContentModule:instruction()
    ].
