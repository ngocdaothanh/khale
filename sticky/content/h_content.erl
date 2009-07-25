-module(h_content).

-compile(export_all).

title(Content) ->
    HelperModule = h_module(Content),
    HelperModule:title(Content).

h_module(Content) ->
    Type = m_content:type(Content),
    list_to_atom("h_" ++ atom_to_list(Type)).

timestamp_to_string({{Y, M, D}, {H, Mi, S}}) ->
    string:join([integer_to_list(N) || N <- [Y, M, D, H, Mi, S]], "-").

string_to_timestamp(String) ->
    [Y, M, D, H, Mi, S] = lists:map(
        fun(E) -> list_to_integer(E) end,
        string:tokens(String, "-")
    ),
    {{Y, M, D}, {H, Mi, S}}.
