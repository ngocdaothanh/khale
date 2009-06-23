compile:
	erl -make

start:
	erl +K true +P 1000000 \
	-name khale@localhost \
	-pa ebin lib/ale/ebin lib/herml/ebin lib/yaws/ebin \
	-eval "application:start(khale)"
