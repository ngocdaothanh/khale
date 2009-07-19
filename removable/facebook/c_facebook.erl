-module(c_facebook).

-routes([
    get, "/facebook", login
]).

-compile(export_all).

-include("sticky.hrl").

%% Facebook Connect:
%% 1. The user clicks "Login with Facebook", a popup window opens.
%% 2. The user inputs email and password. Facebook athenticates and sets cookie.
%% 3. The popup window closes and the current window redirects here.
%% 4. This action checks cookie as instructed at:
%%    http://wiki.developers.facebook.com/index.php/Verifying_The_Signature
login() ->
    Arg       = ale:arg(),
    ApiKey    = proplists:get_value("facebook_key", Arg#arg.opaque),
    AppSecret = proplists:get_value("facebook_secret", Arg#arg.opaque),

    case uid(ApiKey, AppSecret, Arg) of
        undefined -> ok;

        Uid ->
            User = m_facebook:login(Uid),
            ale:session(user, User)
    end,

    ale:view_module(undefined),
    ale:yaws(redirect_local, "/").

%-------------------------------------------------------------------------------

%% http://wiki.developers.facebook.com/index.php/Verifying_The_Signature
uid(ApiKey, AppSecret, Arg) ->
    % Cookie is just a string "Key=Value; Key=Value"
    Cookie = lists:flatten((Arg#arg.headers)#headers.cookie),

    L1 = string:tokens(Cookie, "; "),

    SPrefix = ApiKey ++ "=",
    FPrefix = ApiKey ++ "_",
    Start = length(SPrefix) + 1,

    {L2, S, Id} = lists:foldl(
        fun(KV, {L3, S2, Id2}) ->
            case lists:prefix(SPrefix, KV) of
                true ->
                    S3 = string:substr(KV, Start),
                    {L3, S3, Id2};

                false ->
                    case lists:prefix(FPrefix, KV) of
                        true ->
                            KV2 = string:substr(KV, Start),
                            Id3 = case KV2 of
                                "user=" ++ Id4 -> Id4;
                                _              -> Id2
                            end,
                            {[KV2 | L3], S2, Id3};

                        false -> {L3, S2, Id2}
                    end
            end
        end,
        {[], undefined, undefined},
        L1
    ),

    case (S == undefined) orelse (Id == undefined) of
        true -> undefined;

        false ->
            L3 = lists:sort(L2),

            % For long data, crypto:md5 is faster than erlang:md5
            case ale:md5_hex(crypto, [L3, AppSecret]) of
                S -> Id;
                _ -> undefined
            end
    end.
