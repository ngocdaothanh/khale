-module(c_event).

-compile(export_all).

routes() -> [
    get,    "events/new",     new,
    get,    "events/Id",      show,
    post,   "events",         create,
    get,    "events/Id/edit", edit,
    put,    "events/Id",      update,
    delete, "events/Id",      delete
].

show(_Arg, Id) ->
    "show" ++ Id.

new(_Arg) ->
    "new".

create(_Arg) ->
    "create".

edit(_Arg, Id) ->
    "edit" ++ Id.

update(_Arg, Id) ->
    "update" ++ Id.

delete(_Arg, Id) ->
    "delete" ++ Id.
