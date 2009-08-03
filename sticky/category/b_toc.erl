-module(b_toc).

-compile(export_all).

-include("sticky.hrl").

%% All TOCs should be discussed at /about.
render(_Id, _Config) ->
    Site = ale:app(site),
    Body = Site#site.toc,
    {?T("Links"), Body}.
