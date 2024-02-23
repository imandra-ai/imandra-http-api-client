module Api = Api

module Config : sig
  type t = {
    base_uri: Uri.t;
    auth_token: string option;
  }

  val make : ?auth_token:string -> base_uri:string -> unit -> t
end

module E : sig
  val src_syntax : Api.src_syntax Decoders_yojson.Basic.Encode.encoder

  module Request : sig
    module Hints : sig
      module Induct : sig
        val functional : Api.Request.Hints.Induct.functional -> Yojson.Basic.t

        val structural : Api.Request.Hints.Induct.structural -> Yojson.Basic.t

        val t : Api.Request.Hints.Induct.t Decoders_yojson.Basic.Encode.encoder
      end

      module Method : sig
        val unroll : Api.Request.Hints.Method.unroll -> Yojson.Basic.t

        val ext_solver : Api.Request.Hints.Method.ext_solver -> Yojson.Basic.t

        val t : Api.Request.Hints.Method.t Decoders_yojson.Basic.Encode.encoder
      end

      val t : Api.Request.Hints.t -> Yojson.Basic.t
    end

    module Hints_e = Hints

    val src_syntax : Api.src_syntax Decoders_yojson.Basic.Encode.encoder

    val printer_details : Api.Request.printer_details -> Yojson.Basic.t

    val verify_req_src : Api.Request.verify_req_src -> Yojson.Basic.t

    val verify_req_name : Api.Request.verify_req_name -> Yojson.Basic.t

    val instance_req_src : Api.Request.instance_req_src -> Yojson.Basic.t

    val instance_req_name : Api.Request.instance_req_name -> Yojson.Basic.t

    val decomp_req_src : Api.Request.decomp_req_src -> Yojson.Basic.t

    val eval_req_src : Api.Request.eval_req_src -> Yojson.Basic.t
  end

  module Response : sig
    val model : Api.Response.model -> Yojson.Basic.t

    val instance : Api.Response.instance -> Yojson.Basic.t

    val with_instance : Api.Response.with_instance -> Yojson.Basic.t

    val with_unknown_reason : Api.Response.with_unknown_reason -> Yojson.Basic.t

    val error_response : Api.Response.error -> Yojson.Basic.t

    val upto : Api.Response.upto -> Yojson.Basic.t

    val verify_result :
      Api.Response.verify_result Decoders_yojson.Basic.Encode.encoder

    val instance_result :
      Api.Response.instance_result Decoders_yojson.Basic.Encode.encoder

    val decompose_result :
      Yojson.Basic.t Api.Response.decompose_result
      Decoders_yojson.Basic.Encode.encoder

    val capture : Api.Response.capture -> (string * Yojson.Basic.t) list

    val eval_result :
      Api.Response.eval_result Decoders_yojson.Basic.Encode.encoder

    val reset_result : unit Decoders_yojson.Basic.Encode.encoder
  end
end

module D : sig
  val src_syntax : Api.src_syntax Decoders_yojson.Basic.Decode.decoder

  module Request : sig
    module Hints : sig
      module Induct : sig
        val structural :
          Api.Request.Hints.Induct.t Decoders_yojson.Basic.Decode.decoder

        val functional :
          Api.Request.Hints.Induct.t Decoders_yojson.Basic.Decode.decoder

        val t : Api.Request.Hints.Induct.t Decoders_yojson.Basic.Decode.decoder
      end

      module Method : sig
        val unroll :
          Api.Request.Hints.Method.unroll Decoders_yojson.Basic.Decode.decoder

        val ext_solver :
          Api.Request.Hints.Method.ext_solver
          Decoders_yojson.Basic.Decode.decoder

        val t : Api.Request.Hints.Method.t Decoders_yojson.Basic.Decode.decoder
      end

      val t : Api.Request.Hints.t Decoders_yojson.Basic.Decode.decoder
    end

    val printer_details :
      Api.Request.printer_details Decoders_yojson.Basic.Decode.decoder

    val verify_req_src :
      Api.Request.verify_req_src Decoders_yojson.Basic.Decode.decoder

    val verify_req_name :
      Api.Request.verify_req_name Decoders_yojson.Basic.Decode.decoder

    val instance_req_src :
      Api.Request.instance_req_src Decoders_yojson.Basic.Decode.decoder

    val instance_req_name :
      Api.Request.instance_req_name Decoders_yojson.Basic.Decode.decoder

    val decomp_req_src :
      Api.Request.decomp_req_src Decoders_yojson.Basic.Decode.decoder

    val eval_req_src :
      Api.Request.eval_req_src Decoders_yojson.Basic.Decode.decoder
  end

  module Response : sig
    type my_error = Api.Response.error

    val src_syntax : Api.src_syntax Decoders_yojson.Basic.Decode.decoder

    val model : Api.Response.model Decoders_yojson.Basic.Decode.decoder

    val instance : Api.Response.instance Decoders_yojson.Basic.Decode.decoder

    val with_instance :
      Api.Response.with_instance Decoders_yojson.Basic.Decode.decoder

    val with_unknown_reason :
      Api.Response.with_unknown_reason Decoders_yojson.Basic.Decode.decoder

    val upto : Api.Response.upto Decoders_yojson.Basic.Decode.decoder

    val error : my_error Decoders_yojson.Basic.Decode.decoder

    val verify_result :
      Api.Response.verify_result Decoders_yojson.Basic.Decode.decoder

    val instance_result :
      Api.Response.instance_result Decoders_yojson.Basic.Decode.decoder

    val eval_result :
      Api.Response.eval_result Decoders_yojson.Basic.Decode.decoder

    val reset_result : unit Decoders_yojson.Basic.Decode.decoder

    val decompose_result :
      Yojson.Basic.t Api.Response.decompose_result
      Decoders_yojson.Basic.Decode.decoder

    val opt_capture :
      Api.Response.capture option Decoders_yojson.Basic.Decode.decoder

    val with_capture :
      'a Decoders_yojson.Basic.Decode.decoder ->
      'a Api.Response.with_capture Decoders_yojson.Basic.Decode.decoder
  end
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

val read_error :
  string ->
  ( D.Response.my_error Api.Response.with_capture,
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
