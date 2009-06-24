compile:
	erl -make
	erl -noshell -pa ebin lib/ale/ebin -s routes_gen gen -s init stop
	erl -make

clean:
	rm -rf ebin/*.beam
