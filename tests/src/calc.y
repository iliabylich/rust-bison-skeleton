%expect 0

%define api.parser.struct {Parser}
%define api.location.type {Loc}
%define api.location.range_type {u16}
%define api.value.type {Value}

%define parse.error custom
%define parse.trace


%code use {
    // all use goes here
    use crate::{Token, Lexer, Value, Number};
}

%code parser_fields {
    result: Option<i32>,
    /// Just an extra field for demonstration
    pub name: String,
}

%code {
    // code
}


/* Bison Declarations */
%token
    tPLUS   "+"
    tMINUS  "-"
    tMUL    "*"
    tDIV    "/"
    tLPAREN "("
    tRPAREN ")"
    tNUM    "`number'"
    tERROR  "controlled YYERROR"
    tABORT  "controlled YYABORT"
    tACCEPT "controlled YYACCEPT"
%type <Number> expr number program

%left "-" "+"
%left "*" "/"

%%

 program: expr
            {
                self.result = Some($<Number>1);
                $$ = Value::None;
            }
        | error
            {
                self.result = None;
                $$ = Value::None;
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
        | expr tMUL expr
            {
                $$ = Value::Number($<Number>1 * $<Number>3);
            }
        | expr tDIV expr
            {
                $$ = Value::Number($<Number>1 / $<Number>3);
            }
        | tERROR
            {
                return Ok(Self::YYERROR);
                // or Err(())?
            }
        | tABORT
            {
                self.result = Some(Self::ABORTED);
                return Ok(Self::YYABORT);
            }
        | tACCEPT
            {
                self.result = Some(Self::ACCEPTED);
                return Ok(Self::YYACCEPT);
            }

  number: tNUM
            {
                $$ = Value::Number($<Token>1.token_value);
            }

%%

impl Parser {
    /// "Sucess" status-code of the parser
    pub const ACCEPTED: i32 = -1;

    /// "Failure" status-code of the parser
    pub const ABORTED: i32 = -2;

    /// Constructor
    pub fn new(lexer: Lexer, name: &str) -> Self {
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            yydebug: false,
            yyerrstatus_: 0,
            yylexer: lexer,
            result: None,
            name: name.to_owned(),
        }
    }

    /// Wrapper around generated `parse` method that also
    /// extracts `result` field and returns it.
    pub fn do_parse(mut self) -> (Option<i32>, String) {
        self.parse();
        (self.result, self.name)
    }

    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }

    fn report_syntax_error(&self, ctx: &Context) {
        eprintln!("report_syntax_error: {:#?}", ctx)
    }
}

impl std::fmt::Debug for Loc {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_ /*'*/>) -> Result<(), std::fmt::Error> {
        f.write_str(&format!("{}...{}", self.begin, self.end))
    }
}
