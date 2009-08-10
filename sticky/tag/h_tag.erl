-module(h_tag).

-compile(export_all).

-include("sticky.hrl").

render_tag_selection() ->
    Js = "$('a.tag').click(function() {
        var tag   = this.innerHTML;
        var input = $('input.textbox[name=tags]');
        var val   = jQuery.trim(input.val());
        var tag2  = (val == '')? tag : (', ' + tag);
        input.val(val + tag2);
        return false;
    });",
    ale:app_add_js(Js),

    [
        {span, [{class, label}], ?T("Tags")},
        {input, [{type, text}, {class, textbox}, {name, tags}]},

        {ul, [],
            [{li, [],
                {a, [{href, "#"}, {class, tag}], yaws_api:htmlize(Tag#tag.name)}
            } || Tag <- m_tag:all()]
        }
    ].

render_tags(ContentType, ContentId) ->
    Tags = m_tag:all(ContentType, ContentId),
    
    Links = lists:map(
        fun(Tag) ->
            Name = yaws_api:htmlize(Tag#tag.name),
            {a, [{href, ale:path(content, tag, [Tag#tag.name])}], Name}
        end,
        Tags
    ),
    h_application:join(Links, ", ").
