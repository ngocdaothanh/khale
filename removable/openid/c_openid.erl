%%% Please install http://github.com/pib/erlangopenid
%%% http://openid.net/specs/openid-simple-registration-extension-1_0.html

-module(c_openid).

-routes([
    get,  "/openid",        login,
    post, "/openid",        login,
    get,  "/openid_return", return
]).

-compile(export_all).

-include("sticky.hrl").

login() ->
    case ale:method() of
        get -> ok;

        post ->
            OpenId = ale:params(openid),
            inets:start(),
            ReturnUrl = "http://localhost:3000/openid_return",  %ale:path(return),
            RemoteUrl = openid:start_authentication(OpenId, ReturnUrl),
            RemoteUrl2 = RemoteUrl ++ "&openid.sreg.optional=email,fullname",
            ale:yaws(redirect, RemoteUrl2),
            ale:view(undefined)
    end.

return() ->
    Arg = ale:arg(),
    Params = yaws_api:parse_query(Arg),
    case openid:finish_authentication(Params) of
        {ok, OpenId} ->
            OpenId2 = shorten(OpenId),
            Email = proplists:get_value("openid.sreg.email", Params),
            User = m_openid:login(OpenId2, Email),
            c_user:login(User);

        _ ->
            ale:flash(?T("Could not login with the provided OpenID.")),
            ale:yaws(redirect_local, ale:path(login)),
            ale:view(undefined)
    end.

%% Remove http(s):// and trailing slash.
shorten(OpenId) ->
    WithoutScheme = case OpenId of
        "http://"  ++ Rest -> Rest;
        "https://" ++ Rest -> Rest;
        _                  -> OpenId
    end,
    string:strip(WithoutScheme, right, $/).
