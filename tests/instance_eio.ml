open Imandra_http_api_client

let tests (module Log : Logs.LOG) ~client ~sw : unit Alcotest.test_case list =
  [
    Alcotest.test_case "Finding an instance x such that x+1>4." `Quick
      (fun () ->
        let config = Config.make ~base_uri:"http://127.0.0.1:3000" () in
        Log.debug (fun k -> k "Turning redef on...");
        let redef : Api.Request.eval_req_src =
          { src = "#redef"; syntax = Iml }
        in
        let _ = Eio.eval config redef ~sw ~client in
        Log.debug (fun k -> k "Sending query to server...");
        let req : Api.Request.eval_req_src =
          { src = "let goo x = x + 1"; syntax = Iml }
        in
        let _ = Eio.eval config req ~sw ~client in
        let result =
          Eio.instance_by_src config ~client ~sw
            {
              src = "fun (x : int) -> goo x > 4";
              syntax = Iml;
              hints = None;
              instance_printer =
                Some { name = "Z.sprint ()"; cx_var_name = "x" };
            }
        in
        let ok =
          Logs.on_error ~pp:handle_error
            ~use:(fun _err -> failwith "failed")
            result
        in
        Log.debug (fun k ->
            k "Got ok response: %a"
              CCFormat.(some Api.Response.pp_capture)
              ok.capture));
  ]
