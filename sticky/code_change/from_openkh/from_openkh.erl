%%% This module converts data and files from OpenKH 0.5 to Khale. It uses
%%% epgsql (http://bitbucket.org/will/epgsql/) to connect to PostgreSQL.
%%%
%%% This is semiautomatic.
%%%
%%% It may be optimal to keep strings as binaries.
%%%
%%% Code in this moudle is ugly and slow, but it's OK because this module is
%%% only used once to convert OpenKH to Khale.

-module(from_openkh).

-compile(export_all).

-include("sticky.hrl").
-include("../../../removable/article/article.hrl").
-include("../../../removable/qa/qa.hrl").

code_change() ->
    Host     = "localhost",
    Username = "postgres",
    Password = "postgres",
    Database = "openkh05",
    Port     = 5432,

    {ok, C} = pgsql:connect(Host, Username, Password, [{database, Database}, {port, Port}]),

    migrate_users(C),

    migrate_site(C),

    migrate_catagories(C),

    migrate_articles(C),
    migrate_forums(C),
    migrate_polls(C),

    migrate_comments(C),

    pgsql:close(C).

%% The user id conversion will be stored in the process dictionary.
migrate_users(C) ->
    % Only migrate OpenID users
    {ok, _, Rows} = pgsql:equery(C, "SELECT id, openid, email FROM users WHERE openid NOT LIKE 'id.cntt.tv%' ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {PgId, ShortenOpenId, Email} = Row,
            ShortenOpenId2 = binary_to_list(ShortenOpenId),
            Email2 = case Email of
                null -> undefined;
                _    -> binary_to_list(Email)
            end,

            OpenId = "http://" ++ ShortenOpenId2,
            R = m_openid:login(OpenId, Email2, ShortenOpenId2),

            MnId = R#user.id,
            user_id_pg_to_mn(PgId, MnId)
        end,
        Rows
    ).

migrate_site(_C) ->
    Site = #site{
        id = 1,
        name = "cntt.tv", subtitle = "Blog cộng đồng về CNTT",
        about = "Short introduction"
    },
    mnesia:transaction(fun() -> mnesia:write(Site) end).

migrate_catagories(C) ->
    {ok, _, Rows} = pgsql:equery(C, "SELECT id, name FROM categories"),
    lists:foreach(
        fun(Row) ->
            {PgId, Name} = Row,
            Name2 = binary_to_list(Name),
            Tag = m_tag:create(Name2),

            category_id_pg_to_mn(PgId, Tag#tag.id)
        end,
        Rows
    ).

%% First author + last version
migrate_articles(C) ->
    {ok, _, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Article' ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {Id, Views, ThreadUpdatedAt} = Row,

            ThreadUpdatedAt2 = timestamp_pg_to_mn(ThreadUpdatedAt),

            {UserId, Ip, Title, Abstract, Body, CreatedAt, UpdatedAt} = article_first_author_last_version(C, Id),

            ContentId = m_helper:next_id(content),
            content_id_pg_to_mn(Id, {article, ContentId}),
            Article = #article{
                id = ContentId,
                title = Title, abstract = Abstract, body = Body,
                user_id = UserId, ip = Ip,
                created_at = CreatedAt,
                updated_at = UpdatedAt,
                views = Views
            },
            Thread = #thread{content_type_id = {article, ContentId}, updated_at = ThreadUpdatedAt2},
            mnesia:transaction(fun() ->
                mnesia:write(Article),
                mnesia:write(Thread)
            end),

            tag(C, Id)
        end,
        Rows
    ).

%% Returns {UserId, Ip, Title, Abstract, Body, CreatedAt, UpdatedAt}.
article_first_author_last_version(C, NodeId) ->
    {ok, _, [{UserId, CreatedAt}]} = pgsql:equery(C, "SELECT user_id, created_at FROM node_versions WHERE node_id = " ++ integer_to_list(NodeId) ++ " ORDER BY version LIMIT 1"),
    CreatedAt2 = timestamp_pg_to_mn(CreatedAt),
    UserId2    = user_id_pg_to_mn(UserId),

    {ok, _, [Row]} = pgsql:equery(C, "SELECT id, title, _body, ip, created_at FROM node_versions WHERE node_id = " ++ integer_to_list(NodeId) ++ " ORDER BY version DESC LIMIT 1"),
    {AVId, Title, Yaml, Ip, UpdatedAt} = Row,
    Title2     = binary_to_list(Title),
    Ip2        = ip_pg_to_mn(Ip),
    UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

    File = "/tmp/khale/article/" ++ integer_to_list(NodeId) ++ "_" ++ integer_to_list(AVId) ++ ".yml",
    %file:write_file(File, Yaml),

    {ok, BAbstract} = file:read_file(File ++ ".abstract.txt"),
    {ok, BBody}     = file:read_file(File ++ ".body.txt"),
    Abstract = binary_to_list(BAbstract),
    Body     = binary_to_list(BBody),

    {UserId2, Ip2, Title2, Abstract, Body, CreatedAt2, UpdatedAt2}.

migrate_forums(C) ->
    {ok, _, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Forum' ORDER BY id"),
    lists:map(
        fun(Row) ->
            {NodeId, Views, UpdatedAt} = Row,
            {ok, _, [Row2]} = pgsql:equery(C, "SELECT title, user_id, ip, created_at FROM node_versions WHERE node_id = " ++ integer_to_list(NodeId) ++ " ORDER BY version"),
            {Title, UserId, Ip, CreatedAt} = Row2,

            Question   = binary_to_list(Title),
            Ip2        = ip_pg_to_mn(Ip),
            CreatedAt2 = timestamp_pg_to_mn(CreatedAt),
            UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

            ContentId = m_helper:next_id(content),
            content_id_pg_to_mn(NodeId, {qa, ContentId}),

            UserId2 = user_id_pg_to_mn(UserId),
            Qa = #qa{
                id = ContentId,
                question = Question,
                user_id = UserId2, ip = Ip2,
                created_at = CreatedAt2, updated_at = CreatedAt2, views = Views
            },
            Thread = #thread{content_type_id = {qa, ContentId}, updated_at = UpdatedAt2},
            mnesia:transaction(fun() ->
                mnesia:write(Qa),
                mnesia:write(Thread)
            end),

            tag(C, NodeId)
        end,
        Rows
    ).

migrate_polls(C) ->
    {ok, _, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Poll' ORDER BY id").

migrate_comments(C) ->
    {ok, _, Rows} = pgsql:equery(C, "SELECT node_id, message, user_id, ip, created_at, updated_at FROM comments ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {PgNodeId, Message, PgUserId, Ip, CreatedAt, UpdatedAt} = Row,
            case content_id_pg_to_mn(PgNodeId) of
                undefined -> ok;

                {ContentType, ContentId} ->
                    Body       = binary_to_list(Message),
                    UserId     = user_id_pg_to_mn(PgUserId),
                    Ip2        = ip_pg_to_mn(Ip),
                    CreatedAt2 = timestamp_pg_to_mn(CreatedAt),
                    UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

                    % Special processing for forum: if this is the first discussion
                    % for a forum, then move it to the corresponding qa's detail
                    Content = m_content:find(ContentType, ContentId),
                    case (ContentType == qa) andalso (Content#qa.detail == undefined) of
                        true ->
                            Content2 = Content#qa{detail = Body},
                            mnesia:transaction(fun() -> mnesia:write(Content2) end);

                        false ->
                            Id = m_helper:next_id(discussion),
                            Discussion = #discussion{
                                id = Id,
                                content_type = ContentType, content_id = ContentId,
                                body = Body,
                                user_id = UserId, ip = Ip2,
                                created_at = CreatedAt2, updated_at = UpdatedAt2
                            },
                            mnesia:transaction(fun() -> mnesia:write(Discussion) end)
                    end
            end
        end,
        Rows
    ).

tag(C, NodeId) ->
    {Type, Id} = content_id_pg_to_mn(NodeId),
    {ok, _, Rows} = pgsql:equery(C, "SELECT category_id FROM categories_nodes WHERE node_id = " ++ integer_to_list(NodeId)),
    lists:foreach(
        fun({CategoryId}) ->
            TagId = category_id_pg_to_mn(CategoryId),
            TC = #tag_content{tag_id = TagId, content_type = Type, content_id = Id},
            mnesia:transaction(fun() -> mnesia:write(TC) end)
        end,
        Rows
    ).

%-------------------------------------------------------------------------------

timestamp_pg_to_mn(Timestamp) ->
    {Date, {H, M, S}} = Timestamp,  % S is a float
    {Date, {H, M, round(S)}}.

user_id_pg_to_mn(PgId, MnId) -> put({user_id, PgId}, MnId).
user_id_pg_to_mn(PgId) ->
    case get({user_id, PgId}) of
        undefined -> 1;  % User deleted?
        X         -> X
    end.

category_id_pg_to_mn(PgId, MnId) -> put({category_id, PgId}, MnId).
category_id_pg_to_mn(PgId) -> get({category_id, PgId}).

content_id_pg_to_mn(PgId, {MnType, MnId}) -> put({content_id, PgId}, {MnType, MnId}).
content_id_pg_to_mn(PgId) ->
    case get({content_id, PgId}) of
        undefined ->
            io:format("Content has not been migrated or has been deleted: ~p~n", [PgId]),
            undefined;

        X -> X
    end.

%% "a.b.b.d" -> {a, b, c, d}
ip_pg_to_mn(PgIp) ->
    String = binary_to_list(PgIp),
    Tokens = string:tokens(String, "."),
    [N1, N2, N3, N4] = lists:map(
        fun(S) -> list_to_integer(string:strip(S, right, 10)) end,  % WTF, there is \n
        Tokens
    ),
    {N1, N2, N3, N4}.
