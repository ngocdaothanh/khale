-module(controller_articles).

-compile(export_all).

routes() -> [
    get,    "articles",         index,
    get,    "articles/Id",      show,
    get,    "articles/new",     new,
    post,   "articles",         create,
    get,    "articles/Id/edit", edit,
    put,    "articles/Id",      update,
    delete, "articles/Id",      delete
].

index(_Arg) ->
    "index".

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
