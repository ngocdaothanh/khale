-module(m_content).

-compile(export_all).

-include("sticky.hrl").

-define(MAX_DOCS_PER_TYPE, 100000).

migrate() -> m_helper:create_table(thread, record_info(fields, thread)).

%% Returns the list of content modules. Content modules should define
%% content() -> [Option].
%%
%% Option:
%% * noncreatable
modules() ->
    ale:conf(app, "content_modules", fun() ->
        filelib:fold_files(?ALE_ROOT ++ "/ebin", "^m_.*\.beam$", false,
            fun(ModelFile, Acc) ->
                Base = filename:basename(ModelFile, ".beam"),
                Module = list_to_atom(Base),
                code:ensure_loaded(Module),
                case erlang:function_exported(Module, content, 0) of
                    true  -> [Module | Acc];
                    false -> Acc
                end
            end,
            []
        )
    end).

types() ->
    lists:map(
        fun(Module) ->
            [$m, $_ | Base] = atom_to_list(Module),
            list_to_atom(Base)
        end,
        modules()
    ).

m_module(Type) -> list_to_atom([$m, $_ | atom_to_list(Type)]).

type_strings() -> [atom_to_list(T) || T <- types()].

type(Content) -> element(1, Content).

find(ContentType, ContentId) ->
    MModule = m_module(ContentType),
    MModule:find(ContentId).

%% Returns nonsticky contents sorted reveresely by thread_updated_at.
more(TagName, ThreadUpdatedAt) ->
    {atomic, Contents} = mnesia:transaction(fun() ->
        Q1 = case m_tag:find_by_name(TagName) of
            undefined ->
                case ThreadUpdatedAt of
                    undefined -> qlc:q([R || R <- mnesia:table(thread)]);
                    _         -> qlc:q([R || R <- mnesia:table(thread), R#thread.updated_at < ThreadUpdatedAt])
                end;

            Tag ->
                case ThreadUpdatedAt of
                    undefined ->
                        qlc:q([T ||
                            T <- mnesia:table(thread), CT <- mnesia:table(content_tag),
                            T#thread.content_type_id == {CT#content_tag.content_type, CT#content_tag.content_id},
                            CT#content_tag.tag_id == Tag#tag.id
                        ]);

                    _ ->
                        qlc:q([T ||
                            T <- mnesia:table(thread), CT <- mnesia:table(content_tag),
                            T#thread.content_type_id == {CT#content_tag.content_type, CT#content_tag.content_id},
                            CT#content_tag.tag_id == Tag#tag.id,
                            T#thread.updated_at < ThreadUpdatedAt
                        ])
                end
        end,
        Q2 = qlc:keysort(3, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Threads = qlc:next_answers(QC, ?ITEMS_PER_PAGE),
        qlc:delete_cursor(QC),

        lists:map(
            fun(Thread) ->
                {ContentType, ContentId} = Thread#thread.content_type_id,
                MModule = m_module(ContentType),
                MModule:find(ContentId)
            end,
            Threads
        )
    end),
    Contents.

thread_updated_at(Content) ->
    ContentType = element(1, Content),
    ContentId   = element(2, Content),
    Q = qlc:q([R || R <- mnesia:table(thread), R#thread.content_type_id == {ContentType, ContentId}]),
    [Thread] = m_helper:do(Q),
    Thread#thread.updated_at.

%-------------------------------------------------------------------------------

%% See sphinx.conf.
%%
%% All contents are merged into only one index. Because IDs must be unique, they
%% are segmented into fixed-size segments specified by MAX_DOCS_PER_TYPE.
%%
%% For example:
%% event 1 -> 100001
%% poll  1 -> 200001
sphinx_xml() ->
    Tables = types(),
    mnesia:start(),
    mnesia:wait_for_tables(Tables, infinity),

    % http://erlang.org/doc/apps/xmerl/xmerl_ug.html

    {_, Docs} = lists:foldl(
        fun(Type, {TypeIndex, Acc}) ->
            MModule = m_module(Type),
            IdTitleBodyList = MModule:sphinx_id_title_body_list(),

            IdBase = ?MAX_DOCS_PER_TYPE*TypeIndex,

            Acc2 = lists:foldl(
                fun({Id, Title, Body}, Acc3) ->
                    SegmentedId = IdBase + Id,

                    Discussions = m_discussion:more(Type, Id, undefined, all_remaining),
                    Discussions2 = lists:foldl(
                        fun(D, Acc4) -> [Acc4, " ", D#discussion.body] end,
                        "",
                        Discussions
                    ),

                    Doc = {'sphinx:document', [{id, integer_to_list(SegmentedId)}], [
                        {title,       [Title]},
                        {body,        [Body]},
                        {discussions, [Discussions2]}
                    ]},
                    [Doc | Acc3]
                end,
                Acc,
                IdTitleBodyList
            ),

            {TypeIndex + 1, Acc2}
        end,
        {0, []},
        Tables
    ),

    Schema = {'sphinx:schema', [], [
        {'sphinx:field', [{name, "title"}],       []},
        {'sphinx:field', [{name, "body"}],        []},
        {'sphinx:field', [{name, "discussions"}], []}
    ]},
    Content = {'sphinx:docset', [], [Schema | Docs]},
    Docset = #xmlElement{name = 'sphinx:docset', content = [Content]},
    io:format(xmerl:export_simple([Docset], xmerl_xml)).

sphinx_find(SegmentedId) ->
    Modules = modules(),
    Index   = SegmentedId div ?MAX_DOCS_PER_TYPE,
    Module  = lists:nth(Index + 1, Modules),
    Id      = SegmentedId rem ?MAX_DOCS_PER_TYPE,
    Module:find(Id).
