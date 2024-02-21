module Config = struct
  type t = {
    base_uri: Uri.t;
    auth_token: string option;
  }

  let make ?auth_token ~base_uri () =
    { base_uri = Uri.of_string base_uri; auth_token }
end

module E = Api.Encoders (Decoders_yojson.Basic.Encode)
module D = Api.Decoders (Decoders_yojson.Basic.Decode)

type error =
  [ `Error_response of
    Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
  | `Error_decoding_response of Decoders_yojson.Basic.Decode.error
  ]

let build_uri (c : Config.t) path = Uri.with_path c.base_uri path

let default_headers (c : Config.t) =
  let other_headers = [] in
  let auth_header =
    match c.auth_token with
    | None -> []
    | Some t -> [ "Authorization", Format.asprintf "Bearer %s" t ]
  in
  other_headers @ auth_header

let make_body enc x : Cohttp_eio.Body.t =
  Decoders_yojson.Basic.Encode.encode_string enc x |> Cohttp_eio.Body.of_string

let read_response dec (s : Cohttp_eio.Body.t) =
  match
    Decoders_yojson.Basic.Decode.decode_string
      (D.Response.with_capture dec)
      (s |> Eio.Flow.read_all)
  with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)

let read_error (s : Cohttp_eio.Body.t) =
  match
    Decoders_yojson.Basic.Decode.decode_string
      D.Response.(with_capture error)
      (s |> Eio.Flow.read_all)
  with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)

let read (dec : 'a Decoders_yojson.Basic.Decode.decoder)
    ((resp, body) : Http.Response.t * Cohttp_eio.Body.t) =
  let status = Cohttp.Response.status resp in
  if status = `OK then
    read_response dec body |> CCResult.flat_map (fun ok -> Ok ok)
  else
    read_error body
    |> CCResult.flat_map (fun err -> Error (`Error_response (status, err)))

(* let net =
   let open Eio.Std in
   let net = Eio_mock.Net.make "mocknet" in
   Eio_mock.Net.on_getaddrinfo net
     [ `Return [ `Tcp (Eio.Net.Ipaddr.V4.loopback, 443) ] ];
   let conn = Eio_mock.Flow.make "connection" in
   Eio_mock.Net.on_connect net [ `Return conn ];
   net *)

let eval (c : Config.t) (req : Api.Request.eval_req_src) ~sw cl =
  let uri = build_uri c "/eval/by-src" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let body = make_body E.Request.eval_req_src req in
  let res = Cohttp_eio.Client.call cl ~sw `POST uri ~headers ~body in
  read D.Response.eval_result res

let get_history (c : Config.t) cl ~sw =
  let uri = build_uri c "/history" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let resp, body = Cohttp_eio.Client.get cl ~sw uri ~headers in

  Logs.debug (fun k -> k "%s" (body |> Eio.Flow.read_all));
  read Decoders_yojson.Basic.Decode.string (resp, body)

let get_status (c : Config.t) cl ~sw =
  let uri = build_uri c "/status" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let resp, body = Cohttp_eio.Client.get cl ~sw uri ~headers in
  (* Logs.debug (fun k -> k "%s" (body |> Eio.Flow.read_all)); *)
  read Decoders_yojson.Basic.Decode.string (resp, body)

let reset (c : Config.t) cl ~sw =
  let uri = build_uri c "/reset" in
  let headers = default_headers c |> Cohttp.Header.of_list in
  let res = Cohttp_eio.Client.call cl ~sw `POST uri ~headers in
  read D.Response.reset_result res
