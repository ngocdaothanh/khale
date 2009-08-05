-module(m_block).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(block, record_info(fields, block)).

region(left_column) ->
    [
        #block{type = search},
        #block{type = about},
        #block{type = current_user},
        #block{type = tags}
    ];

region(right_column) ->
    [
        #block{type = chat},
        #block{type = titles},
        #block{type = html}
    ].
