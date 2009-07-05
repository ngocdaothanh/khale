-module(m_qa).
-content_module(true).

-compile(export_all).

-include("sticky.hrl").

name() ->
    ?T("Q/A").

instruction() ->
    ?T("A Q/A is a collection of questions, answers and discussions. Select if you want to ask something and would like everyone to freely answer or discuss.").

create(UserId, CategoryIds, Title, AbstractAndQuestion) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Qa = #content{
        id = Id, user_id = UserId, type = qa,
        title = Title, data = AbstractAndQuestion,
        created_at = CreatedAt, updated_at = CreatedAt
    },
    m_content:save(Qa, CategoryIds).

fake() ->
    lists:foreach(
        fun(Args) -> apply(?MODULE, create, Args) end,
        [
            [1, [1, 2], "What is Erlang?", "I want to study Erlang. Can you tell me about it?"],
            [2, [2, 3], "What is Ruby?",   "I want to study Ruby. Can you tell me about it?"],
            [2, [1, 3], "What is Java?",   "I want to study Java. Can you tell me about it?"]
        ]
    ).
