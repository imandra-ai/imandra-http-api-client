module Client = Imandra_http_api_client
module Api = Imandra_http_api_client.Api

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
  Unix.sleep 10;

  let config = Client.Config.make ~base_uri:"http://localhost:3000" () in

  let response =
    Log.debug (fun k -> k "Sending query to server...");
    let req : Api.Request.eval_req_src =
      { src = "let f x = x + 1"; syntax = Iml }
    in
    let* result = Client.eval config req in
    (match result with
    | Ok _ -> Log.app (fun k -> k "Got ok response")
    | Error _ -> Log.app (fun k -> k "Got error response"));
    Log.debug (fun k -> k "Shutting down server...");
    let* _ = Client.shutdown config () in
    Lwt.return ()
  in

  let () = Lwt_main.run response in
  Log.debug (fun k -> k "Terminating server...");
  process#kill 11
