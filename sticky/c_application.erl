-module(c_application).

-compile(export_all).

%% On load, after setting public directories, Ale calls this function to give
%% the application a chance to prepare things. The return value is ignored.
%%
%% SC: see yaws.hrl
start(_SC) ->
    ok.

error_404(_Arg, _Uri) ->
    [{status, 404}, {html, "Not found"}].

error_500(_Arg, _Type, _Reason) ->
    [{status, 500}, {html, "There was error processing your request. The admin has been notified. Sorry for your inconvenience."}].
