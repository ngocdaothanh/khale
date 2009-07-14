-module(default_v_error_404).

-compile(export_all).

-include("sticky.hrl").

render() ->
    [
        {h1, [], ?T("Page not found.")},
        {p, [], ?T("The page you're trying to access does not exist. Please check the address.")}
    ].
