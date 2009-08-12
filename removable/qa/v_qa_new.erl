-module(v_qa_new).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render() ->
    Title = ?T("Create new Q/A"),
    ale:app(title_in_head, Title),
    ale:app(title_in_body, Title),
    [
        {p, [], ?T("A Q/A is a collection of question, answers and discussions. Create a Q/A if you want to ask something and would like everyone to freely answer or discuss.")},
        p_qa_form:render(post, ale:path(create), #qa{question = "", detail = ""}, [])
    ].
