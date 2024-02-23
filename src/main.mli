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
  Cohttp.Response.t * Cohttp_lwt.Body.t ->
  ('a Api.Response.with_capture, [> error ]) Lwt_result.t

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
