# Imandra HTTP API Client
Query Imandra via HTTP. See also https://github.com/aestheticIntegration/bs-imandra-client for a sample client implementation and OCaml API types.

## Installation 
This repository uses Nix and [Nix flakes](https://nixos.wiki/wiki/Flakes) for system-level dependencies. 

To install dependencies and build the project, please clone this repository and run:
```
make opam-install-deps
make all
```

## Getting Started

We assume that you have `imandra-http-api` running on localhost at port 3000. With this setup, tests can be run using `dune runtest`. 
The `imandra_http_api_client.mli` interface file has functions which interact with various endpoints. 

