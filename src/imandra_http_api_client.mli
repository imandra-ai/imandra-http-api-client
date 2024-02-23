module Api = Api

module Config : sig
  type t = {
    base_uri: Uri.t;
    auth_token: string option;
  }

  val make : ?auth_token:string -> base_uri:string -> unit -> t
end

type error =
  [ `Error_decoding_response of Decoders_yojson.Basic.Decode.error
  | `Error_response of
    Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
  ]

val handle_error : Format.formatter -> error -> unit

val build_uri : Config.t -> string -> Uri.t

val default_headers : Config.t -> (string * string) list

val make_body :
  'a Decoders_yojson.Basic.Encode.encoder -> 'a -> Cohttp_lwt.Body.t

val read_response :
  'a Decoders_yojson.Basic.Decode.decoder ->
  string ->
  ( 'a Api.Response.with_capture,
    [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
  result

val read :
  'a Decoders_yojson.Basic.Decode.decoder ->
  Http.Response.t * Cohttp_lwt.Body.t ->
  ('a Api.Response.with_capture, [> error ]) result Lwt.t

val eval :
  Config.t ->
  Api.Request.eval_req_src ->
  (Api.Response.eval_result Api.Response.with_capture, [> error ]) result Lwt.t

val get_history :
  Config.t -> (string Api.Response.with_capture, [> error ]) result Lwt.t

val get_status :
  Config.t -> (string Api.Response.with_capture, [> error ]) result Lwt.t

val instance_by_name :
  Config.t ->
  Api.Request.instance_req_name ->
  (Api.Response.instance_result Api.Response.with_capture, [> error ]) result
  Lwt.t

val instance_by_src :
  Config.t ->
  Api.Request.instance_req_src ->
  (Api.Response.instance_result Api.Response.with_capture, [> error ]) result
  Lwt.t

val reset :
  Config.t -> unit -> (unit Api.Response.with_capture, [> error ]) result Lwt.t

val shutdown :
  Config.t ->
  unit ->
  (string Api.Response.with_capture, [> error ]) result Lwt.t

val verify_by_name :
  Config.t ->
  Api.Request.verify_req_name ->
  (Api.Response.verify_result Api.Response.with_capture, [> error ]) result
  Lwt.t

val verify_by_src :
  Config.t ->
  Api.Request.verify_req_src ->
  (Api.Response.verify_result Api.Response.with_capture, [> error ]) result
  Lwt.t

val decompose :
  Config.t ->
  Api.Request.decomp_req_src ->
  ( Yojson.Basic.t Api.Response.decompose_result Api.Response.with_capture,
    [> error ] )
  result
  Lwt.t

module Eio : sig
  val read_raw :
    Cohttp_eio.Body.t ->
    ( string,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val read_response :
    'a Decoders_yojson.Basic.Decode.decoder ->
    Cohttp_eio.Body.t ->
    ( 'a Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val read_error :
    Cohttp_eio.Body.t ->
    ( Api.Response.error Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val read :
    'a Decoders_yojson.Basic.Decode.decoder ->
    Http.Response.t * Cohttp_eio.Body.t ->
    ( 'a Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val eval :
    Config.t ->
    Api.Request.eval_req_src ->
    sw:Eio.Switch.t ->
    client:Cohttp_eio.Client.t ->
    ( Api.Response.eval_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val get_history :
    Config.t ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( string,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val get_status :
    Config.t ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( string,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val instance_by_name :
    Config.t ->
    Api.Request.instance_req_name ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( Api.Response.instance_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val instance_by_src :
    Config.t ->
    Api.Request.instance_req_src ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( Api.Response.instance_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val reset :
    Config.t ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( string,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val shutdown :
    Config.t ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( string,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error ] )
    result

  val verify_by_name :
    Config.t ->
    Api.Request.verify_req_name ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( Api.Response.verify_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val verify_by_src :
    Config.t ->
    Api.Request.verify_req_src ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( Api.Response.verify_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result

  val decompose :
    Config.t ->
    Api.Request.decomp_req_src ->
    client:Cohttp_eio.Client.t ->
    sw:Eio.Switch.t ->
    ( Yojson.Basic.t Api.Response.decompose_result Api.Response.with_capture,
      [> `Error_decoding_response of Decoders_yojson.Basic.Decode.error
      | `Error_response of
        Cohttp.Code.status_code * Api.Response.error Api.Response.with_capture
      ] )
    result
end
