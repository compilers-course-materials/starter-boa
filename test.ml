open Compile
open Runner
open Printf
open OUnit2

let is_osx = Conf.make_bool "osx" false "Set this flag to run on osx";;

let t name program expected = name>::test_run program name expected;;

let ta name program expected = name>::test_run_anf program name expected;;

let te name program expected_err = name>::test_err program name expected_err;;

let tanf name program expected = name>::fun _ ->
  assert_equal (anf program) expected;;

let forty_one = "sub1(42)";;

let forty_one_a = ACExpr(CPrim1(Sub1, ImmNumber(42)));;


let suite =
"suite">:::
 [

  tanf "forty_one_anf"
       (EPrim1(Sub1, ENumber(42)))
       forty_one_a;

  ta "forty_one_run_anf" forty_one_a "41";
 
  t "forty_one" forty_one "41";



(* I would start by making these tests work 
  t "if1" "if 5: 4 else: 2" "4";
  t "if1" "if 0: 4 else: 2" "2";
  *)
  ]
;;


let () =
  run_test_tt_main suite
;;
