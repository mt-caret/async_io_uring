io\_uring backend for Async. Currently only used for watching file descriptors
and very beta; expect lots of crashes.

build instructions (w/ OCaml 4.11.1, YMMV for other versions):

```
$ git clone --recursive https://github.com/mt-caret/async_io_uring
$ opam install dune dune-configurator ocaml-compiler-libs ocaml-migrate-parsetree octavius stdlib-shims
$ cd async_io_uring/io_uring_test
$ dune build --profile release @@default
$ ASYNC_CONFIG="((file_descr_watcher Io_uring))" ../_build/default/io_uring_test/echo_server_async.exe
```

currently, the following libraries have been forked w/ changes:

- core
- ppx\_sexp\_conv
- ppx\_expect
- ppx\_string
- ppx\_sexp\_message
- ppx\_custom\_printf
- ppx\_fields\_conv
- ppx\_optcomp
- async
- async\_kernel
- async\_unix

benchmarks:

currently, Async using the io\_uring backend seems to be a bit slower than the
epoll backend? tested using the command
`ab -n 100000 -c 10 http://localhost:8000/`.

epoll backend:
```
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       1
Processing:     0    1   1.6      1      21
Waiting:        0    1   1.5      1      21
Total:          0    1   1.6      1      21

Percentage of the requests served within a certain time (ms)
  50%      1
  66%      1
  75%      1
  80%      2
  90%      3
  95%      5
  98%      7
  99%      9
 100%     21 (longest request)
```

io\_uring backend:
```
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        0    0   0.0      0       1
Processing:     0    1   1.6      1      28
Waiting:        0    1   1.6      1      28
Total:          0    1   1.6      1      28

Percentage of the requests served within a certain time (ms)
  50%      1
  66%      1
  75%      1
  80%      2
  90%      3
  95%      5
  98%      6
  99%     10
 100%     28 (longest request)
```

todo:

- [ ] figure out above benchmarks
  - shot in the dark guess: allocation of a list in the critical path is the
    culprit? possibly return a immediate option?
- [ ] investigate ETIME in `io_uring_peek_cqe()`
