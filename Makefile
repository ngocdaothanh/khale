# The first make is to compile controller_xxx so that ale_routes_gen:gen/0 can
# collect routes from them (-pa ebin must be specified)
compile:
	erl -make
	erl -noshell -pa ebin -s ale_routes_gen gen -s ale_cache_is_cached_gen gen -s init stop
	erl -make

clean:
	rm -rf ebin/*.beam

start:
	yaws \
		--pa ebin \
		--mnesiadir mnesia

migrate:
	erl \
		-noshell \
		-pa ebin \
		-mnesia dir mnesia \
		-s m_helper migrate -s init stop
