# Boa

![A boa](https://upload.wikimedia.org/wikipedia/commons/9/90/Boa_constrictor%2C_Va%C5%88kovka%2C_Brno_%282%29.jpg)

In this assignment you'll implement a small language called Boa, which has
**b**inary **o**per**a**tors and conditionals. You'll use an A-Normal Form
conversion to make binary operator compilation easy, and compile if via `jmp`
instructions.

## The Boa Language

As usual, there are a few pieces that go into defining a language for us to
compile.

- A description of the concrete syntax – the text the programmer writes

- A description of the abstract syntax – how to express what the
  programmer wrote in a data structure our compiler uses.

- The _semantics_—or description of the behavior—of the abstrac
  syntax, so our compiler knows what the code it generates should do.


In boa, the second step is broken up into two:

- A description of the user-facing abstract syntax – how to express what the
  programmer wrote in a data structure our compiler uses, translated directly
  from the concrete syntax.

- A description of the compiler-facing abstract syntax – in this case, the
  `aexpr`, `cexpr`, and `immexpr` datatypes, which are translated from the
  user-facing abstract syntax.

### Concrete Syntax

The concrete syntax of Boa is:

```
<expr> :=
  | let <bindings> in <expr>
  | if <expr>: <expr> else: <expr>
  | <binop-expr>

<binop-expr> :=
  | <number>
  | <identifier>
  | add1(<expr>)
  | sub1(<expr>)
  | <expr> + <expr>
  | <expr> - <expr>
  | <expr> * <expr>
  | ( <expr> )

<bindings> :=
  | <identifier> = <expr>
  | <identifier> = <expr>, <bindings>
}
```

As in Adder, a `let` expression can have one _or more_ bindings.


### Abstract Syntax

#### User-facing

The abstract syntax of Boa is an OCaml datatype, and corresponds nearly
one-to-one with the concrete syntax.  Here, we've added `E` prefixes to the
constructors, which will distinguish them from the ANF forms later.

```
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
```

#### Compiler-facing

The compiler-facing abstract syntax of Boa splits the above expressions into
three categories

```
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
```


### Semantics

Numbers, unary operators, let-bindings, and ids have the same semantics as
before.  Binary operator expressions evaluate their arguments and combine them
based on the operator.  If expressions behave similarly to if statements in C:
first, the conditional (first part) is evaluated.  If it is not `0`, the else
branch is evaluated.  Otherwise, the then branch is evaluated.

### Examples

```
sub1(5)

# as an expr

EPrim1(Add1, ENum(5))

# evaluates to

4
```

```
if 5 - 5: 6 else: 8

# as an expr

EIf(EPrim2(Minus, ENum(5), ENum(5)), ENum(6), ENum(8))

# evaluates to

8
```

```
let x = 10, y = 9 in
if (x - y) * 2: x else: y

# as an expr

ELet([("x", ENum(10)), ("y", ENum(9))],
  EIf(EPrim2(Times, EPrim2(Minus, EId("x"), EId("y")), ENum(2)),
      EId("x"),
      EId("y")))
```


### New Assembly Instructions

As usual, full summaries of the instructions we use are at [this assembly
guide](http://www.cs.virginia.edu/~evans/cs216/guides/x86.html).
