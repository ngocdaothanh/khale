%%% See http://yoan.dosimple.ch/blog/2008/05/15/
-module(s_chat).

-compile(export_all).

-define(SERVER, {global, ?MODULE}).
-define(MSG_STORAGE_SIZE, 100).
-define(TIMEOUT, 10000).

-record(state, {msg_now_list, clients}).

%% The whole site has only one chat room.
start_link()     -> gen_server:start_link(?SERVER, ?MODULE, [], []).

%% When there is new chat message, Pid will be sent {chat, Msg, Now}.
subscribe(Pid)   -> gen_server:cast(?SERVER, {subscribe, Pid}).

unsubscribe(Pid) -> gen_server:cast(?SERVER, {unsubscribe, Pid}).

chat(Msg)        -> gen_server:cast(?SERVER, {chat, Msg}).

%% Returns {[{Name, Msg}], NewPrevNow}.
msgs(PrevNow)    -> gen_server:call(?SERVER, {msgs, PrevNow}).

timeout() -> ?TIMEOUT.

%-------------------------------------------------------------------------------

init([]) -> {ok, #state{msg_now_list = [], clients = []}}.

handle_call({msgs, PrevNow}, _From, State) ->
    MsgNowList = State#state.msg_now_list,
    Msgs1 = lists:foldl(
        fun({Msg, Now}, Acc) ->
            case Now > PrevNow of
                true  -> [Msg | Acc];
                false -> Acc
            end
        end,
        [],
        MsgNowList
    ),

    Reply = case Msgs1 of
        [] -> {[], PrevNow};

        _ ->
            Msgs2 = lists:reverse(Msgs1),
            {_, PrevNow2} = lists:last(MsgNowList),
            {Msgs2, PrevNow2}
    end,
    {reply, Reply, State}.

handle_cast({subscribe, Pid}, State) ->
    Clients = State#state.clients,
    {noreply, State#state{clients = [Pid | Clients]}, ?TIMEOUT};

handle_cast({unsubscribe, Pid}, State) ->
    Clients = State#state.clients,
    {noreply, State#state{clients = Clients -- [Pid]}, ?TIMEOUT};

handle_cast({chat, Msg}, State) ->
    Clients = State#state.clients,
    Now = now(),
    lists:foreach(
        fun(Pid) -> Pid ! {chat, Msg, Now} end,
        Clients
    ),

    MsgNowList1 = State#state.msg_now_list,
    MsgNowList2 = case length(MsgNowList1) of
        ?MSG_STORAGE_SIZE ->
            [_Hd | Rest] = MsgNowList1,
            Rest;

        _ -> MsgNowList1
    end,
    MsgNowList3 = MsgNowList2 ++ [{Msg, Now}],
    {noreply, State#state{msg_now_list = MsgNowList3, clients = []}}.

handle_info(timeout, State) -> {noreply, State#state{clients = []}}.

terminate(_Reason, _State) -> ok.
