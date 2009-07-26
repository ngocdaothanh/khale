-module(c_qa).

-routes([
    get,    "/qas/new",      new,
    get,    "/qas/:id",      show,
    post,   "/qas",          create,
    get,    "/qas/:id/edit", edit,
    put,    "/qas/:id",      update,
    delete, "/qas/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(qa, m_qa:find(Id)).
