module Client = Imandra_http_api_client

let tests (module Log : Logs.LOG) : unit Alcotest_lwt.test_case list =
  [
    Alcotest_lwt.test_case "Region decomp." `Quick (fun _ () ->
        let open Lwt.Syntax in
        let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in

        let* response =
          let* () = Logs_lwt.debug (fun k -> k "Sending query to server...") in
          let* _ =
            Client.eval config
              { src = "let boo (x : int) = x > 1 "; syntax = Iml }
          in
          let* result =
            Client.decompose config
              {
                Imandra_http_api_client__Api.Request.name = "boo";
                Imandra_http_api_client__Api.Request.assuming = None;
                Imandra_http_api_client__Api.Request.prune = true;
                Imandra_http_api_client__Api.Request.max_rounds = None;
                Imandra_http_api_client__Api.Request.stop_at = None;
              }
          in
          let* () = Logs_lwt.debug (fun k -> k "Shutting down server...") in
          let* _ = Client.shutdown config () in
          Lwt.return result
        in
        match response with
        | Ok { body = decomp; _ } ->
          Logs_lwt.debug (fun k ->
              k "Decomp region AST: %a"
                CCFormat.(list Yojson.Basic.pp)
                CCList.(
                  let+ x = decomp.regions in
                  x.ast_json))
        | _ -> Logs_lwt.err (fun k -> k "Unexpected error."));
  ]
