-module(subl_autocomp).		

-compile([export_all]).

generate() ->
	extra(),
	Modules = code:all_loaded(),
	Bifs = bifs(),
	AllCompletions = [ process(M) || {M, _} <- Modules ],
	All = lists:append(Bifs, lists:append(AllCompletions)),
	Props = [{source, <<"meta.type.function.erlang">>}, {completions, All}],
	Bin = list_to_binary(mochijson2:encode(Props)),
	file:write_file("ErlangStdLibs.sublime-completions", Bin).

process(Module) ->
	Exports = Module:module_info(exports),
	[completion(Module, Fun, Arity) || {Fun, Arity} <- Exports].

completion(Fun, Arity) ->
	Trigger = atom_to_list(Fun) ++ "/" ++ integer_to_list(Arity),
	A = [ "${" ++ integer_to_list(X) ++ ":arg" ++ integer_to_list(X-1)  ++ "}" || X <- lists:seq(1,Arity), Arity > 0 ],
	Contents = atom_to_list(Fun) ++ "(" ++ string:join(A, ", ")  ++ ")",
	[{trigger, list_to_binary(Trigger)}, {contents, list_to_binary(Contents)}].

completion(Module, Fun, Arity) ->
	Trigger = atom_to_list(Module) ++ ":" ++ atom_to_list(Fun) ++ "/" ++ integer_to_list(Arity),
	A = [ "${" ++ integer_to_list(X) ++ ":arg" ++ integer_to_list(X-1) ++ "}" || X <- lists:seq(1,Arity), Arity > 0],
	Contents = atom_to_list(Module) ++ ":" ++ atom_to_list(Fun) ++ "(" ++ string:join(A, ", ")  ++ ")",
	[{trigger, list_to_binary(Trigger)}, {contents, list_to_binary(Contents)}].

bifs() ->
	Exports = erlang:module_info(exports),
	[completion(Fun, Arity) || {Fun, Arity} <- Exports].

extra() ->
	ok = application:load(mnesia).
