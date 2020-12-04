%expect 0

%define api.parser.struct {Parser}
%define api.parser.generic {<'a> /*'*/}
%define api.location.type {Loc}
%define api.value.type {Value}

%define parse.error custom
%define parse.trace


%code use {
  // all use goes here
}

%code parser_fields {
  result: Option<String>,
  pub name: &'a str, /*'*/
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
  input { self.result = Some($<Expr>1.value); $$ = Value::None; }
;

input:
  line { $$ = $1; }
| input line { $$ = $2; }
;

line:
  EOL                { $$ = Value::new_expr("EOL".to_owned()); }
| exp EOL            { let exp = $<Expr>1; println!("{}", exp.value); $$ = Value::Expr(exp); }
| error EOL          { println!("err recovery"); $$ = Value::new_expr("Recovered error".to_owned()); }
;

exp:
  NUM                { $$ = Value::new_expr($<Token>1.to_string_lossy()); }
| exp "=" exp {
      $$ = self.make_comparison(&@$, $<Expr>1, $<Expr>3)?;
  }
| exp "+" exp        { $$ = Value::new_expr(format!("({} + {})", $<Expr>1.value, $<Expr>3.value)); }
| exp "-" exp        { $$ = Value::new_expr(format!("({} - {})", $<Expr>1.value, $<Expr>3.value)); }
| exp "*" exp        { $$ = Value::new_expr(format!("({} * {})", $<Expr>1.value, $<Expr>3.value)); }
| exp "/" exp        { $$ = Value::new_expr(format!("({}/+ {})", $<Expr>1.value, $<Expr>3.value)); }
| "-" exp  %prec NEG { $$ = Value::new_expr(format!("(-{})", $<Expr>2.value)); }
| exp "^" exp        { $$ = Value::new_expr(format!("({} ^ {})", $<Expr>1.value, $<Expr>3.value)); }
| "(" exp ")"        { $$ = Value::new_expr(format!("({})", $<Expr>2.value)); }
| "(" error ")"      { $$ = Value::new_expr("(err)".to_owned()); }
| "!"                { return Ok(Self::YYERROR); }
| "-" error          { return Ok(Self::YYERROR); }
;

%%

#[derive(Debug, Clone)]
pub struct TokenValue {
    s: String,
}
impl TokenValue {
    /// Converts TokenValue to string, replaces unknown chars to `U+FFFD`
    pub fn to_string_lossy(&self) -> String {
        self.s.clone()
    }

    /// Converts TokenValue to a vector of bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.s.as_bytes().to_vec()
    }
}

/// A token that is emitted by a lexer and consumed by a parser
#[derive(Clone)]
pub struct Token {
    pub token_type: i32,
    pub token_value: TokenValue,
    pub loc: Loc,
}
use std::fmt;
impl fmt::Debug for Token {
    fn fmt(&self, f: &mut fmt::Formatter<'_> /*'*/) -> fmt::Result {
        f.write_str(&format!(
            "[{}, {:?}, {}...{}]",
            token_name(self.token_type),
            self.token_value,
            self.loc.begin,
            self.loc.end
        ))
    }
}

impl Token {
    /// Converts Token to a string, replaces unknown chars to `U+FFFD`
    pub fn to_string_lossy(&self) -> String {
        self.token_value.to_string_lossy()
    }

    /// Converts Token to a vector of bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.token_value.to_bytes()
    }
}

#[derive(Debug, Clone, PartialEq)]
pub struct Expr {
    pub value: String
}

#[derive(Clone, Debug)]
pub enum Value {
    None,
    Uninitialized,
    Stolen,
    Token(Box<Token>),
    Expr(Box<Expr>)
}

impl Value {
    pub fn from_token(value: Token) -> Self {
        Self::Token(Box::new(value))
    }

    pub fn new_expr(value: String) -> Self {
        Self::Expr(Box::new(Expr { value }))
    }
}

impl Token {
    fn boxed_from(value: Value) -> Box<Token> {
        match value {
            Value::Token(v) => v,
            other => panic!("expected Token, got {:?}", other),
        }
    }
}

impl Expr {
    fn boxed_from(value: Value) -> Box<Expr> {
        match value {
            Value::Expr(v) => v,
            other => panic!("expected TokenValue, got {:?}", other),
        }
    }
}

impl<'a> Parser<'a> {
    pub fn new(lexer: Lexer, name: &'a /*'*/ str) -> Self {
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            yydebug: false,
            yyerrstatus_: 0,
            yylexer: lexer,
            result: None,
            name
        }
    }

    pub fn do_parse(&mut self) -> Option<String> {
        self.parse();
        self.result.take()
    }

    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }

    fn report_syntax_error(&self, ctx: &Context) {
        eprintln!("report_syntax_error: {:#?}", ctx)
    }

    fn make_comparison(&mut self, _: &Loc, lhs: Box<Expr>, rhs: Box<Expr>) -> Result<Value, ()> {
        if *lhs != *rhs {
            return Err(());
        }
        Ok(Value::new_expr("LHS == RHS".to_owned()))
    }
}

#[derive(Debug)]
pub struct Lexer {
    tokens: Vec<Token>
}

impl Lexer {
    pub fn new(src: &str) -> Self {
        let mut tokens = vec![];

        for (idx, c) in src.chars().enumerate() {
            let token_type = match c {
                '0'|'1'|'2'|'3'|'4'|'5'|'6'|'7'|'8'|'9' => Self::NUM,
                '!' => Self::BANG,
                '+' => Self::PLUS,
                '-' => Self::MINUS,
                '*' => Self::STAR,
                '/' => Self::SLASH,
                '^' => Self::CARET,
                '(' => Self::LPAREN,
                ')' => Self::RPAREN,
                '=' => Self::EQUAL,
                '\n' => Self::EOL,
                ' ' => continue,
                _ => panic!("unknown char {}", c)
            };
            let token = Token {
                token_type,
                token_value: TokenValue { s: c.to_string() },
                loc: Loc {
                    begin: idx,
                    end: idx + 1,
                },
            };
            tokens.push(token)
        }
        tokens.push(
            Token {
                token_type: Self::YYEOF,
                token_value: TokenValue { s: "".to_owned() },
                loc: Loc { begin: src.len(), end: src.len() + 1 },
            },
        );

        // panic!("tokens = {:?}", tokens);

        Self { tokens }
    }

    fn yylex(&mut self) -> Token {
        self.tokens.remove(0)
    }
}
