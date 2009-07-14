-module(default_v_error_500).

-compile(export_all).

-include("sticky.hrl").

render() ->
    [
        {h1, [], ?T("We're sorry, but something went wrong.")},
        {p, [], ?T("We've been notified about this issue and we'll take a look at it shortly.")}
    ].
