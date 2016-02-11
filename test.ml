open Compile
open Runner
open Printf
open OUnit2
open Pretty

let is_osx = Conf.make_bool "osx" false "Set this flag to run on osx";;

let t name program expected = name>::test_run program name expected;;

let ta name program expected = name>::test_run_anf program name expected;;

let te name program expected_err = name>::test_err program name expected_err;;

let tanf name program expected = name>::fun _ ->
  assert_equal (anf program) expected ~printer:string_of_aexpr;;

let forty_one = "41";;

let forty_one_a = ACExpr(CImmExpr(ImmNumber(41)));;


let suite =
"suite">:::
 [

  tanf "forty_one_anf"
       (ENumber(41))
       forty_one_a;

  tanf "prim1_anf"
       (EPrim1(Sub1, ENumber(55)))
       (ALet("temp_unary_1", CPrim1(Sub1, ImmNumber(55)),
          ACExpr(CImmExpr(ImmId("temp_unary_1")))));

  ta "forty_one_run_anf" forty_one_a "41";
 
  t "forty_one" forty_one "41";



(* Some useful if tests to start you off

  t "if1" "if 5: 4 else: 2" "4";
  t "if2" "if 0: 4 else: 2" "2";

  *)
  ]
;;


let () =
  run_test_tt_main suite
;;
