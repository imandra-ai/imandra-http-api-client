open Client_tests

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let suite : unit Alcotest_lwt.test list =
  [
    "eval", Evaluation.tests (module Log);
    "verfication", Verification.tests (module Log);
    "instance", Instance.tests (module Log);
    "decomp", Decompose.tests (module Log);
  ]

let lwt_reporter () =
  let buf_fmt ~like =
    let b = Buffer.create 512 in
    ( Fmt.with_buffer ~like b,
      fun () ->
        let m = Buffer.contents b in
        Buffer.reset b;
        m )
  in
  let app, app_flush = buf_fmt ~like:Fmt.stdout in
  let dst, dst_flush = buf_fmt ~like:Fmt.stderr in
  let reporter = Logs_fmt.reporter ~app ~dst () in
  let report src level ~over k msgf =
    let k () =
      let write () =
        match level with
        | Logs.App -> Lwt_io.write Lwt_io.stdout (app_flush ())
        | _ -> Lwt_io.write Lwt_io.stderr (dst_flush ())
      in
      let unblock () =
        over ();
        Lwt.return_unit
      in
      Lwt.finalize write unblock |> Lwt.ignore_result;
      k ()
    in
    reporter.Logs.report src level ~over:(fun () -> ()) k msgf
  in
  { Logs.report }

let () =
  Logs.set_reporter (lwt_reporter ());
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
