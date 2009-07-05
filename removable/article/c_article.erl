-module(c_article).

-compile(export_all).

routes() -> [
    get,    "articles/new",     new,
    get,    "articles/Id",      show,
    post,   "articles",         create,
    get,    "articles/Id/edit", edit,
    put,    "articles/Id",      update,
    delete, "articles/Id",      delete
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
