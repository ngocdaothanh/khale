-module(default_v_error_404).

-compile(export_all).

render() ->
    [
        {h1, [], "We're sorry, but something went wrong."},
        {p, [], "The page you're trying to access does not exist. Please check the address."}
    ].
