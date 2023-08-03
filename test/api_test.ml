open Imandra_http_api_client

module Fmt = CCFormat 
let () = 
  let eval_request = Default_api.eval ~eval_request_src_t:{
  Eval_request_src.src = "let h x = x + 1";
  Eval_request_src.syntax = Some `Iml
} in 
let response = Lwt_main.run eval_request in 
Fmt.printf "@[%a@.@]" Eval_response.pp response