-module(ale_yaws_mod).

-compile(export_all).

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

%-------------------------------------------------------------------------------
% Called by Yaws as configured in yaws.conf

%% appmods
out(Arg) ->
    RestMethod = rest_method(Arg),
    Uri = Arg#arg.appmoddata,
    try ale_routes:route_uri(RestMethod, Uri) of
        % Give Yaws a chance to server static file
        % If Yaws cannot find a file at the Uri, out404 below will be called
        no_controller_and_action -> {page, Arg#arg.server_path};

        _Ignored -> build_response()
    catch
        % This is more convenient than Yaws' errormod_crash
        Type : Reason ->
            error_logger:error_report([
                {type, Type}, {reason, Reason},
                {trace, erlang:get_stacktrace()}
            ]),
            controller_application:error_500(Type, Reason),
            build_response()
    end.

%% errormod_404
out404(Arg, _GC, _SC) ->
    Uri = Arg#arg.appmoddata,
    controller_application:error_404(Uri),
    build_response().

%-------------------------------------------------------------------------------

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

build_response() ->
    Status = case get(status) of
        undefined -> 200;
        Status0 -> Status0
    end,

    ContentType = case get(content_type) of
        undefined -> "text/html";
        ContentType0 -> ContentType0
    end,

    Content = case get(content) of
        undefined -> "text/html";
        Content0 -> Content0
    end,

    [{status, Status}, {content, ContentType, Content}].
