-module(v_poll_show).

-compile(export_all).

-include("poll.hrl").

render() ->
    ale:app(title_in_body, h_poll:render_name()),

    Poll = ale:app(poll),
    TitleInHead = h_poll:render_title(Poll),
    ale:app(title_in_head, TitleInHead),

    [
        {h1, [], TitleInHead},
        h_poll:render_poll(Poll, m_poll:votable(Poll, h_poll:user_id())),
        h_discussion:render_all(poll, Poll#poll.id)
    ].
