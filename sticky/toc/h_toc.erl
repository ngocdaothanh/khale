-module(h_toc).

-compile(export_all).

-include("sticky.hrl").

name() -> yaws_api:htmlize(?T("Table of Content")).

title(Content) ->
    Category = m_toc:category(Content),
    CategoryName = Category#category.name,
    yaws_api:htmlize(?TF("Table of Contents of Category ~s", CategoryName)).
