module Api = Api

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
(*
   let make_body enc x =
     Decoders_yojson.Basic.Encode.encode_string enc x |> Cohttp_lwt.Body.of_string *)

let read_response dec s =
  match
    Decoders_yojson.Basic.Decode.decode_string (D.Response.with_capture dec) s
  with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)

let read_error s =
  match
    Decoders_yojson.Basic.Decode.decode_string D.Response.(with_capture error) s
  with
  | Ok err -> Ok err
  | Error e -> Error (`Error_decoding_response e)
