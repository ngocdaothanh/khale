-module(controller_application).

-compile(export_all).

error_404(_Uri) ->
    put(status, 404),
    put(content, "Not found").

error_500(_Type, _Reason) ->
    put(status, 500),
    put(content, "There was error processing your request, and the admin has been notified. Sorry for your inconvenience.").
