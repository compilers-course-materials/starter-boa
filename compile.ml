open Printf

type reg =
  | EAX
  | ESP

type arg =
  | Const of int
  | Reg of reg
  | RegOffset of int * reg

type instruction =
  | IMov of arg * arg
  | IAdd of arg * arg
  | ISub of arg * arg
  | IMul of arg * arg
  | ILabel of string
  | ICmp of arg * arg
  | IJne of string
  | IJe of string
  | IJmp of string
  | IRet

type prim1 =
  | Add1
  | Sub1

type prim2 =
  | Plus
  | Minus
  | Times

type expr =
  | ELet of (string * expr) list * expr
  | EPrim1 of prim1 * expr
  | EPrim2 of prim2 * expr * expr
  | EIf of expr * expr * expr
  | ENumber of int
  | EId of string


type immexpr =
  | ImmNumber of int
  | ImmId of string

and cexpr =
  | CPrim1 of prim1 * immexpr
  | CPrim2 of prim2 * immexpr * immexpr
  | CIf of immexpr * aexpr * aexpr
  | CImmExpr of immexpr

and aexpr =
  | ALet of string * cexpr * aexpr
  | ACExpr of cexpr

let count = ref 0
let gen_temp base =
  count := !count + 1;
  sprintf "temp_%s_%d" base !count

let rec anf_k (e : expr) (k : immexpr -> aexpr) : aexpr =
  match e with
    | EPrim1(op, e) ->
      anf_k e (fun imm -> ACExpr(CPrim1(op, imm)))
    | ELet(binds, body) ->
      failwith "You need to do this one (let)"
    | EPrim2(op, left, right) ->
      failwith "You need to do this one (prim2)"
    | EIf(cond, thn, els) ->
      let tmp = gen_temp "if" in
      let ret = (fun imm -> ACExpr(CImmExpr(imm))) in
      anf_k cond (fun immcond ->
        ALet(tmp, CIf(immcond, anf_k thn ret, anf_k els ret), k(ImmId(tmp))))
    | ENumber(n) ->
      k(ImmNumber(n))
    | EId(name) ->
      failwith "You need to do this one (id)"

let anf (e : expr) : aexpr =
  anf_k e (fun imm -> ACExpr(CImmExpr(imm)))

let r_to_asm (r : reg) : string =
  match r with
    | EAX -> "eax"
    | ESP -> "esp"

let arg_to_asm (a : arg) : string =
  match a with
    | Const(n) -> sprintf "%d" n
    | Reg(r) -> r_to_asm r
    | RegOffset(n, r) ->
      if n >= 0 then
        sprintf "[%s+%d]" (r_to_asm r) n
      else
        sprintf "[%s-%d]" (r_to_asm r) (-1 * n)

let i_to_asm (i : instruction) : string =
  match i with
    | IMov(dest, value) ->
      sprintf "  mov %s, %s" (arg_to_asm dest) (arg_to_asm value)
    | IAdd(dest, to_add) ->
      sprintf "  add %s, %s" (arg_to_asm dest) (arg_to_asm to_add)
    | ISub(dest, to_sub) ->
      sprintf "  sub %s, %s" (arg_to_asm dest) (arg_to_asm to_sub)
    | IMul(dest, to_mul) ->
      sprintf "  imul %s, %s" (arg_to_asm dest) (arg_to_asm to_mul)
    | ICmp(left, right) ->
      failwith "You need to do this one (cmp)"
    | ILabel(name) ->
      failwith "You need to do this one (label)"
    | IJne(label) ->
      failwith "You need to do this one (jne)"
    | IJe(label) ->
      failwith "You need to do this one (jne)"
    | IJmp(label) ->
      failwith "You need to do this one (jmp)"
    | IRet ->
      " ret"

let to_asm (is : instruction list) : string =
  List.fold_left (fun s i -> sprintf "%s\n%s" s (i_to_asm i)) "" is

let rec find ls x =
  match ls with
    | [] -> None
    | (y,v)::rest ->
      if y = x then Some(v) else find rest x

let acompile_imm_arg (i : immexpr) _ (env : (string * int) list) : arg =
  match i with
    | ImmNumber(n) -> Const(n)
    | ImmId(name) ->
      failwith "You need to do this one (compiled id)"

let acompile_imm (i : immexpr) (si : int) (env : (string * int) list) : instruction list =
  [ IMov(Reg(EAX), acompile_imm_arg i si env) ]

let rec acompile_step (s : cexpr) (si : int) (env : (string * int) list) : instruction list =
  match s with
    | CImmExpr(i) -> acompile_imm i si env
    | CPrim1(op, e) ->
      let prelude = acompile_imm e si env in
      begin match op with
        | Add1 ->
          prelude @ [
            IAdd(Reg(EAX), Const(1))
          ]
        | Sub1 ->
          prelude @ [
            IAdd(Reg(EAX), Const(-1))
          ]
      end
    | CPrim2(op, left, right) ->
      failwith "You need to do this one (compile prim2)"
    | CIf(cond, thn, els) ->
      failwith "You need to do this one (compile if)"

and acompile_expr (e : aexpr) (si : int) (env : (string * int) list) : instruction list =
  match e with
    | ALet(id, e, body) ->
      let prelude = acompile_step e (si + 1) env in
      let body = acompile_expr body (si + 1) ((id, si)::env) in
      prelude @ [
        IMov(RegOffset(-4 * si, ESP), Reg(EAX))
      ] @ body
    | ACExpr(s) -> acompile_step s si env

let compile_anf_to_string anfed =
  begin
    count := 0;
    let prelude =
      "section .text
  global our_code_starts_here
  our_code_starts_here:" in
    let compiled = (acompile_expr anfed 1 []) in
    let as_assembly_string = (to_asm (compiled @ [IRet])) in
    sprintf "%s%s\n" prelude as_assembly_string
  end


let compile_to_string prog =
  let anfed = anf prog in
  compile_anf_to_string anfed

