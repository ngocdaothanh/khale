-module(controller_content).

-compile(export_all).

routes() -> [
    get, "", recent_contents
].

recent_contents() ->
    put(content, "Recent contents").
