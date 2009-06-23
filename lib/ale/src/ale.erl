-module(ale).

-compile(export_all).

-include_lib("yaws/include/yaws_api.hrl").

box(Str) ->
    {'div',[{class,"box"}],
     {pre,[],Str}}.

out(Arg) ->
    io:format("~p~n", [(Arg#arg.req)#http_request.method]),
    Uri = Arg#arg.appmoddata,
    case map_runner:run_uri(get, Uri) of
        no_map -> {page, Uri};  % May be static data
        Body   -> [{content, "text/html", Body}]
    end.

out404(_Arg, _GC, _SC) ->
    [{status, 404}, {content, "text/html", "404"}].
