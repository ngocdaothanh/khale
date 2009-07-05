-module(b_category_list).

-compile(export_all).

-include("sticky.hrl").

render(_Id, _Config) ->
    % Categories = m_category:all(),
    % Body = #list{body = lists:map(
    %     fun(C) ->
    %         #listitem{body = #link{text = C#category.name, url = "/" ++ C#category.unix_name}}
    %     end,
    %     Categories)
    % },
    % {?T("Categories"), Body}.
    [].
