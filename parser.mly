%{
open Compile

%}

%token <int> NUM
%token <string> ID
%token ADD1 SUB1 LPAREN RPAREN LET IN EQUAL COMMA PLUS MINUS TIMES IF COLON ELSECOLON EOF

%left PLUS MINUS TIMES



%type <Compile.expr> program

%start program

%%

const :
  | NUM { ENumber($1) }

prim1 :
  | ADD1 { Add1 }
  | SUB1 { Sub1 }

binds :
  | ID EQUAL expr { [($1, $3)] }
  | ID EQUAL expr COMMA binds { ($1, $3)::$5 }

binop_expr :
  | prim1 LPAREN expr RPAREN { EPrim1($1, $3) }
  | LPAREN expr RPAREN { $2 }
  | binop_expr PLUS binop_expr { EPrim2(Plus, $1, $3) }
  | binop_expr MINUS binop_expr { EPrim2(Minus, $1, $3) }
  | binop_expr TIMES binop_expr { EPrim2(Times, $1, $3) }
  | const { $1 }
  | ID { EId($1) }

expr :
  | LET binds IN expr { ELet($2, $4) }
  | IF expr COLON expr ELSECOLON expr { EIf($2, $4, $6) }
  | binop_expr { $1 }

program :
  | expr EOF { $1 }

%%
