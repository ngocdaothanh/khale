-include_lib("ale/include/ale.hrl").
-include_lib("stdlib/include/qlc.hrl").

-define(MNESIA_WAIT_FOR_TABLES_TIMEOUT, 20000).
-define(TABLE_OPTIONS, [{disc_copies, [node()]}]).
-define(ITEMS_PER_PAGE, 10).

-record(about, {id, short, long}).

% indexed_data is indexed for fast lookup
-record(user, {id, type, admin = false, indexed_data, extra_data}).

-record(category, {id, name, unix_name, position, toc_id}).
-record(category_content, {category_id, content_id}).

-record(content, {id, user_id, ip, data, created_at, updated_at, sticky = 0, views = 0, thread_updated_at}).

-record(comment, {id, user_id, ip, content_id, body, created_at, updated_at}).

-record(block, {id, type, data, region, position}).

-record(toc_data, {body}).
