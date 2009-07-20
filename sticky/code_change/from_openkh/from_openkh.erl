%%% This module converts data and files from OpenKH 0.5 to Khale. It uses
%%% epgsql (http://bitbucket.org/will/epgsql/) to connect to PostgreSQL.
%%%
%%% This is semiautomatic.

-module(from_openkh).

-compile(export_all).

-include("sticky.hrl").
-include("../../removable/article/article.hrl").

code_change() ->
    Host     = "localhost",
    Username = "postgres",
    Password = "postgres",
    Database = "openkh05",
    Port     = 5432,

    {ok, C} = pgsql:connect(Host, Username, Password, [{database, Database}, {port, Port}]),

    migrate_users(C),
    migrate_catagories(C),
    migrate_articles(C),

    pgsql:close(C).

%% The user id conversion will be stored in the process dictionary.
migrate_users(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, openid, email FROM users WHERE openid NOT LIKE 'id.cntt.tv%' ORDER BY id"),
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

migrate_catagories(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT name, path, position FROM categories ORDER BY position"),
    lists:foreach(
        fun(Row) ->
            {Name, Path, Position} = Row,
            Name2     = binary_to_list(Name),
            UnixName  = binary_to_list(Path),
            m_category:create(Name2, UnixName, Position)
        end,
        Rows
    ).

migrate_articles(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Article' ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {Id, Views, UpdatedAt} = Row,
            UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

            ContentId = m_helper:next_id(content),
            V = migrate_article_versions(C, Id, ContentId),

            R = #content{
                id = ContentId, user_id = V#article_version.user_id,
                type = article, title = V#article_version.title,
                data = {V#article_version.abstract, V#article_version.body},
                created_at = V#article_version.created_at,
                updated_at = UpdatedAt2, sticky = 0, views = Views,
                ip = V#article_version.ip
            },

            mnesia:transaction(fun() -> mnesia:write(R) end)
        end,
        Rows
    ).

%% Returns the last article version.
migrate_article_versions(C, NodeId, ContentId) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, title, _body, user_id, ip, created_at FROM node_versions WHERE node_id = " ++ integer_to_list(NodeId) ++ " ORDER BY version"),
    Vs = lists:map(
        fun(Row) ->
            {AVId, Title, Yaml, UserId, Ip, CreatedAt} = Row,
            Title2     = binary_to_list(Title),
            UserId2    = user_id_pg_to_mn(UserId),
            Ip2        = binary_to_list(Ip),
            CreatedAt2 = timestamp_pg_to_mn(CreatedAt),

            File = "/tmp/khale/article/" ++ integer_to_list(NodeId) ++ "_" ++ integer_to_list(AVId) ++ ".yml",
            %file:write_file(, Yaml),

            {ok, BAbstract} = file:read_file(File ++ ".abstract.txt"),
            {ok, BBody}     = file:read_file(File ++ ".body.txt"),
            Abstract = binary_to_list(BAbstract),
            Body     = binary_to_list(BBody),

            Id = m_helper:next_id(article_version),
            V = #article_version{
                id = Id, content_id = ContentId, user_id = UserId2, title = Title2,
                abstract = Abstract, body = Body, created_at = CreatedAt2, ip = Ip2
            },

            mnesia:transaction(fun() -> mnesia:write(V) end),
            V
        end,
        Rows
    ),
    lists:last(Vs).

timestamp_pg_to_mn(Timestamp) ->
    {Date, {H, M, S}} = Timestamp,
    {Date, {H, M, round(S)}}.

user_id_pg_to_mn(PgId, MnId) -> put({user_id, PgId}, MnId).
    
user_id_pg_to_mn(PgId) ->
    case get({user_id, PgId}) of
        undefined -> 1;
        X         -> X
    end.
