-module(v_openid_login).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Login with OpenID")),
    [
        {p, [], ?T("In your <a href=\"http://en.wikipedia.org/wiki/OpenID\">OpenID</a> Persona, you need to specify email and full name. Email is used to display <a href=\"http://gravatar.com\">Gravatar</a>.")},

        {form, [{method, post}, {action, ale:path(openid, login)}], [
            {span, [{class, label}], ?T("OpenID")},
            {input, [{type, text}, {name, openid}]},
            {input, [{type, submit}, {value, ?T("Login")}]}
        ]},

        {p, [], ?T("Input your OpenID and click Login button. You will be redirected to your OpenID site to login, then you will be redirected back to this site.")}
    ].
