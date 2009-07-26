-module(h_content).

-compile(export_all).

h_module(Content) ->
    Type = element(1, Content),
    list_to_atom([$h, $_ | atom_to_list(Type)]).

title(Content) ->
    HModule = h_module(Content),
    HModule:title(Content).

timestamp_to_string({{Y, M, D}, {H, Mi, S}}) ->
    string:join([integer_to_list(N) || N <- [Y, M, D, H, Mi, S]], "-").

string_to_timestamp(String) ->
    [Y, M, D, H, Mi, S] = lists:map(
        fun(E) -> list_to_integer(E) end,
        string:tokens(String, "-")
    ),
    {{Y, M, D}, {H, Mi, S}}.
