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
    migrate_catagories(C),
    migrate_tocs(C),
    migrate_articles(C),
    migrate_forums(C),
    migrate_comments(C),

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

migrate_tocs(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Article' ORDER BY id"),
    ok.

migrate_articles(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT id, views, updated_at FROM nodes WHERE type LIKE 'Article' ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {Id, Views, UpdatedAt} = Row,
            UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

            ContentId = m_helper:next_id(content),
            content_id_pg_to_mn(Id, ContentId),

            V = migrate_article_versions(C, Id, ContentId),
            ArticleData = #article{
                title    = V#article_version.title,
                abstract = V#article_version.abstract,
                body     = V#article_version.body
            },
            R = #content{
                id = ContentId,
                user_id = V#article_version.user_id, ip = V#article_version.ip,
                data = ArticleData,
                created_at = V#article_version.created_at,
                updated_at = V#article_version.created_at,
                sticky = 0, views = Views,
                thread_updated_at = UpdatedAt2
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
            Ip2        = ip_pg_to_mn(Ip),
            CreatedAt2 = timestamp_pg_to_mn(CreatedAt),

            File = "/tmp/khale/article/" ++ integer_to_list(NodeId) ++ "_" ++ integer_to_list(AVId) ++ ".yml",
            %file:write_file(File, Yaml),

            {ok, BAbstract} = file:read_file(File ++ ".abstract.txt"),
            {ok, BBody}     = file:read_file(File ++ ".body.txt"),
            Abstract = binary_to_list(BAbstract),
            Body     = binary_to_list(BBody),

            Id = m_helper:next_id(article_version),
            V = #article_version{
                id = Id, content_id = ContentId,
                user_id = UserId2, ip = Ip2,
                title = Title2, abstract = Abstract, body = Body,
                created_at = CreatedAt2
            },
            mnesia:transaction(fun() -> mnesia:write(V) end),
            V
        end,
        Rows
    ),
    lists:last(Vs).

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
            content_id_pg_to_mn(NodeId, ContentId),

            UserId2 = user_id_pg_to_mn(UserId),
            Qa = #content{
                id = ContentId,
                user_id = UserId2, ip = Ip2,
                data = #qa{question = Question},
                created_at = CreatedAt2,
                updated_at = CreatedAt2, sticky = 0, views = Views,
                thread_updated_at = UpdatedAt2
            },
            mnesia:transaction(fun() -> mnesia:write(Qa) end)
        end,
        Rows
    ).

migrate_comments(C) ->
    {ok, _Columns, Rows} = pgsql:equery(C, "SELECT node_id, message, user_id, ip, created_at, updated_at FROM comments ORDER BY id"),
    lists:foreach(
        fun(Row) ->
            {PgNodeId, Message, PgUserId, Ip, CreatedAt, UpdatedAt} = Row,
            case content_id_pg_to_mn(PgNodeId) of
                undefined -> ok;

                ContentId ->
                    Body       = binary_to_list(Message),
                    UserId     = user_id_pg_to_mn(PgUserId),
                    Ip2        = ip_pg_to_mn(Ip),
                    CreatedAt2 = timestamp_pg_to_mn(CreatedAt),
                    UpdatedAt2 = timestamp_pg_to_mn(UpdatedAt),

                    % Special processing for forum: if this is the first comment
                    % for a forum, then move it to the corresponding qa's detail
                    Content = m_content:find(ContentId),
                    Data = Content#content.data,
                    case (element(1, Data) == qa) andalso (Data#qa.detail == undefined) of
                        true ->
                            Data2 = Data#qa{detail = Body},
                            Content2 = Content#content{data = Data2},
                            mnesia:transaction(fun() -> mnesia:write(Content2) end);

                        false ->
                            Id = m_helper:next_id(comment),
                            Comment = #comment{
                                id = Id,
                                user_id = UserId, ip = Ip2,
                                content_id = ContentId,
                                body = Body, created_at = CreatedAt2,
                                updated_at = UpdatedAt2
                            },
                            mnesia:transaction(fun() -> mnesia:write(Comment) end)
                    end
            end
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

content_id_pg_to_mn(PgId, MnId) -> put({content_id, PgId}, MnId).

content_id_pg_to_mn(PgId) ->
    case get({content_id, PgId}) of
        undefined ->
            io:format("Content was not migrated: ~p~n", [PgId]),
            undefined;

        X -> X
    end.

ip_pg_to_mn(PgIp) ->
    String = binary_to_list(PgIp),
    Tokens = string:tokens(String, "."),
    [N1, N2, N3, N4] = lists:map(
        fun(S) -> list_to_integer(string:strip(S, right, 10)) end,  % WTF, there is \n
        Tokens
    ),
    {N1, N2, N3, N4}.
