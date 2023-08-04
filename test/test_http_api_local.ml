(* open Imandra_http_api_client  *)

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let setup_logs =
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Debug)

let () =
  let http_api =
    Log.debug (fun k -> k "Starting Http Api Process...");
    new Lwt_process.process_full
      ("/usr/local/bin/imandra-http-api", [| "--skip-update" |])
  in
  match http_api#state with
  | Running ->
    Log.debug (fun k -> k "Process running...")
    (* Log.debug (fun k -> k "Terminating Http Api Process.."); *)
    (* http_api#terminate) *)
  | _ -> ()
