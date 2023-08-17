PORT?=3000
PID=$(shell lsof -t -i :$(PORT))
killcmd = $(if $(PID), "kill" "-9" $(PID), "echo" "No process running on port :$(PORT).")

all:
	@dune build @install

tests:
	dune runtest --force

clean:
	@dune clean

WATCH?= @install
watch:
	@dune build $(WATCH) -w

kill-process:
	@$(killcmd)

run-instance: kill-process
	dune exec test_http_api_instance

run-eval: kill-process
	dune exec test_http_api_eval

run-verify: kill-process
	dune exec test_http_api_verify

_opam:
	opam switch create . --empty
	opam switch set-invariant ocaml-base-compiler.4.12.1

opam-install-deps: _opam
	opam install ./imandra-http-api-client.opam -y --deps-only

.PHONY: all clean watch tests
