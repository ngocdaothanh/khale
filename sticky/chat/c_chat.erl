-module(c_chat).

-routes([
    get,  "/chats/:prev_now", index,
    post, "/chats",           create
]).

-compile(export_all).

-include("sticky.hrl").

before_action(_) ->
    ale:layout_module(undefined),
    false.

index() ->
    PrevNow1 = ale:params(prev_now),
    PrevNow2 = h_application:string_to_now(PrevNow1),
    {Msgs1, PrevNow3} = s_chat:msgs(PrevNow2),

    % Return immediately if there is message
    {Msgs2, PrevNow4} = case Msgs1 of
        [] ->
            s_chat:subscribe(self()),
            receive
                {chat, Msg, Now} -> {Msgs1 ++ [Msg], Now};
                _                      -> {Msgs1, PrevNow3}
            after s_chat:timeout()     -> {Msgs1, PrevNow3}
            end;

        _ -> {Msgs1, PrevNow3}
    end,

    case Msgs2 of
        [] -> ale:view(undefined);
        _  -> ale:app(msgs_prev_now, {Msgs2, PrevNow4})
    end.

create() ->
    ale:view(undefined),
    case ale:params(msg) of
        undefined -> ok;

        Msg -> s_chat:chat(Msg)
    end.
