module Client = Imandra_http_api_client

let tests (module Log : Logs.LOG) : unit Alcotest_lwt.test_case list =
  [
    Alcotest_lwt.test_case "Finding an instance x such that x+1>4." `Quick
      (fun _ () ->
        let open Lwt.Syntax in
        let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in

        let* response =
          let* () = Logs_lwt.debug (fun k -> k "Sending query to server...") in
          let* _ =
            Client.eval config
              { src = "let bla (x : int) = x + 1 "; syntax = Iml }
          in
          let* result =
            Client.instance_by_src config
              {
                src = "fun (x : int) -> bla x > 4";
                syntax = Iml;
                hints = None;
                instance_printer =
                  Some { name = "Z.sprint ()"; cx_var_name = "x" };
              }
          in
          Lwt.return result
        in
        match response with
        | Ok { body = I_sat { instance }; _ } ->
          let* () =
            Logs_lwt.debug (fun k ->
                k "Model string: %a" CCFormat.(string) instance.model.src)
          in
          Logs_lwt.debug (fun k ->
              k "Printed string: %a" CCFormat.(some string) instance.printed)
        | _ -> Logs_lwt.err (fun k -> k "Unexpected error."));
  ]
