type src_syntax =
  | Reason
  | Iml

module D = Decoders

module Request : sig
  module Hints : sig
    module Induct : sig
      type functional = { f_name: string }

      type style =
        | Multiplicative
        | Additive

      type structural = {
        style: style;
        vars: string list;
      }

      type t =
        | Functional of functional
        | Structural of structural
        | Default
    end

    module Method : sig
      type unroll = { steps: int option }

      type ext_solver = { name: string }

      type t =
        | Unroll of unroll
        | Ext_solver of ext_solver
        | Auto
        | Induct of Induct.t
    end

    type t = { method_: Method.t }
  end

  type printer_details = {
    name: string;
    cx_var_name: string;
  }

  type verify_req_src = {
    syntax: src_syntax;
    src: string;
    instance_printer: printer_details option;
    hints: Hints.t option;
  }

  type verify_req_name = {
    name: string;
    instance_printer: printer_details option;
    hints: Hints.t option;
  }

  type instance_req_src = {
    syntax: src_syntax;
    src: string;
    instance_printer: printer_details option;
    hints: Hints.t option;
  }

  type instance_req_name = {
    name: string;
    instance_printer: printer_details option;
    hints: Hints.t option;
  }

  type decomp_req_src = {
    name: string;
    assuming: string option;
    prune: bool;
    max_rounds: int option;
    stop_at: int option;
  }

  type eval_req_src = {
    syntax: src_syntax;
    src: string;
  }
end

module Response : sig
  type capture = {
    stdout: string;
    stderr: string;
    raw_stdio: string option;
  }

  type model = {
    syntax: src_syntax;
    src: string;
  }

  type instance = {
    model: model;
    type_: string;
    printed: string option;
  }

  type with_instance = { instance: instance }

  type with_unknown_reason = { unknown_reason: string }

  type error = { error: string }

  type upto =
    | Upto_steps of int
    | Upto_bound of int

  type instance_result =
    | I_unsat
    | I_unsat_upto of upto
    | I_sat of with_instance
    | I_unknown of with_unknown_reason

  type verify_result =
    | V_proved
    | V_proved_upto of upto
    | V_refuted of with_instance
    | V_unknown of with_unknown_reason

  type eval_result = { success: bool }

  type reset_result = unit

  type 'a with_capture = {
    body: 'a;
    capture: capture;
  }

  type 'a response = ('a with_capture, error with_capture) result
end

module Decoders : functor (D : Decoders.Decode.S) -> sig
  val src_syntax : src_syntax D.decoder

  module Request : sig
    module Hints : sig
      module Induct : sig
        val structural : (D.value, Request.Hints.Induct.t) D.t_let

        val functional : (D.value, Request.Hints.Induct.t) D.t_let

        val t : (D.value, Request.Hints.Induct.t) D.t_let
      end

      module Method : sig
        val unroll : (D.value, Request.Hints.Method.unroll) D.t_let

        val ext_solver : (D.value, Request.Hints.Method.ext_solver) D.t_let

        val t : Request.Hints.Method.t D.decoder
      end

      val t : Request.Hints.t D.decoder
    end

    val printer_details : Request.printer_details D.decoder

    val verify_req_src : Request.verify_req_src D.decoder

    val verify_req_name : Request.verify_req_name D.decoder

    val instance_req_src : Request.instance_req_src D.decoder

    val instance_req_name : Request.instance_req_name D.decoder

    val decomp_req_src : Request.decomp_req_src D.decoder

    val eval_req_src : Request.eval_req_src D.decoder
  end

  module Response : sig
    type my_error = Response.error

    val src_syntax : src_syntax D.decoder

    val model : Response.model D.decoder

    val instance : Response.instance D.decoder

    val with_instance : Response.with_instance D.decoder

    val with_unknown_reason : Response.with_unknown_reason D.decoder

    val upto : Response.upto D.decoder

    val error : my_error D.decoder

    val verify_result : Response.verify_result D.decoder

    val instance_result : Response.instance_result D.decoder

    val eval_result : Response.eval_result D.decoder

    val reset_result : unit D.decoder

    val capture : Response.capture D.decoder

    val with_capture : 'a D.decoder -> 'a Response.with_capture D.decoder
  end
end

module Encoders : functor (E : D.Encode.S) -> sig
  val src_syntax : src_syntax E.encoder

  module Request : sig
    module Hints : sig
      module Induct : sig
        val functional : Request.Hints.Induct.functional -> E.value

        val structural : Request.Hints.Induct.structural -> E.value

        val t : Request.Hints.Induct.t E.encoder
      end

      module Method : sig
        val unroll : Request.Hints.Method.unroll -> E.value

        val ext_solver : Request.Hints.Method.ext_solver -> E.value

        val t : Request.Hints.Method.t E.encoder
      end

      val t : Request.Hints.t -> E.value
    end

    module Hints_e = Hints

    val src_syntax : src_syntax E.encoder

    val printer_details : Request.printer_details -> E.value

    val verify_req_src : Request.verify_req_src -> E.value

    val verify_req_name : Request.verify_req_name -> E.value

    val instance_req_src : Request.instance_req_src -> E.value

    val instance_req_name : Request.instance_req_name -> E.value

    val eval_req_src : Request.eval_req_src -> E.value
  end

  module Response : sig
    val model : Response.model -> E.value

    val instance : Response.instance -> E.value

    val with_instance : Response.with_instance -> E.value

    val with_unknown_reason : Response.with_unknown_reason -> E.value

    val error_response : Response.error -> E.value

    val upto : Response.upto -> E.value

    val verify_result : Response.verify_result E.encoder

    val instance_result : Response.instance_result E.encoder

    val capture : Response.capture -> (string * E.value) list

    val eval_result : Response.eval_result E.encoder

    val reset_result : unit E.encoder
  end
end
