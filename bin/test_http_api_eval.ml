open Imandra_http_api_client

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

  let response =
    Log.debug (fun k -> k "Sending query to server...");
    let* result =
      Default_api.eval
        ~eval_request_src_t:
          {
            Eval_request_src.src = "let f x = x + 1";
            Eval_request_src.syntax = Some `Iml;
          }
    in
    Log.debug (fun k -> k "Shutting down server...");
    let* _ = Default_api.shutdown () in
    Lwt.return result
  in

  let response = Lwt_main.run response in
  Log.debug (fun k -> k "Received response %a..." Eval_response.pp response);
  Log.debug (fun k -> k "Terminating server...");
  process#kill 11
