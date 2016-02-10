open Compile
open Runner
open Printf
open OUnit2

let is_osx = Conf.make_bool "osx" false "Set this flag to run on osx";;
let t name program expected = name>::test_run program name expected;;

let forty_one = "sub1(42)";;


let suite =
"suite">:::
 [t "forty_one" forty_one "41";
  ]
;;


let () =
  run_test_tt_main suite
;;
