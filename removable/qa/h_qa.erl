-module(h_qa).

-compile(export_all).

-include("sticky.hrl").
-include("qa.hrl").

render_name() -> yaws_api:htmlize(?T("Q/A")).

render_title(Qa) -> yaws_api:htmlize(Qa#qa.question).

render_preview(Qa) -> Qa#qa.detail.
