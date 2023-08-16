module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug)

let eval_test : unit Alcotest_lwt.test_case list =
  [
    Alcotest_lwt.test_case "let f x = x + 1" `Quick (fun _ () ->
        let config =
          let open Imandra_http_api_client in
          Config.make ~base_uri:"http://localhost:3000" ()
        in

        Log.debug (fun k -> k "Sending query to server...");
        let req : Imandra_http_api_client.Api.Request.eval_req_src =
          { src = "let f x = x + 1"; syntax = Iml }
        in
        let open Lwt.Syntax in
        let* result = Imandra_http_api_client.eval config req in
        (match result with
        | Ok _ -> Log.app (fun k -> k "Got ok response")
        | Error _ -> Log.app (fun k -> k "Got error response"));
        Log.debug (fun k -> k "Shutting down server...");
        let* _ = Imandra_http_api_client.shutdown config () in
        Lwt.return ());
  ]

let suite : unit Alcotest_lwt.test list = [ "eval", eval_test ]

let () =
  let process =
    Log.debug (fun k -> k "Starting server...");
    Lwt_process.open_process_full
      ( "/usr/local/bin/imandra-http-api",
        [| "/usr/local/bin/imandra-http-api"; "--skip-update" |] )
  in
  Log.debug (fun k -> k "Server started with PID %d..." process#pid);
  Unix.sleep 10;
  Lwt_main.run
  @@
  (Lwt_main.at_exit (fun () ->
       Log.debug (fun k -> k "Terminating server...");
       Lwt.return @@ process#kill 11);
   Alcotest_lwt.run "imandra-http-api-client" suite)
