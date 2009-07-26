-module(h_application).

-compile(export_all).

-include("sticky.hrl").

region(Region) ->
    Blocks = m_block:all(Region),
    {'ul', [{class, region}, {id, Region}], [h_block:render(B) || B <- Blocks]}.

title_in_head() ->
    Title = ale:app(title),
    case Title of
        undefined -> "Khale";
        _         -> ["Khale - ", yaws_api:htmlize(Title)]
    end.

title_in_body() ->
    Title = ale:app(title),
    case Title of
        undefined -> "";
        _         -> {h3, [], yaws_api:htmlize(Title)}
    end.

flash() ->
    case ale:flash() of
        undefined -> "";
        Flash     -> {'div', [{class, flash}], Flash}
    end.

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
