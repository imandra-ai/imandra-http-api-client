(*
 * This file has been generated by the OCamlClientCodegen generator for openapi-generator.
 *
 * Generated by: https://openapi-generator.tech
 *
 *)

type t = {
  (* Example: my_fn_name  *)
  name: string;
  instance_printer: Printer_details.t option; [@default None]
  hints: Hints.t option; [@default None]
}
[@@deriving yojson { strict = false }, show]

let create (name : string) : t = { name; instance_printer = None; hints = None }
