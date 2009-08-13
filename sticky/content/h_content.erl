-module(h_content).

-compile(export_all).

h_module(Content) ->
    Type = element(1, Content),
    list_to_atom([$h, $_ | atom_to_list(Type)]).

render_title(Content) ->
    HModule = h_module(Content),
    HModule:render_title(Content).

show_path(Content) ->
    Type = element(1, Content),
    Id = element(2, Content),
    ale:path(Type, show, [Id]).

render_titles_with_more(Contents) ->
    h_application:more(
        Contents, undefined,
        fun(Content) ->
            {li, [], {a, [{href, h_content:show_path(Content)}], h_content:render_title(Content)}}
        end,
        fun(LastContent) ->
            ThreadUpdatedAt1 = m_content:thread_updated_at(LastContent),
            ThreadUpdatedAt2 = h_application:timestamp_to_string(ThreadUpdatedAt1),
            case ale:params(tag_name) of
                undefined -> ale:path(content, titles, [ThreadUpdatedAt2]);
                TagName   -> ale:path(content, titles, [TagName, ThreadUpdatedAt2])
            end
        end
    ).

render_preview(Content) ->
    Title = {h1, [], {a, [{href, h_content:show_path(Content)}], h_content:render_title(Content)}},
    [Title, render_preview_without_title(Content)].

render_preview_without_title(Content) ->
    HModule = h_content:h_module(Content),
    Type = m_content:type(Content),
    Id = element(2, Content),
    [
        HModule:render_preview(Content),
        {br},
        h_discussion:render_last(Type, Id)
    ].
