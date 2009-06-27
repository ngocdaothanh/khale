-module(ale).

-compile(export_all).

sync() -> make:all([load]).

%-------------------------------------------------------------------------------
%%% See RETURN VALUES from out/1 of http://yaws.hyber.org/yman.yaws?page=yaws_api
%%%
%%% Each request has its own processing process. An applications will put return
%%% values directly to the process dictionary using y/2, 3, 4 functions. These
%%% values will be collected at build_response/0.

yk(Key) -> {ale_yaws, Key}.

%% Puts into the current process dictionary a value to be sent to Yaws.
%%
%% Ex: ale:y(html, "Hello World")
y(Key, Value)                  -> put(yk(Key), Value).
y(Key, Value1, Value2)         -> put(yk(Key), {Value1, Value2}).
y(Key, Value1, Value2, Value3) -> put(yk(Key), {Value1, Value2, Value3}).

%% Gets from the current　process dictionary a value that is intended to be sent to Yaws.
y(Key) -> get(yk(Key)).

%% Builds response to be sent to Yaws from things in the current process
%% dictionary.
build_response() ->
    lists:foldr(
        fun
            ({{ale_yaws, Key}, {Value1, Value2, Value3}}, Acc) -> [{Key, Value1, Value2, Value3} | Acc];
            ({{ale_yaws, Key}, {Value1, Value2        }}, Acc) -> [{Key, Value1, Value2        } | Acc];
            ({{ale_yaws, Key},  Value                  }, Acc) -> [{Key, Value}                  | Acc];
            (_                                          , Acc) ->                                  Acc
        end,
        [],
        get()
    ).

%-------------------------------------------------------------------------------

ak(Key) -> {ale_application, Key}.

%% Puts into the current process dictionary　a value that could be share among
%% the application filters, actions, helpers, views etc. along the request
%% processing process.
a(Key, Value) -> put(ak(Key), Value).

a(Key) -> get(ak(Key)).

%% Builds the environment (proplist) from things in the current process
%% dictionary to be used when rendering ehtml or ejs templates.
build_template_environment() ->
    lists:foldr(
        fun
            ({{ale_application, Key}, Value}, Acc) -> [{Key, Value} | Acc];
            (_                              , Acc) ->                 Acc
        end,
        [],
        get()
    ).

%-------------------------------------------------------------------------------
