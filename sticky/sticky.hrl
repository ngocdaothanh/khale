-include_lib("ale/include/ale.hrl").

-include_lib("stdlib/include/qlc.hrl").

-record(about, {id, short, long}).

% indexed_data is indexed for fast lookup
-record(user, {id, type, indexed_data, extra_data}).

-record(category, {id, name, unix_name, position}).
-record(category_content, {category_id, content_id}).

-record(content, {id, user_id, type, title, data, created_at, updated_at, sticky = false, views = 0, ip}).
-record(content_version, {id, content_id, user_id, title, data, created_at, ip}).

-record(comment, {id, user_id, content_id, body, created_at, updated_at, ip}).

-record(block, {id, type, data, region, position}).

-define(MNESIA_WAIT_FOR_TABLES_TIMEOUT, 20000).
-define(TABLE_OPTIONS, [{disc_copies, [node()]}]).
