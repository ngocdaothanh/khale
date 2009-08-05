-module(b_search).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    Keyword = case ale:params(keyword) of
        undefined -> "";
        X         -> X
    end,
    Body = {input, [{id, search_keyword}, {type, text}, {class, textbox}, {value, yaws_api:htmlize(Keyword)}]},
    {?T("Search"), Body}.
