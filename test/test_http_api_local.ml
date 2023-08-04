open Imandra_http_api_client

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

(* let process =
   Lwt_process.open_process_full
     ("/usr/local/bin/imandra-http-api", [| "--skip-update" |]) *)

let foo =
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Debug);
  Log.debug (fun k -> k "Starting server...");
  Lwt_process.open_process_full
    ("/usr/local/bin/imandra-http-api", [| "--skip-update" |])

let () =
  let response =
    Log.debug (fun k -> k "Sending query to server...");
    Default_api.eval
      ~eval_request_src_t:
        {
          Eval_request_src.src = "let f x = x + 1";
          Eval_request_src.syntax = Some `Iml;
        }
  in
  let _ = Lwt_main.run response in
  ();
  Log.debug (fun k -> k "Terminating server...")
