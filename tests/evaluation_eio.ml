open Imandra_http_api_client

let tests (module Log : Logs.LOG) ~client ~sw : unit Alcotest.test_case list =
  [
    Alcotest.test_case "Evaluating let f x = x + 1." `Quick (fun () ->
        let config =
          Main_eio.Config.make ~base_uri:"http://127.0.0.1:3000" ()
        in
        Log.debug (fun k -> k "Turning redef on...");
        let redef : Api.Request.eval_req_src =
          { src = "#redef"; syntax = Iml }
        in
        let _ = Main_eio.eval config redef ~sw ~client in
        Log.debug (fun k -> k "Sending query to server...");
        let req : Api.Request.eval_req_src =
          { src = "let goo x = x + 1"; syntax = Iml }
        in
        let result = Main_eio.eval config req ~client ~sw in
        let ok =
          Logs.on_error ~pp:Main.handle_error
            ~use:(fun _err -> failwith "failed")
            result
        in
        Log.debug (fun k ->
            k "Got ok response: %a"
              CCFormat.(some Api.Response.pp_capture)
              ok.capture));
    Alcotest.test_case "Getting status" `Quick (fun () ->
        let config =
          Main_eio.Config.make ~base_uri:"http://127.0.0.1:3000" ()
        in
        Log.debug (fun k -> k "Sending query to server...");
        let result = Main_eio.get_status config ~client ~sw in
        let ok =
          Logs.on_error ~pp:Main.handle_error
            ~use:(fun _err -> failwith "failed")
            result
        in
        Log.debug (fun k -> k "Got ok response: %s" ok));
  ]
