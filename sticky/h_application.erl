-module(h_application).

-compile(export_all).

-include("sticky.hrl").

region(Region) ->
    Blocks = m_block:region(Region),
    {'ul', [{class, region}], [h_block:render(B) || B <- Blocks]}.

title_in_head() ->
    Site = ale:app(site),
    Name = yaws_api:htmlize(Site#site.name),
    case ale:app(title_in_head) of
        undefined -> Name;
        Title     -> [Name, " - ", yaws_api:htmlize(Title)]
    end.

title_in_feed() ->
    Site = ale:app(site),
    yaws_api:htmlize(Site#site.name).

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

render_mathcha() ->
    {Question, EncryptedAnswer} = ale:mathcha(),
    [
        {span, [{class, label}], Question},
        {input, [{type, hidden}, {name, encrypted_answer}, {value, EncryptedAnswer}]},
        {input, [{type, text}, {class, "textbox quarter"}, {name, answer}]}, {br}
    ].

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

user_id() ->
    case ale:session(user) of
        undefined -> undefined;
        User      -> User#user.id
    end.

%% Thing must be a record in the form {Type, Id, UserId, Ip, ...}.
editable(Thing) ->
    case element(3, Thing) of
        undefined -> ale:ip() == element(4, Thing);

        UserId ->
            case ale:session(user) of
                undefined -> false;
                User      -> UserId == User#user.id
            end
    end.

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
        {true, true}  -> ?TFB(":month/:day/:year", date_binding(Date1));
        {true, false} -> ?TFB("Updated :month/:day/:year", date_binding(Date2));

        {false, _} ->
            [
                ?TFB(":month/:day/:year", date_binding(Date1)),
                " (",
                ?TFB("updated :month/:day/:year", date_binding(Date2)),
                ")"
            ]
    end.

date_binding({Y, M, D}) ->
    [Y2, M2, D2] = [integer_to_list(I) || I <- [Y, M, D]],
    [{year, Y2}, {month, M2}, {day, D2}].

%% Converts localized string date to Erlang's {Y, M, D} format. Tokens must be
%% separated by "/"
%%
%% Ex: 30/12/2009 -> {2009, 12, 30}
parse_date(String) ->
    try
        [I1, I2, I3] = [list_to_integer(S) || S <- string:tokens(String, "/")],
        case ?T(":month/:day/:year") of
            ":month/:day/:year" -> {I3, I1, I2};
            ":month/:year/:day" -> {I2, I1, I3};
            ":day/:month/:year" -> {I3, I2, I1};
            ":day/:year/:month" -> {I2, I3, I1};
            ":year/:day/:month" -> {I1, I3, I2};
            ":year/:month/:day" -> {I1, I2, I3}
        end
    catch
        _ : _ -> undefined
    end.

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
