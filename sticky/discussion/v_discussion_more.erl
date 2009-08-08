-module(v_discussion_more).

-compile(export_all).

-include("sticky.hrl").

render() ->
    % Type and ID cannot be inferred from Discussions when it is empty!
    ContentType = ale:app(content_type),
    ContentId   = ale:app(content_id),
    Discussions = ale:app(discussions),
    h_application:more(
        Discussions, discussions, discussion,
        fun(Discussion)     -> h_discussion:render_one(Discussion, true) end,
        fun(LastDiscussion) -> ale:path(discussion, more, [ContentType, ContentId, LastDiscussion#discussion.id]) end
    ).
