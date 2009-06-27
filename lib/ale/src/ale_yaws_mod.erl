-module(ale_yaws_mod).

-compile(export_all).

-include_lib("yaws/include/yaws.hrl").
-include_lib("yaws/include/yaws_api.hrl").

%-------------------------------------------------------------------------------
% Called by Yaws as configured in yaws.conf

%% Modifies the current SC to set docroot and xtra_docroots to the list of all
%% public directories in the application.
%%
%% Called after Yaws has loaded.
start(SC) ->
    {ok, GC, [SCs]} = yaws_api:getconf(),  % The 3rd element is array of array

    % docroot is undefined at this moment (see yaws.conf)
    % SC2 = SC#sconf{xtra_docroots = public_dirs()} does not work because Yaws
    % does not check public_dirs if it sees that docroot is undefined
    SC2 = SC#sconf{docroot = "public", xtra_docroots = public_dirs()},

    % 10: position of servername in the sconf record, see yaws.hrl
    SCs2 = lists:keyreplace(SC#sconf.servername, 10, SCs, SC2),

    yaws_api:setconf(GC, [SCs2]),

    controller_application:start(SC2).

out(Arg) ->
    RestMethod = rest_method(Arg),
    Uri = Arg#arg.appmoddata,
    try ale_routes:route_uri(RestMethod, Uri) of
        % Give Yaws a chance to server static file
        % If Yaws cannot find a file at the Uri, out404 below will be called
        no_controller_and_action -> {page, Arg#arg.server_path};

        _Ignored -> ale:build_response()
    catch
        % This is more convenient than Yaws' errormod_crash
        Type : Reason ->
            error_logger:error_report([
                {type, Type}, {reason, Reason},
                {trace, erlang:get_stacktrace()}
            ]),
            controller_application:error_500(Type, Reason),
            ale:build_response()
    end.

out404(Arg, _GC, _SC) ->
    Uri = Arg#arg.appmoddata,
    controller_application:error_404(Uri),
    ale:build_response().

%-------------------------------------------------------------------------------

public_dirs() ->
    public_dirs(filelib:wildcard("./*"), []).

public_dirs(Dirs, Acc) ->
    lists:foldl(
        fun(Dir, Acc2) ->
            case filelib:is_dir(Dir) of
                false -> Acc2;

                true ->
                    Basename = filename:basename(Dir),
                    case Basename of
                        "public" -> [Dir | Acc];
                        _ -> public_dirs(filelib:wildcard(Dir ++ "/*"), Acc2)
                    end
            end
        end,
        Acc,
        Dirs
    ).

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

