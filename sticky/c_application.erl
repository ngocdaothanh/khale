-module(c_application).

-compile(export_all).

%% On application startup, after setting public directories, Ale calls this
%% function to give the application a chance to prepare things. The return value
%% should be {ok, SupPid} or ignore.
%%
%% SC   : see yaws.hrl
%% Nodes: list of nodes as specified in yaws.conf
start(_SC, Nodes) ->
    m_helper:start(Nodes),
    ignore.

before_filter(_Controller, _Action) ->
    ale:layout_module(default_v_layout),
    false.

error_404() ->
    ale:yaws(status, 404),
    ale:view_module(default_v_error_404).

error_500(_Type, _Reason) ->
    ale:yaws(status, 500),
    ale:view_module(default_v_error_500).
