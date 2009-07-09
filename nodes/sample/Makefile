ALE_ROOT=../..

migrate:
	erl -setcookie cookie \
		-mnesia dir mnesia \
		-name khale_n1@ngoc-2.local \
		-pa $(ALE_ROOT)/ebin \
		-noshell -s m_helper migrate -s init stop

start:
	yaws --erlarg "-setcookie cookie" \
	    --pa $(ALE_ROOT)/ebin \
		--mnesiadir mnesia \
		--id khale_n1 \
		--name khale_n1@ngoc-2.local
