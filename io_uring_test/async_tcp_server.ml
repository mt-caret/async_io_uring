open Core
open Async

let resp = "HTTP/1.0 200 OK\n\n"

let handle_connection inet_addr reader writer =
  let buf = Bytes.make 1024 '_' in
  let%map (_ : [ `Eof | `Ok of int ]) = Reader.read reader buf in
  Writer.write writer resp
;;

let () =
  Command.run
  @@ Command.async ~summary:"async tcp server"
  @@ let%map_open.Command port =
       flag "port" (optional_with_default 8000 int) ~doc:"PORT port to listen on"
     in
     fun () ->
       let server =
         Tcp.Server.create_inet
           ~on_handler_error:
             (`Call
               (fun inet_addr exn ->
                 raise_s
                   [%message
                     "error handling connection"
                       (inet_addr : Socket.Address.Inet.t)
                       (exn : exn)]))
           (Tcp.Where_to_listen.of_port port)
           handle_connection
       in
       Tcp.Server.close_finished_and_handlers_determined server
;;
