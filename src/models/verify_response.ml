(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  _type: Enums.verifyresult;
  body: Verify_response_body.t option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create (_type : Enums.verifyresult) : t = { _type; body = None }
