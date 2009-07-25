-module(p_qa_new).

-compile(export_all).

-include("sticky.hrl").

render() ->
    ale:app(title, ?T("Create new Q/A")),
    [
        {p, [], ?T("A Q/A is a collection of question, answers and discussions. Create a Q/A if you want to ask something and would like everyone to freely answer or discuss.")},

        {span, [{class, label}], ?T("Question")},
        {input, [{type, text}, {name, question}]}
    ].
