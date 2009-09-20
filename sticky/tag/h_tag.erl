-module(h_tag).

-compile(export_all).

-include("sticky.hrl").

render_tag_selection(Tags) ->
    Js = ale:ff("p_tag_selection.js"),
    ale:app_add_js(Js),

    TagNames = [yaws_api:htmlize(Tag#tag.name) || Tag <- Tags],
    [
        {span, [{class, label}], ?T("Tags (separated by comma)")},
        {input, [{type, text}, {class, textbox}, {name, tags}, {value, h_app:join(TagNames, ", ")}]},

        {ul, [],
            [{li, [],
                {a, [{title, ?T("Click to select")}, {href, "#"}, {class, tag}], yaws_api:htmlize(Tag#tag.name)}
            } || Tag <- m_tag:all()]
        }
    ].

%% Returns EHTML or undefined so that the result can be used in h_user:render/2.
render_tags(ContentType, ContentId) ->
    case m_tag:all(ContentType, ContentId) of
        [] -> undefined;

        Tags ->
            Links = lists:map(
                fun(Tag) ->
                    Name = yaws_api:htmlize(Tag#tag.name),
                    {a, [{href, ale:path(content, tag, [Tag#tag.name])}], Name}
                end,
                Tags
            ),
            h_app:join(Links, ", ")
    end.
