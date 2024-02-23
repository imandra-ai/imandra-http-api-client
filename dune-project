(lang dune 2.7)

(name imandra-http-api-client)

(generate_opam_files true)

(source
 (github imandra-ai/imandra-http-api-client))

(authors "the Imandra team and contributors")

(maintainers "the Imandra team and contributors")

(license MIT)

(package
 (name imandra-http-api-client)
 (synopsis "Interact with Imandra via http from within OCaml.")
 (version 0.1)
 (depends
  ocaml
  containers
  cohttp-eio
  eio
  eio_main
  cohttp
  ppx_deriving
  cohttp-lwt-unix
  decoders
  decoders-yojson
  alcotest
  alcotest-lwt))
