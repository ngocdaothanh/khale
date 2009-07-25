-module(m_block).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(block, record_info(fields, block)).

all(Region) ->
    [
        #block{id = 1, type = html},
        #block{id = 2, type = titles},
        #block{id = 3, type = current_user},
        #block{id = 4, type = categories},
        #block{id = 5, type = about}
    ].
