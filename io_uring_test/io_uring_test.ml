open Core
open Async

let () =
  let _io_uring = Linux_ext.Io_uring.create ~entries:(Int63.of_int 100) in
  printf "Hello, world!"
