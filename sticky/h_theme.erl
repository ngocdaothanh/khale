-module(h_theme).

-compile(export_all).

-include("sticky.hrl").

region(Region) ->
    Blocks = m_block:all(Region),
    {'ul', [{class, region}, {id, Region}], [p_block:render(B) || B <- Blocks]}.

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
