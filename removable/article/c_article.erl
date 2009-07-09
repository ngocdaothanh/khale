-module(c_article).

-compile(export_all).

create() ->
    "create".

update(Id) ->
    "update" ++ Id.
