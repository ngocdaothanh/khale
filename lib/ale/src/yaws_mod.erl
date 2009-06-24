-module(yaws_mod).

-compile(export_all).

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

%-------------------------------------------------------------------------------
% Called by Yaws as configured in yaws.conf

%% start_mod
start(_SC) ->
    supervisor:start_link(?MODULE, []).

init([]) ->
    RestartStrategy = one_for_one,
    MaxRestarts = 1000,
    MaxSecondsBetweenRestarts = 3600,
    SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
    HerlManager = {herml_manager, {herml_manager, start_link, [?MODULE, "."]}, permanent, brutal_kill, worker,     [herml_manager]},
    {ok, {SupFlags, [HerlManager]}}.

%% appmods
out(Arg) ->
    RestMethod = rest_method(Arg),
    Uri = Arg#arg.appmoddata,
    case routes:route_uri(RestMethod, Uri) of
        % Give Yaws a chance to server static file
        % If Yaws cannot find a file at the Uri, out404 below will be called
        no_controller_and_action -> {page, Arg#arg.server_path};

        _Ignored -> build_response()
    end.

%% errormod_404
out404(_Arg, _GC, _SC) ->
    controller_application:error_404(),
    build_response().

%% errormod_crash
crashmsg(_Arg, _SC, _Str) ->
    controller_application:error_500(),
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
