-module(m_helper).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    mnesia:create_schema([node()]),
    mnesia:start(),
    create_table(counter, [table, current_id]),    % for next_id/1
    apply_to_all("^m_.*\.beam$", migrate),
    mnesia:stop().

%% Called by c_application on application start.
start(Nodes) ->
    mnesia:start(),
    replicate(Nodes).

%% If there is no directory "mnesia", replicates one from other nodes.
replicate(Nodes) ->
    % See: http://erlanganswers.com/web/mcedemo/mnesia/DistributedHelloWorld.html

    % Merge tables of this node with those of other nodes
    mnesia:change_config(extra_db_nodes, Nodes),

    % This line will create directory "mnesia" if none exists
    mnesia:change_table_copy_type(schema, node (), disc_copies),

    % Replicate
    lists:foreach(
        fun(Table) ->
            io:format("Replicate ~p...~n", [Table]),
            mnesia:add_table_copy(Table, node(), disc_copies)
        end,
        mnesia:system_info(tables)
    ).

%-------------------------------------------------------------------------------

%% Other modules should call this function to create tables on migration.
create_table(Name, Attributes) ->
    create_table(Name, Attributes, set).

create_table(Name, Attributes, Type) ->
    mnesia:create_table(Name, [{attributes, Attributes}, {type, Type} | ?TABLE_OPTIONS]).

do(Q) ->
    {atomic, Val} = mnesia:transaction(fun() -> qlc:e(Q) end),
    Val.

next_id(Table) ->
    mnesia:dirty_update_counter(counter, Table, 1).

%-------------------------------------------------------------------------------

apply_to_all(BeamPattern, Function) ->
    filelib:fold_files(?ALE_ROOT ++ "/ebin", BeamPattern, false,
        fun(ModelFile, Acc) ->
            Base = filename:basename(ModelFile, ".beam"),
            Module = list_to_atom(Base),
            code:ensure_loaded(Module),
            case (Base =/= "m_helper") andalso erlang:function_exported(Module, Function, 0) of
                true  ->
                    io:format("~s...~n", [Base]),
                    [{Module, Module:Function()} | Acc];

                false -> Acc
            end
        end,
        []
    ).
