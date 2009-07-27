-include_lib("ale/include/ale.hrl").
-include_lib("stdlib/include/qlc.hrl").

-define(MNESIA_WAIT_FOR_TABLES_TIMEOUT, 20000).
-define(TABLE_OPTIONS, [{disc_copies, [node()]}]).
-define(ITEMS_PER_PAGE, 10).

% indexed_data is indexed for fast lookup
-record(user, {id, type, admin = false, indexed_data, extra_data}).

% user_id: ID of the admin who last editted
-record(about, {short, long, user_id, ip, updated_at}).

% user_id: ID of the admin who last editted TOC
-record(category, {id, name, unix_name, position, toc, user_id, ip}).

-record(category_content, {category_id, content_type, content_id}).

-record(discussion, {id, content_type, content_id, body, user_id, ip, created_at, updated_at}).

% Used to sort contents, updated_at id updated when:
% * Content is updated
% * Discussion is created, updated
%
% content_type_id: {type, id}
-record(thread, {content_type_id, updated_at}).

-record(block, {id, type, data, region, position}).
