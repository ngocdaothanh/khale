-module(c_about).

-routes([
    get, "/about", about
]).

-compile(export_all).

about() -> ok.
