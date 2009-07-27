-module(h_content).

-compile(export_all).

h_module(Content) ->
    Type = element(1, Content),
    list_to_atom([$h, $_ | atom_to_list(Type)]).

title(Content) ->
    HModule = h_module(Content),
    HModule:title(Content).
