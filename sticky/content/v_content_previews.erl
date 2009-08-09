-module(v_content_previews).

-compile(export_all).

-include("sticky.hrl").

render() ->
    Contents = ale:app(contents),
    h_application:more(
        Contents, previews,
        fun(Content) -> {li, [{class, preview}], render_one(Content)} end,
        fun(LastContent) ->
            ThreadUpdatedAt1 = m_content:thread_updated_at(LastContent),
            ThreadUpdatedAt2 = h_application:timestamp_to_string(ThreadUpdatedAt1),
            case ale:params(tag_name) of
                undefined -> ale:path(previews, [ThreadUpdatedAt2]);
                TagName   -> ale:path(previews, [TagName, ThreadUpdatedAt2])
            end
        end
    ).

render_one(Content) ->
    HModule = h_content:h_module(Content),
    Type = m_content:type(Content),
    Id = element(2, Content),
    [
        HModule:render_preview(Content),
        {br},
        h_discussion:render_last(Type, Id)
    ].
