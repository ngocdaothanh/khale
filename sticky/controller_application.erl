-module(controller_application).

-compile(export_all).

%% On load, after setting public directories, Ale calls this function to give
%% the application a chance to prepare things. The return value is ignored.
%%
%% SC: see yaws.hrl
start(_SC) ->
    ok.

before_filter

error_404(_Uri) ->
    ale:y(status, 404),
    ale:y(html, "Not found").

error_500(_Type, _Reason) ->
    ale:y(status, 500),
    ale:y(html, "There was error processing your request. The admin has been notified. Sorry for your inconvenience.").
