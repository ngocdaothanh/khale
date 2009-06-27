compile:
	erl -make
	erl -noshell -pa ebin lib/ale/ebin -s ale_routes_gen gen -s init stop
	erl -make

clean:
	rm -rf ebin/*.beam
