open Imandra_http_api_client

let tests (module Log : Logs.LOG) ~client ~sw : unit Alcotest.test_case list =
  [
    Alcotest.test_case "Proving List.rev (List.rev x) = x." `Quick (fun () ->
        let config =
          Main_eio.Config.make ~base_uri:"http://127.0.0.1:3000" ()
        in
        Log.debug (fun k -> k "Turning redef on...");
        let redef : Api.Request.eval_req_src =
          { src = "#redef"; syntax = Iml }
        in
        let _ = Main_eio.eval config redef ~sw ~client in
        Log.debug (fun k -> k "Sending query to server...");
        let result =
          Main_eio.verify_by_src config ~client ~sw
            {
              src = "fun x -> List.rev (List.rev x) = x";
              syntax = Iml;
              hints = Some { method_ = Auto };
              instance_printer = None;
            }
        in
        let ok =
          Logs.on_error ~pp:Main.handle_error
            ~use:(fun _err -> failwith "failed")
            result
        in
        Log.debug (fun k ->
            k "Got ok response: %a"
              CCFormat.(some Api.Response.pp_capture)
              ok.capture));
  ]
