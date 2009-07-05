-module(h_theme).

-compile(export_all).

region(Region) ->
    Blocks = m_block:all(Region),
    {'ul', [{class, region}, {id, Region}], [p_block:render(B) || B <- Blocks]}.
