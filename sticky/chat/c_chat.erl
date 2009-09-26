-module(c_chat).

-routes([
    post, "/chats/:now", more,  % POST is used to avoid browser cache
    post, "/chats",      create
]).

-compile(export_all).

-include("sticky.hrl").
-define(TIMEOUT, 60000).

before_action() ->
    ale:view(undefined),
    true.

more() ->
    Now1 = ale:params(now),
    Now2 = h_app:string_to_now(Now1),
    case s_chat:subscribe(self(), Now2) of
        {NumUsers, Msgs, Now3} ->
            Data = {struct, [
                {numUsers, NumUsers},
                {msgs, {array, Msgs}},
                {now, h_app:now_to_string(Now3)}
            ]},
            ale:yaws(content, "application/json", json:encode(Data));

        NumUsers ->
            receive
                {chat, NumUsers2, Msg, Now3} ->
                    Data = {struct, [
                        {numUsers, NumUsers2},
                        {msgs, {array, [Msg]}},
                        {now, h_app:now_to_string(Now3)}
                    ]},
                    ale:yaws(content, "application/json", json:encode(Data))
            after ?TIMEOUT ->
                s_chat:unsubscribe(self()),
                Data = {struct, [{numUsers, NumUsers}]},
                ale:yaws(content, "application/json", json:encode(Data))
            end
    end.

create() ->
    case ale:params(msg) of
        undefined -> ok;
        Msg       -> s_chat:publish(Msg)
    end.
