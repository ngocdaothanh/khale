-module(m_content).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(content,         record_info(fields, content)),
    m_helper:create_table(content_version, record_info(fields, content_version)).

%% Returns the list of content modules. Content modules should define
%% -content_module(true).
modules() ->
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
    ).

types() ->
    lists:map(
        fun(Module) ->
            [$m, $_ | Base] = atom_to_list(Module),
            list_to_atom(Base)
        end,
        modules()
    ).

type_strings() -> [atom_to_list(T) || T <- types()].

type_to_module(Type) ->
    list_to_atom("m_" ++ atom_to_list(Type)).

all() ->
    Stickies = all(true),
    NonStickies = all(false),
    Stickies ++ NonStickies.

%% Sticky: bool()
all(Sticky) ->
    Q1 = qlc:q([C || C <- mnesia:table(content), C#content.sticky == Sticky]),
    Q2 = qlc:keysort(1 + 7, Q1, [{order, ascending}]),    % sort by updated_at
    m_helper:do(Q2).

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
