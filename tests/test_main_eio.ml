open Client_tests

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local-eio"))

let suite ~client ~sw : unit Alcotest.test list =
  [
    "eval_eio", Evaluation_eio.tests (module Log) ~client ~sw;
    "instance_eio", Instance_eio.tests (module Log) ~client ~sw;
    "decomp_eio", Decompose_eio.tests (module Log) ~client ~sw;
    "verfication_eio", Verification_eio.tests (module Log) ~client ~sw;
  ]

let () =
  Logs.set_reporter
    (Logs_fmt.reporter ~app:Format.err_formatter ~dst:Format.err_formatter ());
  Logs.set_level (Some Logs.Debug);
  Eio_main.run @@ fun env ->
  let client = Cohttp_eio.Client.make ~https:None env#net in
  Eio.Switch.run @@ fun sw ->
  Alcotest.run ~verbose:false ~show_errors:false "imandra-http-api-client-eio"
    (suite ~client ~sw)
