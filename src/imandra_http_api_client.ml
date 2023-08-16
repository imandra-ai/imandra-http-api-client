
module Config = struct
  type t = { base_url : Uri.t; auth_token: string option }
end

module E = Api.Encoders(Decoders_yojson.Basic.Encode)
module D = Api.Decoders(Decoders_yojson.Basic.Decode)

type error =
  [ `Error_response of Cohttp.Code.status_code * Api.Response.error
  | `Error_decoding_response of Decoders_yojson.Basic.Decode.error ]

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

let read_ok_response dec s =
  match Decoders_yojson.Basic.Decode.decode_string (D.Response.ok_response dec) s with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)

let read_error s =
  match Decoders_yojson.Basic.Decode.decode_string D.Response.error s with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)

let read (dec: 'a Decoders_yojson.Basic.Decode.decoder) (resp, body) : ('a Api.Response.ok_response, error) Lwt_result.t =
  let open Lwt.Syntax in
  let* body = Cohttp_lwt.Body.to_string body in
  let status = Cohttp.Response.status resp in
  let res = if status = `OK then
    read_ok_response dec body
    |> CCResult.flat_map (fun ok -> Ok ok)
  else
    read_error body
    |> CCResult.flat_map (fun err -> Error (`Error_response (status, err)))
  in
  Lwt.return res

let eval (c: Config.t) req =
  let open Lwt.Syntax in
  let uri = build_uri c "/eval/by-src" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.eval_req_src req in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers ~body in
  read D.Response.eval_result res

let get_history (c: Config.t) =
  let open Lwt.Syntax in
  let uri = build_uri c "/history" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let* res = Cohttp_lwt_unix.Client.call `GET uri ~headers in
  read Decoders_yojson.Basic.Decode.string res

let get_status (c: Config.t) =
  let open Lwt.Syntax in
  let uri = build_uri c "/status" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let* res = Cohttp_lwt_unix.Client.call `GET uri ~headers in
  read Decoders_yojson.Basic.Decode.string res

let instance_by_src (c: Config.t) req =
  let open Lwt.Syntax in
  let uri = build_uri c "/instance/by-name" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.instance_req_name req in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers ~body in
  read D.Response.instance_result res

let instance_by_src (c: Config.t) req =
  let open Lwt.Syntax in
  let uri = build_uri c "/instance/by-src" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.instance_req_src req in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers ~body in
  read D.Response.instance_result res

let reset (c: Config.t) () =
  let open Lwt.Syntax in
  let uri = build_uri c "/reset" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers in
  read D.Response.reset_result res

let shutdown (c: Config.t) () =
  let open Lwt.Syntax in
  let uri = build_uri c "/shutdown" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers in
  read Decoders_yojson.Basic.Decode.string res


let verify_by_src (c: Config.t) req =
  let open Lwt.Syntax in
  let uri = build_uri c "/verify/by-name" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.verify_req_name req in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers ~body in
  read D.Response.verify_result res

let verify_by_src (c: Config.t) req =
  let open Lwt.Syntax in
  let uri = build_uri c "/verify/by-src" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.verify_req_src req in
  let* res = Cohttp_lwt_unix.Client.call `POST uri ~headers ~body in
  read D.Response.verify_result res
