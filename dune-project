(lang dune 2.7)

(name imandra_http_api_client)

(generate_opam_files true)

(source
 (github imandra-ai/imandra_http_api_client))

(authors "the Imandra team and contributors")

(maintainers "the Imandra team and contributors")

(license MIT)

(package
 (name imandra_http_api_client)
 (synopsis "Interact with Imandra via http from within OCaml.")
 (depends
  ocaml
  ppx_deriving_yojson
  containers
  cohttp
  ppx_deriving
  cohttp-lwt-unix
  ocaml-migrate-parsetree))
