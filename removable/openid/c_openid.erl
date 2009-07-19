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
            try
                inets:start(),
                ReturnUrl = "http://localhost:3000/openid_return",  %ale:path(return),
                RemoteUrl = openid:start_authentication(OpenId, ReturnUrl),
                RemoteUrl2 = RemoteUrl ++ "&openid.sreg.required=email,fullname",
                ale:yaws(redirect, RemoteUrl2),
                ale:view(undefined)
            catch
                _ : _ -> ale:flash(?T("Could not login with the provided OpenID."))
            end
    end.

return() ->
    Arg = ale:arg(),
    Params = yaws_api:parse_query(Arg),
    case openid:finish_authentication(Params) of
        {ok, OpenId} ->
            Email    = proplists:get_value("openid.sreg.email", Params),
            Fullname = proplists:get_value("openid.sreg.fullname", Params),
            User     = m_openid:login(OpenId, Email, Fullname),
            c_user:login(User);

        _ ->
            ale:flash(?T("Could not login with the provided OpenID.")),
            ale:yaws(redirect_local, ale:path(login)),
            ale:view(undefined)
    end.
