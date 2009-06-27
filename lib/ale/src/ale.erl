-module(ale).

-compile(export_all).

sync() ->
    make:all([load]).
