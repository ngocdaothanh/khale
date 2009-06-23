-module(ale).

-compile(export_all).

-include_lib("yaws/include/yaws_api.hrl").

box(Str) ->
    {'div',[{class,"box"}],
     {pre,[],Str}}.

out(Arg) ->
    RestMethod = rest_method(Arg),
    Uri = Arg#arg.appmoddata,
    case map_runner:run_uri(RestMethod, Uri) of
        no_map -> {page, Uri};  % May be static data
        Body   -> [{content, "text/html", Body}]
    end.

out404(_Arg, _GC, _SC) ->
    [{status, 404}, {content, "text/html", "404"}].

%% 'GET'                       -> get
%% 'POST'                      -> post
%% 'POST' & _method = "put"    -> put
%% 'POST' & _method = "delete" -> delete
rest_method(Arg) ->
    Method = (Arg#arg.req)#http_request.method,
    case Method of
        'GET' -> get;

        'POST' ->
            case yaws_api:postvar(Arg, "_method") of
                undefined      -> post;
                {ok, "put"}    -> put;
                {ok, "delete"} -> delete
            end
    end.
