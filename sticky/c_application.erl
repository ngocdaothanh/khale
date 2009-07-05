-module(c_application).

-compile(export_all).

%% On load, after setting public directories, Ale calls this function to give
%% the application a chance to prepare things. The return value is ignored.
%%
%% SC: see yaws.hrl
start(_SC) ->
    ok.

error_404(_Arg, _Uri) ->
    ale:put(yaws, status, 404),
    ale:put(ale, view, default_v_error_404).

error_500(_Arg, _Type, _Reason) ->
    ale:put(yaws, status, 500),
    ale:put(ale, view, default_v_error_500).
