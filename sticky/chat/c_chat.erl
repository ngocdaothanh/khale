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
    {NameMsgList1, PrevNow3} = s_chat:msgs(PrevNow2),

    % Return immediately if there is message
    {NameMsgList2, PrevNow4} = case NameMsgList1 of
        [] ->
            s_chat:subscribe(self()),
            receive
                {chat, Name, Msg, Now} -> {NameMsgList1 ++ [{Name, Msg}], Now};
                _                      -> {NameMsgList1, PrevNow3}
            after s_chat:timeout()     -> {NameMsgList1, PrevNow3}
            end;

        _ -> {NameMsgList1, PrevNow3}
    end,

    case NameMsgList2 of
        [] -> ale:view(undefined);
        _  -> ale:app(name_msg_list_and_prev_now, {NameMsgList2, PrevNow4})
    end.

create() ->
    ale:view(undefined),
    case ale:params(msg) of
        undefined -> ok;

        Msg ->
            Name = ?T("Noname"),
            s_chat:chat(Name, Msg)
    end.
