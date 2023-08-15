
module Config = struct
  type t = { base_url : Uri.t; auth_token: string option }
end

module E = Api.Encoders(Decoders_yojson.Basic.Encode)
module D = Api.Decoders(Decoders_yojson.Basic.Decode)

let build_uri (c : Config.t) path =
  Uri.with_path c.base_url path

let default_headers (c : Config.t) =
  let other_headers = [] in
  let auth_header = match c.auth_token with
  | None -> []
  | Some t -> [("Authorization", Format.asprintf "Bearer %s" t)]
  in
  other_headers @ auth_header

let make_body enc x =
  Decoders_yojson.Basic.Encode.encode_string enc x
  |> Cohttp_lwt.Body.of_string

let eval (c: Config.t) ~eval_req_src_t =
  let open Lwt.Infix in
  let uri = build_uri c "/eval/by-src" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.eval_req_src eval_req_src_t in
  Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) ->
  read_body D.Response.
  Request.read_json_body resp body

(* let get_history () = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/history" in *)
(*   let headers = Request.default_headers in *)
(*   Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) -> *)
(*   Request.read_string_body resp body *)

(* let get_status () = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/status" in *)
(*   let headers = Request.default_headers in *)
(*   Cohttp_lwt_unix.Client.call `GET uri ~headers >>= fun (resp, body) -> *)
(*   Request.read_string_body resp body *)

(* let instance_by_name ~instance_request_name_t = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/instance/by-name" in *)
(*   let headers = Request.default_headers in *)
(*   let body = *)
(*     Request.write_as_json_body Instance_request_name.to_yojson *)
(*       instance_request_name_t *)
(*   in *)
(*   Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) -> *)
(*   Request.read_json_body resp body *)

let instance_by_src ~instance_request_src_t =
  let open Lwt.Infix in
  let uri = build_uri "/instance/by-src" in
  let headers = Request.default_headers in
  let body =
    Request.write_as_json_body Instance_request_src.to_yojson
      instance_request_src_t
  in
  Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) ->
  Request.read_json_body
    (* (JsonSupport.unwrap Instance_response.of_yojson) *)
    resp body

(* (\* TODO: fix in the server side to send reset info in the body? currently it returns "{}". *\) *)
(* let reset () = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/reset" in *)
(*   let headers = Request.default_headers in *)
(*   Cohttp_lwt_unix.Client.call `POST uri ~headers >>= fun (resp, body) -> *)
(*   Request.read_string_body resp body *)

(* let shutdown () = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/shutdown" in *)
(*   let headers = Request.default_headers in *)
(*   Cohttp_lwt_unix.Client.call `POST uri ~headers >>= fun (resp, body) -> *)
(*   (\* Request.read_json_body_as JsonSupport.to_string resp body *\) *)
(*   Request.read_string_body resp body *)

(* let verify_by_name ~verify_request_name_t = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/verify/by-name" in *)
(*   let headers = Request.default_headers in *)
(*   let body = *)
(*     Request.write_as_json_body Verify_request_name.to_yojson *)
(*       verify_request_name_t *)
(*   in *)
(*   Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) -> *)
(*   Request.read_json_body resp body *)

(* let verify_by_src ~verify_request_src_t = *)
(*   let open Lwt.Infix in *)
(*   let uri = build_uri "/verify/by-src" in *)
(*   let headers = Request.default_headers in *)
(*   let body = *)
(*     Request.write_as_json_body Verify_request_src.to_yojson verify_request_src_t *)
(*   in *)
(*   Cohttp_lwt_unix.Client.call `POST uri ~headers ~body >>= fun (resp, body) -> *)
(*   Request.read_json_body resp body *)
