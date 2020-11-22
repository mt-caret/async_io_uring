open Core

let rec recv_loop ~buf ~client_socket_fd =
  let num_bytes_read =
    Unix.recv client_socket_fd ~buf ~pos:0 ~len:(Bytes.length buf) ~mode:[]
  in
  if num_bytes_read > 0
  then (
    let num_bytes_sent =
      Unix.send client_socket_fd ~buf ~pos:0 ~len:num_bytes_read ~mode:[]
    in
    if num_bytes_sent > 0
    then (
      let str = Bytes.sub buf 0 num_bytes_read |> Bytes.to_string in
      print_string [%string "read: %{str}"];
      if String.is_substring str ~substring:"bye"
      then Unix.close client_socket_fd
      else recv_loop ~buf ~client_socket_fd))
;;

let rec naive_accept_loop ~socket_fd =
  let client_socket_fd, client_socket_address = Unix.accept socket_fd in
  print_s
    [%message
      "client connected"
        (client_socket_fd : Unix.File_descr.t)
        (client_socket_address : Unix.sockaddr)];
  let buf = Bytes.make 1024 '_' in
  recv_loop ~buf ~client_socket_fd;
  naive_accept_loop ~socket_fd
;;

let () =
  let port = 8000 in
  let socket_fd = Unix.socket ~domain:PF_INET ~kind:SOCK_STREAM ~protocol:0 () in
  Unix.bind socket_fd ~addr:(ADDR_INET (Unix.Inet_addr.bind_any, port));
  Unix.listen socket_fd ~backlog:0;
  print_endline [%string "listening on port %{port#Int}"];
  naive_accept_loop ~socket_fd
;;
