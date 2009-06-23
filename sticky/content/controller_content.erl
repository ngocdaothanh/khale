-module(controller_content).

-compile(export_all).

map() -> [
    get, "", recent_contents
].

recent_contents() ->
    "Recent contents".
