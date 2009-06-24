-module(controller_application).

-compile(export_all).

error_404(Uri) ->
    put(response_code, 404),
    put(content, "Not found").

error_500(Reason) ->
    put(response_code, 500),
    put(content, "Server error").
