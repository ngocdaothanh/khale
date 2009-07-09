-module(c_event).

-compile(export_all).

create() ->
    "create".

update(Id) ->
    "update" ++ Id.
