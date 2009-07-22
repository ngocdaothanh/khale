-module(m_content).

-compile(export_all).

-include("sticky.hrl").

migrate() -> m_helper:create_table(content, record_info(fields, content)).

%% Returns the list of content modules. Content modules should define
%% -content_module(true).
modules() ->
    ale:cache("khale_content_modules", fun() ->
        filelib:fold_files(?ALE_ROOT ++ "/ebin", "^m_.*\.beam$", false,
            fun(ModelFile, Acc) ->
                Base = filename:basename(ModelFile, ".beam"),
                Module = list_to_atom(Base),
                code:ensure_loaded(Module),
                Attributes = Module:module_info(attributes),
                case proplists:get_value(content_module, Attributes) of
                    [true] -> [Module | Acc];
                    _      -> Acc
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

type_to_module(Type) -> list_to_atom("m_" ++ atom_to_list(Type)).

more(_UnixName, LastContentUpdatedAt) ->
    Stickies = case LastContentUpdatedAt of
        undefined -> stickies();
        _         -> []
    end,
    Stickies ++ nonstickies(LastContentUpdatedAt).

%% Returns sticky contents sorted reveresely by sticky strength.
stickies() ->
    Q1 = qlc:q([C || C <- mnesia:table(content), C#content.sticky > 0]),
    Q2 = qlc:keysort(1 + 8, Q1, [{order, descending}]),
    m_helper:do(Q2).

%% Returns nonsticky contents sorted reveresely by updated_at.
nonstickies(LastContentUpdatedAt) ->
    {atomic, Contents} = mnesia:transaction(fun() ->
        Q1 = case LastContentUpdatedAt of
            undefined -> qlc:q([R || R <- mnesia:table(content), R#content.sticky == 0]);
            _         -> qlc:q([R || R <- mnesia:table(content), R#content.sticky == 0, R#content.updated_at < LastContentUpdatedAt])
        end,
        Q2 = qlc:keysort(1 + 7, Q1, [{order, descending}]),
        QC = qlc:cursor(Q2),
        Contents2 = qlc:next_answers(QC, ?ITEMS_PER_PAGE),
        qlc:delete_cursor(QC),
        Contents2
    end),
    Contents.

save(Content, CategoryIds) ->
    mnesia:transaction(fun() ->
        mnesia:write(Content),
        lists:foreach(
            fun(CategoryId) ->
                CC = #category_content{
                    category_id = CategoryId,
                    content_id  = Content#content.id
                },
                mnesia:write(CC)
            end,
            CategoryIds
        )
    end).

find(Id) ->
    Q = qlc:q([C || C <- mnesia:table(content), C#content.id == Id]),
    [Content] = m_helper:do(Q),
    Content.
