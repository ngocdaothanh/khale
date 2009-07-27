-module(c_application).

-compile(export_all).

-include("sticky.hrl").

-define(SUP, ?MODULE).
-define(MAX_R, 1).
-define(MAX_T, 60).

%% On application startup, after setting public directories, Ale calls this
%% function to give the application a chance to prepare things. The return value
%% should be {ok, SupPid} or ignore.
%%
%% SC   : see yaws.hrl
%% Nodes: list of nodes as specified in yaws.conf
start(_SC, Nodes) ->
    m_helper:start(Nodes),
    supervisor:start_link({local, ?SUP}, ?MODULE, []).

before_action(_Controller, _Action) ->
    case ale:method() == get andalso ale:params(without_layout) == "true" of
        true  -> ok;
        false -> ale:layout_module(default_v_layout)
    end,
    false.

error_404() ->
    ale:yaws(status, 404),
    ale:view_module(default_v_error_404).

error_500(_Type, _Reason) ->
    ale:yaws(status, 500),
    ale:view_module(default_v_error_500).

init([]) ->
    ChildSpec = {chat, {s_chat, start_link, []}, permanent, brutal_kill, worker, [s_chat]},
    {ok, {{one_for_one, ?MAX_R, ?MAX_T}, [ChildSpec]}}.
