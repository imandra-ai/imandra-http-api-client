module Client = Imandra_http_api_client

let tests (module Log : Logs.LOG) : unit Alcotest_lwt.test_case list =
  [
    Alcotest_lwt.test_case "Evaluating let f x = x + 1." `Quick (fun _ () ->
        let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in

        Log.debug (fun k -> k "Sending query to server...");
        let req : Client.Api.Request.eval_req_src =
          { src = "let f x = x + 1"; syntax = Iml }
        in
        let open Lwt.Syntax in
        let* result = Client.eval config req in
        (match result with
        | Ok _ -> Log.app (fun k -> k "Got ok response")
        | Error _ -> Log.app (fun k -> k "Got error response"));
        Lwt.return ());
  ]
