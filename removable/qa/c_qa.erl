-module(c_qa).

-compile(export_all).

-include("sticky.hrl").

routes() -> [
    get,    "qas/new",     new,
    get,    "qas/Id",      show,
    post,   "qas",         create,
    get,    "qas/Id/edit", edit,
    put,    "qas/Id",      update,
    delete, "qas/Id",      delete
].

new() ->
    v_qa_new:render().
