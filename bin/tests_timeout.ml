module Client = Imandra_http_api_client
module Api = Imandra_http_api_client.Api

let () = Printexc.record_backtrace true

module Log = (val Logs.src_log (Logs.Src.create "imandra-http-api-local"))

let fold_l f acc xs =
  let rec loop acc = function
    | [] -> Lwt_result.return acc
    | x :: xs ->
      let open Lwt_result.Infix in
      f acc x >>= fun acc -> loop acc xs
  in
  loop acc xs

let () =
  let open Lwt.Syntax in
  Logs.set_reporter (Logs.format_reporter ());
  Logs.set_level (Some Logs.Debug);
  let process =
    Log.debug (fun k -> k "Starting server...");
    Lwt_process.open_process_full
      ( "/usr/local/bin/imandra-http-api",
        [| "/usr/local/bin/imandra-http-api"; "--skip-update" |] )
  in
  Log.debug (fun k -> k "Server started with PID %d..." process#pid);
  Unix.sleep 10;

  let config = Client.Config.make ~base_uri:"http://127.0.0.1:3000" () in

  let response =
    Log.debug (fun k -> k "Sending query to server...");
    let* res = Client.eval config { src = "#redef"; syntax = Iml } in
    let* result =
      match res with
      | Ok res ->
        fold_l
          (fun _ x -> Client.eval config { src = x; syntax = Iml })
          res
          (CCList.repeat 1000
             [
               {|let str = Imandra_util.Util.gensym() in Imandra.eval_string (CCFormat.sprintf "let %s x = x + 1" str)|};
             ])
      | Error err -> Lwt_result.fail err
    in
    Log.debug (fun k -> k "Shutting down server...");
    let* _ = Client.shutdown config () in
    Lwt.return result
  in
  let response = Lwt_main.run response in
  (match response with
  | Ok { body = { success = true }; _ } -> Log.debug (fun k -> k "Done!")
  | _ -> Log.err (fun k -> k "Unexpected response"));
  Log.debug (fun k -> k "Terminating server...");
  process#kill 11
