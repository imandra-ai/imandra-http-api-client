module Client = Imandra_http_api_client

let tests (module Log : Logs.LOG) : unit Alcotest_lwt.test_case list =
  [
    Alcotest_lwt.test_case "Proving List.rev (List.rev x) = x." `Quick
      (fun _ () ->
        let open Lwt.Syntax in
        let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in
        let* result =
          let* () = Logs_lwt.debug (fun k -> k "Sending query to server...") in
          let* _ =
            Client.eval config
              { src = "let foo (x : int) = x + 1 "; syntax = Iml }
          in
          let* result =
            Client.verify_by_src config
              {
                src = "fun x -> List.rev (List.rev x) = x";
                syntax = Iml;
                hints = Some { method_ = Auto };
                instance_printer = None;
              }
          in
          Lwt.return result
        in
        match result with
        | Ok { body = V_proved; _ } -> Logs_lwt.debug (fun k -> k "Proved!")
        | _ -> Logs_lwt.err (fun k -> k "Unexpected error."));
  ]
