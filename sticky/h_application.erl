-module(h_application).

-compile(export_all).

-include("sticky.hrl").

region(Region) ->
    Blocks = m_block:all(Region),
    {'ul', [{class, region}, {id, Region}], [h_block:render(B) || B <- Blocks]}.

title_in_head() ->
    case ale:app(title_in_head) of
        undefined -> "Khale";
        Title     -> ["Khale - ", yaws_api:htmlize(Title)]
    end.

title_in_body() ->
    case ale:app(title_in_body) of
        undefined -> "";
        Title     -> {h3, [], yaws_api:htmlize(Title)}
    end.

flash() ->
    case ale:flash() of
        undefined -> "";
        Flash     -> {'div', [{class, flash}], Flash}
    end.

%-------------------------------------------------------------------------------

%% Cycle is not supported because it makes "More..." difficult to implement.
more(Items, UlClass, LiClass, ItemRenderFun, MorePathFun) ->
    More = case length(Items) < ?ITEMS_PER_PAGE of
        true -> [];

        false ->
            LastItem = lists:last(Items),
            {a, [{onclick, "return more(this)"}, {href, MorePathFun(LastItem)}], ?T("More...")}
    end,

    LUlClass = case UlClass of
        undefined -> [];
        _         -> [{class, UlClass}]
    end,
    LLiClass = case LiClass of
        undefined -> [];
        _         -> [{class, LiClass}]
    end,

    [
        {ul, LUlClass, [{li, LLiClass, ItemRenderFun(Item)} || Item <- Items]},
        More
    ].

%-------------------------------------------------------------------------------

timestamp_to_string({{Y, M, D}, {H, Mi, S}}) ->
    string:join([integer_to_list(N) || N <- [Y, M, D, H, Mi, S]], "-").

string_to_timestamp(String) ->
    [Y, M, D, H, Mi, S] = lists:map(
        fun(E) -> list_to_integer(E) end,
        string:tokens(String, "-")
    ),
    {{Y, M, D}, {H, Mi, S}}.

now_to_string({Mega, S, Micro}) ->
    string:join([integer_to_list(N) || N <- [Mega, S, Micro]], "-").

string_to_now(String) ->
    [Mega, S, Micro] = lists:map(
        fun(E) -> list_to_integer(E) end,
        string:tokens(String, "-")
    ),
    {Mega, S, Micro}.
