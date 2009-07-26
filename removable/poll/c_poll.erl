-module(c_poll).

-routes([
    get,    "/polls/new",      new,
    get,    "/polls/:id",      show,
    post,   "/polls",          create,
    get,    "/polls/:id/edit", edit,
    put,    "/polls/:id",      update,
    delete, "/polls/:id",      delete
]).

-compile(export_all).

-include("sticky.hrl").

show() ->
    Id = list_to_integer(ale:params(id)),
    ale:app(poll, m_poll:find(Id)).
