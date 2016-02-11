open Compile
open Printf

let rec intersperse (elts : 'a list) (sep : 'a) : 'a list =
  match elts with
    | [] -> []
    | [elt] -> [sep; elt]
    | elt::rest -> elt::sep::(intersperse rest sep)

let string_of_op1 op =
  match op with
    | Add1 -> "add1"
    | Sub1 -> "sub1"

let string_of_op2 op =
  match op with
    | Plus -> "+"
    | Minus -> "-"
    | Times -> "*"
  

let rec string_of_expr (e : expr) : string =
  match e with
    | ENumber(n) -> string_of_int n
    | EId(x) -> x
    | EPrim1(op, e) ->
      sprintf "%s(%s)" (string_of_op1 op) (string_of_expr e)
    | EPrim2(op, left, right) ->
      sprintf "(%s %s %s)" (string_of_expr left) (string_of_op2 op) (string_of_expr right)
    | ELet(binds, body) ->
      let binds_strs = List.map (fun (x, e) -> sprintf "%s = %s" x (string_of_expr e)) binds in
      let binds_str = List.fold_left (^) "" (intersperse binds_strs ", ") in
      sprintf "(let %s in %s)" binds_str (string_of_expr body)
    | EIf(cond, thn, els) ->
      sprintf "(if %s: %s else: %s)"
        (string_of_expr cond)
        (string_of_expr thn)
        (string_of_expr els)
      

let string_of_immexpr (ie : immexpr) : string =
  match ie with
    | ImmNumber(n) -> string_of_int n
    | ImmId(x) -> x

let rec string_of_cexpr (ce : cexpr) : string =
  match ce with
    | CPrim1(op, e) ->
      sprintf "%s(%s)" (string_of_op1 op) (string_of_immexpr e)
    | CPrim2(op, left, right) ->
      sprintf "(%s %s %s)" (string_of_immexpr left) (string_of_op2 op) (string_of_immexpr right)
    | CIf(cond, thn, els) ->
      sprintf "(if %s: %s else: %s)"
        (string_of_immexpr cond)
        (string_of_aexpr thn)
        (string_of_aexpr els)
    | CImmExpr(ie) -> string_of_immexpr ie

and string_of_aexpr (ae : aexpr) : string =
  match ae with
    | ALet(x, e, body) ->
      sprintf "(let %s = %s in %s)" x (string_of_cexpr e) (string_of_aexpr body)
    | ACExpr(e) ->
      string_of_cexpr(e)

