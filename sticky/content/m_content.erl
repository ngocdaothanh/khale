-module(m_content).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(content,         record_info(fields, content)),
    m_helper:create_table(content_version, record_info(fields, content_version)).

instructions() ->
    m_helper:apply_to_all("^m_.*\.beam$", instruction).

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
