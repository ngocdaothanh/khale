-module(v_content_new).

-compile(export_all).

-include_lib("sticky.hrl").

render() ->
    PartialNew = ale:app(partial_new),
    [
        {form, [{method, post}, {action, ale:url_for(content, create, [ale:params(content_type)])}], [
            PartialNew:render(),
            {input, [{type, submit}, {value, ?T("Save")}]}
        ]}
    ].
