module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let () =
  let open Imandra_http_api_client in
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Debug);
  let config = Main_eio.Config.make ~base_uri:"http://127.0.0.1:3000" () in

  let response http ~sw =
    Log.debug (fun k -> k "Sending query to server...");
    let req : Api.Request.eval_req_src =
      { src = "let f x = x + 1"; syntax = Iml }
    in
    let _ = Main_eio.eval config req ~sw ~client:http in
    let result =
      Main_eio.instance_by_src config ~client:http ~sw
        {
          src = "fun (x : int) -> f x > 4";
          syntax = Iml;
          hints = None;
          instance_printer = Some { name = "Z.sprint ()"; cx_var_name = "x" };
        }
    in
    match result with
    | Ok st ->
      Log.app (fun k ->
          k "Got ok response: %a"
            CCFormat.(some Api.Response.pp_capture)
            st.capture)
    | Error err ->
      (match err with
      | `Error_decoding_response err ->
        Log.err (fun k ->
            k "Decoding error: %a@." Decoders_yojson.Basic.Decode.pp_error err)
      | `Error_response (code, err) ->
        Log.err (fun k ->
            k "Error response: Code = %s @. %a"
              (Cohttp.Code.string_of_status code)
              CCFormat.(some Api.Response.pp_capture)
              err.capture))
  in

  Eio_main.run @@ fun env ->
  let http = Cohttp_eio.Client.make ~https:None env#net in
  Eio.Switch.run @@ fun sw -> response http ~sw