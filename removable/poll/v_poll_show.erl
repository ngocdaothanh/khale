-module(v_poll_show).

-compile(export_all).

-include("poll.hrl").

render() ->
    ale:app(title_in_body, h_poll:render_name()),

    Poll = ale:app(poll),
    TitleInHead = h_poll:render_title(Poll),
    ale:app(title_in_head, TitleInHead),

    User = m_user:find(Poll#poll.user_id),
    Detail = case Poll#poll.detail of
        undefined -> "";
        X         -> X
    end,

    Choices = {ol, [],
        [{li, [], yaws_api:htmlize(C)} || C <- Poll#poll.choices]
    },

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
        {h1, [], TitleInHead},
        h_user:render(User),
        {'div', [], Detail},
        Choices,
        Img,
        h_discussion:render_all(poll, Poll#poll.id)
    ].


