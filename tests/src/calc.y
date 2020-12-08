%expect 0

%define api.parser.struct {Parser}
%define api.location.type {Loc}
%define api.value.type {Value}

%define parse.error custom
%define parse.trace


%code use {
    // all use goes here
    use crate::{Token, Lexer, Value, Numbers, Number};
}

%code parser_fields {
  result: Vec<i32>,
  pub name: String,
}

%code {
  // code
}


/* Bison Declarations */
%token
    tPLUS   "+"
    tMINUS  "-"
    tLPAREN "("
    tRPAREN ")"
    tEOL    _("end of line")
    tNUM    _("number")
    tERROR  "controlled YYERROR"
    tABORT  "controlled YYABORT"
    tACCEPT "controlled YYACCEPT"
%type <Number> expr stmt number
%type <Numbers> program stmts

%left "-" "+"
%left "*" "/"

%%

program: stmts
            {
                self.result = $<Numbers>1;
                $$ = Value::None;
            }

  stmts: stmts stmt
            {
                let mut stmts = $<Numbers>1;
                stmts.push($<Number>2);
                $$ = Value::Numbers(stmts);
            }
        | stmt
            {
                $$ = Value::Numbers(vec![ $<Number>1 ]);
            }

   stmt: expr tEOL
            {
                $$ = $1;
            }
        | error tEOL
            {
                $$ = Value::Number(-1);
            }

   expr: number
            {
                $$ = $1;
            }
        | tLPAREN expr tRPAREN
            {
                $$ = $2;
            }
        | expr tPLUS expr
            {
                $$ = Value::Number($<Number>1 + $<Number>3);
            }
        | expr tMINUS expr
            {
                $$ = Value::Number($<Number>1 - $<Number>3);
            }
        | tERROR
            {
                return Ok(Self::YYERROR);
                // or Err(())?
            }
        | tABORT
            {
                return Ok(Self::YYABORT);
            }
        | tACCEPT
            {
                return Ok(Self::YYACCEPT);
            }

 number: tNUM
            {
                $$ = Value::Number($<Token>1.to_string_lossy().parse::<i32>().unwrap());
            }

%%

impl Parser {
    pub fn new(lexer: Lexer, name: &str) -> Self {
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            yydebug: false,
            yyerrstatus_: 0,
            yylexer: lexer,
            result: vec![],
            name: name.to_owned()
        }
    }

    pub fn do_parse(&mut self) -> Vec<i32> {
        self.parse();
        std::mem::take(&mut self.result)
    }

    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }

    fn report_syntax_error(&self, ctx: &Context) {
        eprintln!("report_syntax_error: {:#?}", ctx)
    }
}
