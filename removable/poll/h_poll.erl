-module(h_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

render_name() -> yaws_api:htmlize(?T("Poll")).

render_title(Poll) -> yaws_api:htmlize(Poll#poll.question).

render_preview(Poll) -> render_poll(Poll, false).

render_poll(Poll, Votable) ->
    User = m_user:find(Poll#poll.user_id),

    Choices = case Votable of
        false ->
            {ol, [],
                [{li, [], yaws_api:htmlize(C)} || C <- Poll#poll.choices]
            };

        true ->
            {_, Lis} = lists:foldr(
                fun(C, {Index, Acc}) ->
                    Li = {li, [], [
                        {input, [{type, radio}, {name, choice}, {value, integer_to_list(Index)}]}, " ",
                        yaws_api:htmlize(C)
                    ]},
                    {Index - 1, [Li | Acc]}
                end,
                {length(Poll#poll.choices), []},
                Poll#poll.choices
            ),

            Id = Poll#poll.id,
            ale:app_add_js(ale:ff("p_poll_vote.js", [Id, Id])),
            [
                {ol, [], Lis},
                {input, [{id, vote}, {type, submit}, {class, button}, {value, ?T("Vote")}]}, {br}
            ]
    end,

    Sum = lists:sum(Poll#poll.votes),
    Img = case Sum of
        0 -> "";

        _ ->
            Votes = Poll#poll.votes,

            NumbersS1 = lists:map(
                fun(N) -> integer_to_list(N) end,
                Votes
            ),
            Data = string:join(NumbersS1, ","),

            Numbers = lists:seq(1, length(Votes)),
            NumbersS2 = lists:map(
                fun(N) -> integer_to_list(N) ++ " (" ++ integer_to_list(lists:nth(N, Votes)) ++ ")" end,
                Numbers
            ),
            Labels = string:join(NumbersS2, "|"),
            {img, [{src, ["http://chart.apis.google.com/chart?cht=p3&chd=t:", Data, "&chs=400x200&chl=", Labels]}]}
    end,

    [
        render_header(User, Poll),
        Choices,
        Img
    ].

render_header(User, Poll) ->
    [
        h_user:render(User, [
            h_tag:render_tags(poll, Poll#poll.id),
            h_application:render_timestamp(Poll#poll.created_at)
        ])
    ].

%% Returns ID or IP of the current user.
user_id() ->
    case ale:session(user) of
        undefined -> ale:ip();
        User      -> User#user.id
    end.
