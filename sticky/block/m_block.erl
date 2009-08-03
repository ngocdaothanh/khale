-module(m_block).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(block, record_info(fields, block)).

all(Region) ->
    [
        #block{type = html},
        #block{type = search},
        #block{type = chat},
        #block{type = titles},
        #block{type = current_user},
        #block{type = categories},
        #block{type = toc},
        #block{type = about}
    ].
