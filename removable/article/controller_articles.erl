-module(controller_articles).

-compile(export_all).

map() -> [
	get,    "articles",         index,
	get,    "articles/Id",      show,
	get,    "articles/new",     new,
	post,   "articles",         create,
	get,    "articles/Id/edit", edit,
	put,    "articles/Id",      update,
	delete, "articles/Id",      delete
].

before_filter() -> [
	user, ensure_login, except, [index, show]
].

index() ->
	"index".

show(Id) ->
	"show" ++ Id.

new() ->
	"new".

create() ->
	"create".

edit(Id) ->
	"edit" ++ Id.

update(Id) ->
	"update" ++ Id.

delete(Id) ->
	"delete" ++ Id.
