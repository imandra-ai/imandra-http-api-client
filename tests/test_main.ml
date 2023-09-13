open Client_tests

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let suite : unit Alcotest_lwt.test list =
  [
    "eval", Evaluation.tests (module Log);
    "verfication", Verification.tests (module Log);
    "instance", Instance.tests (module Log);
    "decomp", Decompose.tests (module Log);
  ]

let () =
  Logs.set_reporter (Logs_fmt.reporter ());
  Logs.set_level (Some Logs.Debug);
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
  (Lwt_main.at_exit (fun () -> Lwt.return @@ process#kill 11);
   Alcotest_lwt.run "imandra-http-api-client" suite)
