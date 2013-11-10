REBAR=$(shell which rebar || ./rebar)
SYNC_PATH = $(ERL_LIBS)/sync
PROPER_PATH = $(ERL_LIBS)/proper

all: deps compile

compile:
		@$(REBAR) compile

app:
		@$(REBAR) compile skip_deps=true

deps:
		@$(REBAR) get-deps

clean:
		@$(REBAR) clean

distclean: clean
		@$(REBAR) delete-deps

test: app
		@$(REBAR) eunit skip_deps=true

start:
		if test -d $(SYNC_PATH); \
		then exec erl -name sourcery@127.0.0.1 -setcookie sourcery -pa $(PWD)/deps/*/ebin -pa $(PWD)/ebin -boot start_sasl -s lager -s vorperl -s topical -run sourcery; \
		else exec erl -name sourcery@127.0.0.1 -setcookie sourcery -pa $(PWD)/deps/*/ebin -pa $(PWD)/ebin -boot start_sasl -s lager -s vorperl -s topical -run sourcery; \
		fi
