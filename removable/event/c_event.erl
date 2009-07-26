-module(c_event).

-routes([
    get,    "/events/new",      new,
    get,    "/events/:id",      show,
    post,   "/events",          create,
    get,    "/events/:id/edit", edit,
    put,    "/events/:id",      update,
    delete, "/events/:id",      delete
]).

-compile(export_all).

create() ->
    "create".

update(Id) ->
    "update" ++ Id.
