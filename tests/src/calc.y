%expect 0

%define api.parser.struct { Parser }
%define api.location.type { Loc }
%define api.value.type { Value }

%define parse.error custom
%define parse.trace


%code use {
  // all use goes here
}

%code parser_fields {
  result: Option<String>,
}

%code {
  // code
}


/* Bison Declarations */
%token
    BANG   "!"
    PLUS   "+"
    MINUS  "-"
    STAR   "*"
    SLASH  "/"
    CARET  "^"
    LPAREN "("
    RPAREN ")"
    EQUAL  "="
    EOL    _("end of line")
  <String>
    NUM    _("number")
%type <Expr> exp input line program

%nonassoc "="       /* comparison            */
%left "-" "+"
%left "*" "/"
%precedence NEG     /* negation--unary minus */
%right "^"          /* exponentiation        */

/* Grammar follows */
%%
program:
  input { self.result = Some($<Expr>1.clone()); $$ = Value::None; }
;

input:
  line { $$ = $1; }
| input line { $$ = $2; }
;

line:
  EOL                { $$ = Value::Expr("EOL".to_owned()); }
| exp EOL            { let exp = $<Expr>1; println!("{:#?}", exp); $$ = Value::Expr(exp); }
| error EOL          { println!("err recovery"); $$ = Value::Expr("ERR".to_owned()) }
;

exp:
  NUM                { $$ = Value::Expr($<Token>1.to_string_lossy()) }
| exp "=" exp {
      if $<Expr>1 != $<Expr>3 {
          self.yyerror(&@$, &format!("calc: error: {:#?} != {:#?}", $1, $3));
      }
      $$ = Value::Expr("err".to_owned());
  }
| exp "+" exp        { $$ = Value::Expr(format!("{:#?} + {:#?}", $<Expr>1, $<Expr>3)); }
| exp "-" exp        { $$ = Value::Expr(format!("{:#?} - {:#?}", $<Expr>1, $<Expr>3)); }
| exp "*" exp        { $$ = Value::Expr(format!("{:#?} * {:#?}", $<Expr>1, $<Expr>3)); }
| exp "/" exp        { $$ = Value::Expr(format!("{:#?}/+ {:#?}", $<Expr>1, $<Expr>3)); }
| "-" exp  %prec NEG { $$ = Value::Expr(format!("-{:#?}", $<Expr>2)); }
| exp "^" exp        { $$ = Value::Expr(format!("{:#?} ^ {:#?}", $<Expr>1, $<Expr>3)); }
| "(" exp ")"        { $$ = Value::Expr(format!("({:#?})", $<Expr>2)); }
| "(" error ")"      { $$ = Value::Expr(format!("(err)")); }
| "!"                { return Self::YYERROR; }
| "-" error          { return Self::YYERROR; }
;

%%

type Expr = String;

#[derive(Clone)]
pub enum Value {
    None,
    Stolen,
    Token(Token),
    Expr(Expr)
}

impl Value {
    pub fn from_token(value: Token) -> Self {
        Self::Token(value)
    }
}

impl From<Value> for Token {
    fn from(value: Value) -> Token {
        match value {
            Value::Token(v) => v,
            other => panic!("expected Token, got {:?}", other),
        }
    }
}

impl From<Value> for Expr {
    fn from(value: Value) -> Expr {
        match value {
            Value::Expr(v) => v,
            other => panic!("expected TokenValue, got {:?}", other),
        }
    }
}

impl std::fmt::Debug for Value {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result { //'
        match self {
            Value::None => f.write_str("Token::None"),
            Value::Stolen => f.write_str("Token::Stolen"),
            Value::Token(token) => f.write_fmt(format_args!("Token::Token({:?})", token)),
            Value::Expr(expr) => f.write_fmt(format_args!("Token::Expr({})", expr))
        }
    }
}

impl Parser {
    pub fn new(lexer: Lexer) -> Self {
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            yydebug: 0,
            yyerrstatus_: 0,
            yylexer: lexer,
            result: None
        }
    }

    pub fn do_parse(mut self) -> Option<String> {
        self.parse();
        self.result
    }

    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }
}

#[derive(Debug)]
pub struct Lexer {
    tokens: Vec<Token>
}

impl Lexer {
    pub fn new(tokens: Vec<Token>) -> Self {
        Self { tokens }
    }

    fn yylex(&mut self) -> Token {
        self.tokens.remove(0)
    }

    fn report_syntax_error(&self, ctx: &Context) {
        eprintln!("{:#?}", ctx)
    }

    fn yyerror(&mut self, loc: &Loc, msg: &str) {
        eprintln!("{:#?} {:#?}", loc, msg)
    }
}
