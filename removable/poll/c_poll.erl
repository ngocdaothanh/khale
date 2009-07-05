-module(c_poll).

-compile(export_all).

-include("sticky.hrl").

routes() -> [
    get,    "polls/new",     new,
    get,    "polls/Id",      show,
    post,   "polls",         create,
    get,    "polls/Id/edit", edit,
    put,    "polls/Id",      update,
    delete, "polls/Id",      delete
].

new() ->
    v_poll_new:render().
