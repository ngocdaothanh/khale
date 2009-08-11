-module(h_application).

-compile(export_all).

-include("sticky.hrl").

region(Region) ->
    Blocks = m_block:region(Region),
    {'ul', [{class, region}], [h_block:render(B) || B <- Blocks]}.

title_in_feed() ->
    Site = ale:app(site),
    yaws_api:htmlize(Site#site.name).

title_in_head() ->
    Site = ale:app(site),
    Name = yaws_api:htmlize(Site#site.name),
    case ale:app(title_in_head) of
        undefined -> Name;
        Title     -> [Name, " - ", yaws_api:htmlize(Title)]
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
more(Items, UlClass, ItemRenderFun, MorePathFun) ->
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

    [
        {ul, LUlClass, [ItemRenderFun(Item) || Item <- Items]},
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

render_timestamp(CreatedAt) -> render_timestamp(CreatedAt, CreatedAt).

render_timestamp({Date1, Time1}, {Date2, Time2}) ->
    case {Date1 == Date2, Time1 == Time2} of
        {true, true}  -> ?TFB(":month/:day, :year", date_binding(Date1));
        {true, false} -> ?TFB("Updated :month/:day, :year", date_binding(Date2));

        {false, _} ->
            [
                ?TFB(":month/:day, :year", date_binding(Date1)),
                " (",
                ?TFB("updated :month/:day, :year", date_binding(Date2)),
                ")"
            ]
    end.

date_binding({Y, M, D}) ->
    [Y2, M2, D2] = [integer_to_list(I) || I <- [Y, M, D]],
    [{year, Y2}, {month, M2}, {day, D2}].

%-------------------------------------------------------------------------------

%% Erlang only has string:join/2 to join only string.
join([], _Separator) -> [];
join([H | T], Separator) ->
    Injected = lists:foldr(
        fun(E, Acc) ->
            [Separator, E | Acc]
        end,
        [],
        T
    ),
    [H | Injected].
