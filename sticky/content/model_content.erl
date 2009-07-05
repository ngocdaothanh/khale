-module(model_content).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    model_helper:create_table(content,         record_info(fields, content)),
    model_helper:create_table(content_version, record_info(fields, content_version)).

instructions() ->
    model_helper:apply_to_all("^model_content_.*\.beam$", instruction).

all() ->
    Stickies = all(true),
    NonStickies = all(false),
    Stickies ++ NonStickies.

%% Sticky: bool()
all(Sticky) ->
    Q1 = qlc:q([C || C <- mnesia:table(content), C#content.sticky == Sticky]),
    Q2 = qlc:keysort(1 + 6, Q1, [{order, ascending}]),    % sort by updated_at
    bleck_db:do(Q2).

save(Content, CategoryIds) ->
    mnesia:transaction(fun() ->
        mnesia:write(Content),
        lists:foreach(
            fun(CategoryId) ->
                CC = #category_content{category_id = CategoryId, content_id = Content#content.id},
                mnesia:write(CC)
            end,
            CategoryIds
        )
    end).
