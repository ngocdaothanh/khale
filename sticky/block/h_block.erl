-module(h_block).

-compile(export_all).

-include("sticky.hrl").

render(Block) ->
    Module = list_to_atom("b_" ++ atom_to_list(Block#block.type)),
    {Title, Body} = Module:render(Block#block.id, Block#block.data),
    {'li', [{class, "block"}], [
        {h5, [{class, "title"}], Title},
        {'div', [{class, "body"}], Body}
    ]}.
