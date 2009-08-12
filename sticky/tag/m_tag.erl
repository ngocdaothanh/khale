-module(m_tag).

-compile(export_all).

-include("sticky.hrl").

migrate() ->
    m_helper:create_table(tag,         record_info(fields, tag)),
    m_helper:create_table(content_tag, record_info(fields, content_tag), bag).

create(Name) ->
    F = fun() ->
        Id = m_helper:next_id(tag),
        Tag = #tag{id = Id, name = Name},
        ok = mnesia:write(Tag),
        Tag
    end,
    case mnesia:transaction(F) of
        {atomic, R} -> R;
        _           -> undefined
    end.

all() ->
    Q1 = qlc:q([R || R <- mnesia:table(tag)]),
    Q2 = qlc:keysort(3, Q1, [{order, ascending}]),  % sort by name
    m_helper:do(Q2).

all(ContentType, ContentId) ->
    F = fun() ->
        Q = qlc:q([
            R#content_tag.tag_id ||
            R <- mnesia:table(content_tag),
            R#content_tag.content_type == ContentType,
            R#content_tag.content_id == ContentId
        ]),
        Ids = qlc:e(Q),

        Tags = lists:map(
            fun(Id) -> mnesia:read(tag, Id) end,  % Result is a list, may be empty
            Ids
        ),
        lists:flatten(Tags)
    end,
    case mnesia:transaction(F) of
        {atomic, X} -> X;
        _           -> []
    end.

find_by_name(Name) ->
    Q = qlc:q([R || R <- mnesia:table(tag), R#tag.name == Name]),
    case m_helper:do(Q) of
        [R] -> R;
        _   -> undefined
    end.

%% TagNames: comma-separated string
%%
%% This function must be run inside an Mnesia transaction.
tag(ContentType, ContentId, TagNames) ->
    TagNames2 = [string:strip(T) || T <- string:tokens(TagNames, ",")],
    TagNames3 = lists:usort(TagNames2),
    TagIds = lists:map(
        fun(TagName) ->
            Tag = case find_by_name(TagName) of
                undefined -> create(TagName);
                X         -> X
            end,
            Tag#tag.id
        end,
        TagNames3
    ),

    % Remove all tags for this content
    OldTags = all(ContentType, ContentId),
    lists:foreach(
        fun(Tag) ->
            Object = #content_tag{content_type = ContentType, content_id = ContentId, tag_id = Tag#tag.id},
            mnesia:delete_object(content_tag, Object, write)
        end,
        OldTags
    ),

    % Then add again
    lists:foreach(
        fun(TagId) ->
            ContentTag = #content_tag{content_type = ContentType, content_id = ContentId, tag_id = TagId},
            ok = mnesia:write(ContentTag)
        end,
        TagIds
    ).
