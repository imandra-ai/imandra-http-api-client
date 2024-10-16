module Client = Imandra_http_api_client
module Api = Imandra_http_api_client.Api

let () = Printexc.record_backtrace true

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let () =
  let open Lwt.Syntax in
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Debug);
  let process =
    Log.debug (fun k -> k "Starting server...");
    Lwt_process.open_process_full
      ( "/usr/local/bin/imandra-http-api",
        [| "/usr/local/bin/imandra-http-api"; "--skip-update" |] )
  in
  Log.debug (fun k -> k "Server started with PID %d..." process#pid);
  (* Unix.sleep 120 *)
  Unix.sleep 10;

  let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in

  let response =
    Log.debug (fun k -> k "Sending query to server...");
    let* _ =
      Client.eval config { src = "let foo (x : int) = x + 1 "; syntax = Iml }
    in
    let* result =
      Client.instance_by_src config
        {
          src = "fun (x : int) -> foo x > 4";
          syntax = Iml;
          hints = None;
          instance_printer = Some { name = "Z.sprint ()"; cx_var_name = "x" };
          reflect = true;
        }
    in
    Log.debug (fun k -> k "Shutting down server...");
    let* _ = Client.shutdown config () in
    Lwt.return result
  in
  let response = Lwt_main.run response in

  (match response with
  | Ok { body = I_sat { instance }; _ } ->
    Log.debug (fun k ->
        k "Model string: %a" CCFormat.(string) instance.model.src);
    Log.debug (fun k ->
        k "Printed string: %a" CCFormat.(some string) instance.printed)
  | _ -> Log.err (fun k -> k "Unexpected response"));
  Log.debug (fun k -> k "Terminating server...");
  process#kill 11
