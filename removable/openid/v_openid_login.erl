-module(v_openid_login).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Login with OpenID")),
    [
        {p, [], ?T("OpenID is... Register at...")},
        {p, [], ?T("Input your OpenID and click Login button. You will be redirected to... then you will be redirected back to this site.")},

        {form, [{method, post}, {action, ale:url_for(openid, login)}], [
            {span, [{class, label}], ?T("OpenID")},
            {input, [{type, text}, {name, openid}]},
            {input, [{type, submit}, {value, ?T("Login")}]}
        ]}
    ].
