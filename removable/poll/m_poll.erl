-module(m_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

migrate() -> m_helper:create_table(poll, record_info(fields, poll)).

content() -> [{public_creatable, true}].

create(Question, Detail, Choices, UserId, Ip, Tags) ->
    Id = m_helper:next_id(content),
    CreatedAt = erlang:universaltime(),
    Votes  = lists:duplicate(length(Choices), 0),
    Voters = [],
    Poll = #poll{
        id = Id,
        question = Question, detail = Detail, choices = Choices,
        votes = Votes, voters = Voters,
        user_id = UserId, ip = Ip,
        created_at = CreatedAt
    },
    m_content:save(Poll, Tags).

find(Id) ->
    Q = qlc:q([R || R <- mnesia:table(poll), R#poll.id == Id]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

%-------------------------------------------------------------------------------

sphinx_id_title_body_list() ->
    Q = qlc:q([
        {R#poll.id, R#poll.question, R#poll.detail} ||
        R <- mnesia:table(poll)
    ]),
    m_helper:do(Q).
