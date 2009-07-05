-module(default_v_error_500).

-compile(export_all).

render() ->
    [
        {h1, [], "We're sorry, but something went wrong."},
        {p, [], "We've been notified about this issue and we'll take a look at it shortly."}
    ].
