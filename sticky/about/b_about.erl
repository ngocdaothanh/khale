-module(b_about).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Data) ->
    About = m_about:find(),
    Body = [
        About#about.short,

        {ul, [], [
            {li, [], {a, [{href, ale:url_for(user, index)}], ?T("User list")}},
            {li, [], {a, [{href, ale:url_for(about, about)}], ?T("Comments")}}
        ]}
    ],
    {"About", Body}.
