-module(map_runner_generator).

-compile(export_all).

generate() ->
	Forms = filelib:fold_files(".", "^controller_.*\.beam$", true,
		fun(FileName, Acc) ->
			BaseName = filename:basename(FileName, ".beam"),
			Controller = list_to_atom(BaseName),
			[generate(Controller) | Acc]
		end,
		[]
	),

	Template = "-module(map_runner).\n\n"
		"-export([run_uri/2, run_tokens/2]).\n\n"
		"run_uri(Method, Uri) -> Tokens = string:tokens(Uri, \"/\"), run_tokens(Method, Tokens).\n\n"
		"~s"
		"\nrun_tokens(_, _) -> no_map.\n",
	Source = io_lib:format(Template, [Forms]),
	file:write_file("map_runner.erl", Source).

generate(Controller) ->
    case erlang:function_exported(Controller, map, 0) of
	    true ->
	        Map = Controller:map(),
	        generate(Controller, Map, [["% ", atom_to_list(Controller), "\n"]]);

	    false -> ""
	end.

generate(_Controller, [], FormAcc) ->
	lists:reverse(FormAcc);
generate(Controller, [Method, Uri, Action | Rest], FormAcc) ->
	Tokens = string:tokens(Uri, "/"),
	{Tokens2, Vars} = lists:foldr(
		fun(Token, {TokenAcc, VarAcc}) ->
			FirstChar = hd(Token),
			case ($a =< FirstChar) andalso (FirstChar =< $z) of
				true  -> {[([$"] ++ Token ++ [$"]) | TokenAcc], VarAcc};
				false -> {[Token | TokenAcc], [Token | VarAcc]}
			end
		end,
		{[], []},
		Tokens
	),

	Template = "run_tokens(~p, [~s]) -> "
		"apply(~p, ~p, [~s]);\n",
	Form = io_lib:format(Template, [Method, string:join(Tokens2, ", "), Controller, Action, string:join(Vars, ", ")]),
	generate(Controller, Rest, [Form | FormAcc]).
