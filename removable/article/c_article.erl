-module(c_article).

-compile(export_all).

create(_Arg) ->
    "create".

update(_Arg, Id) ->
    "update" ++ Id.
