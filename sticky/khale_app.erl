-module(khale_app).

-export([start/2, stop/1, init/1]).

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

start(_, _) ->
    supervisor:start_link(?MODULE, []).

init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    YawsSup     = {yaws_sup,      {yaws_sup,      start_link, []},             permanent, infinity,    supervisor, [yaws_sup]},
    HerlManager = {herml_manager, {herml_manager, start_link, [?MODULE, "."]}, permanent, brutal_kill, worker,     [herml_manager]},
    {ok, {SupFlags, [YawsSup, HerlManager]}}.

stop(_) ->
    ok.
