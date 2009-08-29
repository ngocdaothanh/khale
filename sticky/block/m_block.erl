-module(m_block).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(block, record_info(fields, block)).

region(left1) ->
    [
        #block{type = search},
        #block{type = current_user},
        #block{type = titles}
    ];

region(right1) ->
    [
        #block{type = chat},
        #block{type = html}
    ];

region(left2) ->
    [
        #block{type = about}
    ];

region(right2) ->
    [
        #block{type = tags}
    ].
