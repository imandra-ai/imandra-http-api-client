(lang dune 2.7)

(name imandra-http-api-client)

(generate_opam_files true)

(source
 (github imandra-ai/imandra-http_api-client))

(authors "the Imandra team and contributors")

(maintainers "the Imandra team and contributors")

(license MIT)

(package
 (name imandra-http-api-client)
 (synopsis "Interact with Imandra via http from within OCaml.")
 (depends
  ocaml
  ppx_deriving_yojson
  containers
  cohttp
  ppx_deriving
  cohttp-lwt-unix
  ocaml-migrate-parsetree))
