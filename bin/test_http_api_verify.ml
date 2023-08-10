open Imandra_http_api_client

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
  Unix.sleep 20;

  let response =
    Log.debug (fun k -> k "Sending query to server...");
    let* _ =
      Default_api.eval
        ~eval_request_src_t:
          {
            Imandra_http_api_client__Eval_request_src.src =
              "let foo (x : int) = x + 1 ";
            Imandra_http_api_client__Eval_request_src.syntax = Some `Iml;
          }
    in
    let* result =
      Default_api.verify_by_src
        ~verify_request_src_t:
          {
            Verify_request_src.src = "fun x -> List.rev (List.rev x) = x";
            Verify_request_src.syntax = Some `Iml;
            Verify_request_src.hints =
              Some
                {
                  Imandra_http_api_client__Hints._method =
                    {
                      Imandra_http_api_client__Model_method._type = `Auto;
                      Imandra_http_api_client__Model_method.body = None;
                    };
                };
            Verify_request_src.instance_printer = None;
          }
    in
    Log.debug (fun k -> k "Shutting down server...");
    let* _ = Default_api.shutdown () in
    Lwt.return result
  in
  let response = Lwt_main.run response in
  Log.debug (fun k -> k "Received response %a..." Yojson.Safe.pp response);
  Log.debug (fun k -> k "Terminating server...");
  process#kill 11
