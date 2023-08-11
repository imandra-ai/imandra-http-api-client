PORT?=3000
PID=$(shell lsof -t -i :$(PORT))
killcmd = $(if $(PID), "kill" "-9" $(PID), "echo" "No process running on port :$(PORT).")

all:
	@dune build @install

clean:
	@dune clean

WATCH?= @install
watch:
	@dune build $(WATCH) -w

runtest: 
	imandra-http-api 
	@dune build @runtest  

kill-process:
	@$(killcmd)

run-instance: kill-process
	dune exec test_http_api_instance 

run-eval: kill-process
	dune exec test_http_api_eval 

run-verify: kill-process
	dune exec test_http_api_verify
	
generate-imandra-http-api-client:
	export OCAML_POST_PROCESS_FILE="ocamlformat -i --enable-outside-detected-project"
	docker run -u $(id -u):$(id -g) --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/imandra_http_api_client.swagger.yaml -g ocaml -o /local  -p packageName=imandra_http_api_client -p generateSourceCodeOnly=true enablePostProcessFile=true

.PHONY: all clean watch generate-imandra-http-api-client