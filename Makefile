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
	
generate-imandra-http-api-client:
	docker run -u $(id -u):$(id -g) --rm -v ${PWD}:/local openapitools/openapi-generator-cli generate -i /local/imandra_http_api_client.swagger.yaml -g ocaml -o /local/src  -p packageName=imandra_http_api_client -p generateSourceCodeOnly=true

.PHONY: all clean watch generate-imandra-http-api-client