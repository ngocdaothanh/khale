-module(m_content).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(thread, record_info(fields, thread)).

%% Returns the list of content modules. Content modules should define
%% content() -> [Option].
%%
%% Option:
%% * noncreatable
modules() ->
    % FIXME: save to SC's ets
    ale:cache("khale_content_modules", fun() ->
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

type_strings() -> [atom_to_list(T) || T <- types()].

type(Content) -> element(1, Content).

m_module(ContentType) -> list_to_atom([$m, $_ | atom_to_list(ContentType)]).

find(ContentType, ContentId) ->
    MModule = m_module(ContentType),
    MModule:find(ContentId).

%% Returns nonsticky contents sorted reveresely by thread_updated_at.
more(_UnixName, PrevThreadUpdatedAt) ->
    {atomic, Contents} = mnesia:transaction(fun() ->
        Q1 = case PrevThreadUpdatedAt of
            undefined -> qlc:q([R || R <- mnesia:table(thread)]);
            _         -> qlc:q([R || R <- mnesia:table(thread), R#thread.updated_at < PrevThreadUpdatedAt])
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
