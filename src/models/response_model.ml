(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  syntax: Enums.syntax option; [@default None]
  (* Source code string with a given syntax (default Iml) *)
  src: string option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create () : t = { syntax = None; src = None }
