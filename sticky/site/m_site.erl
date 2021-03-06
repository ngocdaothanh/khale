-module(m_site).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(site, record_info(fields, site)).

find(_) ->
    Q = qlc:q([R || R <- mnesia:table(site)]),
    case m_helper:do(Q) of
        [R] -> R;

        _ ->
            #site{
                name     = "Site Name",
                subtitle = "A site about...",
                about    = "<p>Short introduction about this site...</p>"
            }
    end.
