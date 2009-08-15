-module(h_poll).

-compile(export_all).

-include("sticky.hrl").
-include("poll.hrl").

render_name() -> yaws_api:htmlize(?T("Poll")).

render_title(Poll) -> yaws_api:htmlize(Poll#poll.question).

render_preview(Poll) ->
    User = m_user:find(Poll#poll.user_id),

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
