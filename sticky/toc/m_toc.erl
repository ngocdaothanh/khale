-module(m_toc).

-compile(export_all).

-include("sticky.hrl").

content() -> [{public_creatable, false}].

%% Returns the category for a TOC.
category(Content) ->
    TocId = Content#content.id,
    Q = qlc:q([R || R <- mnesia:table(category), R#category.toc_id == TocId]),
    [R] = m_helper:do(Q),
    R.
