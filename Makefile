# The first make is to compile controller_xxx so that ale_routes_gen:gen/0 can
# collect routes from them (-pa ebin must be specified)
compile:
	erl -make
	erl -noshell -pa ebin -s ale_routes_gen gen -s init stop
	erl -make

clean:
	rm -rf ebin/*.beam

migrate:
	erl \
	-mnesia dir mnesia \
	-name khale@127.0.0.1 \
	-pa ebin \
	-noshell -s m_helper migrate -s init stop

start:
	yaws --mnesiadir mnesia --name khale@127.0.0.1
