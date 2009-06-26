-module(controller_content).

-compile(export_all).

routes() -> [
    get, "", recent_contents
].

recent_contents() ->
    erlang:display(99), 9 = 8,
    put(content, 8),"Recent contents".
