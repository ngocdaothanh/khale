-module(m_about).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(about, record_info(fields, about)).

find(_) ->
    Q = qlc:q([A || A <- mnesia:table(about)]),
    case m_helper:do(Q) of
        [About] -> About;

        _ ->
            DefaultShort = ?T("<p>Short introduction about this site...</p>"),
            DefaultLong  = ?T("<p>Long introduction about this site...</p>"),
            #about{short = DefaultShort, long = DefaultLong}
    end.
