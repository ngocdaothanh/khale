-module(c_application).

-compile(export_all).

%% On load, after setting public directories, Ale calls this function to give
%% the application a chance to prepare things. The return value should be
%% {ok, SupPid} or ignore.
%%
%% SC: see yaws.hrl
start(_SC) ->
    ignore.

before_filter(_Controller, _Action, _Args) ->
    ale:layout(default_v_layout),
    false.

error_404() ->
    ale:yaws(status, 404),
    ale:view(default_v_error_404).

error_500(_Type, _Reason) ->
    ale:yaws(status, 500),
    ale:view(default_v_error_500).
