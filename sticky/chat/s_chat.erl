%%% Anonymous single web chat room:
%%% * Users only care about chat messages and relative number of online users.
%%% * There is only one room (lobby).
%%%
%%% Long polling Comet is chosen. Forever frame was not chosen because the
%%% browser would display the ugly "Loading..." status, and if the use
%%% clicks Stop button the frame is stopped.
%%%
%%% See:
%%% * http://yoan.dosimple.ch/blog/2008/05/15/
%%% * http://www.metabrew.com/article/a-million-user-comet-application-with-mochiweb-part-1/
%%% * http://cometdaily.com/2007/12/11/the-future-of-comet-part-1-comet-today/
%%% * http://cometdaily.com/2007/11/16/more-on-long-polling/
%%% * http://cometdaily.com/2007/12/18/latency-long-polling-vs-forever-frame/
%%%
%%% Existing clients are not notified when a client leaves or enters the chat
%%% room. This is to avoid continuos Ajax connection disconnection. The reason
%%% is because of the nature of HTTP connections: only when "keep-alive" is
%%% specified, the connection may be CLOSED on Comet reply.
%%%
%%% This module is tightly coupled with b_chat and c_chat.
-module(s_chat).

-compile(export_all).

-define(SERVER, {global, ?MODULE}).
-define(MSG_STORAGE_SIZE, 100).

-record(state, {msg_now_list, pids}).

%% The whole site has only one chat room.
start_link()        -> gen_server:start_link(?SERVER, ?MODULE, [], []).

%% Called by b_chat.
%% Returns {NumUsers, Msgs, Now}.
msgs()              -> gen_server:call(?SERVER, msgs).

%% Called by c_chat's GET.
%%
%% Returns {Msgs, NewNow} and does not subscribe Pid if there is any
%% messages since Now, or NumUsers if Pid has been subsribed.
%%
%% If Pid is subscribed, it will receive {chat, Msg, Now} and will be unsuscribed
%% when there is a new message, it does not have to call unsubscribe. It will
%% receive nothing when the number of users changes because the number of users
%% is reset to 0 when a new message comes.
subscribe(Pid, Now) -> gen_server:call(?SERVER, {subscribe, Pid, Now}).

%% Called by c_chat's GET.
unsubscribe(Pid)    -> gen_server:cast(?SERVER, {unsubscribe, Pid}).

%% Called by c_chat's POST.
%%
%% A publisher is probably not a subscriber. This is different from room
%% enter/leave termilogy.
publish(Msg)        -> gen_server:cast(?SERVER, {publish, Msg}).

%-------------------------------------------------------------------------------

init([]) ->
    process_flag(trap_exit, true),
    {ok, #state{msg_now_list = [], pids = []}}.

handle_call(msgs, _From, State = #state{msg_now_list = MsgNowList, pids = Pids}) ->
    {Msgs, Now} = msgs(MsgNowList, {0, 0, 0}),
    {reply, {length(Pids), Msgs, Now}, State};

%% See comment about CLOSED on top.
handle_call({subscribe, Pid, Now}, _From, State = #state{msg_now_list = MsgNowList, pids = Pids}) ->
    Pids2 = case lists:member(Pid, Pids) of
        false ->
            link(Pid),
            [Pid | Pids];

        true -> Pids
    end,
    NumUsers = length(Pids2),

    {Reply, State2} = case msgs(MsgNowList, Now) of
        {[], _}      -> {NumUsers, State#state{pids = Pids2}};
        {Msgs, Now2} -> {{NumUsers, Msgs, Now2}, State}
    end,
    {reply, Reply, State2}.

handle_cast({publish, Msg}, State = #state{msg_now_list = MsgNowList, pids = Pids}) ->
    NumUsers = length(Pids),
    Now      = now(),
    lists:foreach(
        fun(Pid) -> Pid ! {chat, NumUsers, Msg, Now} end,
        Pids
    ),

    MsgNowList2 = case length(MsgNowList) of
        ?MSG_STORAGE_SIZE ->
            [_Hd | Rest] = MsgNowList,
            Rest;

        _ -> MsgNowList
    end,
    {noreply, State#state{msg_now_list = MsgNowList2 ++ [{Msg, Now}], pids = []}};

%% See comment about CLOSED on top.
handle_cast({unsubscribe, Pid}, State = #state{pids = Pids}) ->
    Pids2 = Pids -- [Pid],
    {noreply, State#state{pids = Pids2}}.

handle_info({'EXIT', Pid, _Reason}, State) -> handle_cast({unsubscribe, Pid}, State).

terminate(_Reason, _State) -> ok.

%-------------------------------------------------------------------------------

%% Returns {Msgs, NewNow}
msgs(MsgNowList, Now) ->
    Msgs1 = lists:foldl(
        fun({Msg, Now2}, Acc) ->
            case Now2 > Now of
                true  -> [Msg | Acc];
                false -> Acc
            end
        end,
        [],
        MsgNowList
    ),

    case Msgs1 of
        [] -> {[], Now};

        _ ->
            Msgs2 = lists:reverse(Msgs1),
            {_, NewNow} = lists:last(MsgNowList),
            {Msgs2, NewNow}
    end.
