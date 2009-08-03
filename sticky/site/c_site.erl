-module(c_site).

-routes([
    get, "/about", about
]).

-compile(export_all).

about() -> ok.
