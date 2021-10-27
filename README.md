# rust-bison-skeleton

A set of bison skeleton files that can be used to generate a Bison grammar that is written in Rust.

Technically it's more like a Bison frontend for Rust.

## Requirements

+ Rust
+ Bison `3.7.3` or higher (or maybe a bit lower, it's unknown, better get the latest version)

`bison` executable must be available in `$PATH`.

## Short explanation

Bison is a parser generator, and in fact it doesn't really care what's your programming language.

Under the hood it takes your `.y` file, parses it, extracts all derivations and then constructs a bunch of tables.
Then, this data is passed to a template that is called `skeleton`. Simply treat it as JSX/ERB/Handlebars/etc view template.

This skeleton is a special file written in M4 language (that is not really a programming language, it's closer to a macro engine) that
(once rendered) prints your `.rs` file. As simple as that.

## Configuration

Just like in C/C++/Java/D templates the following directives can be configured:

+ `%expect N` where `N` is a number of expected conflicts. Better set it to 0
+ `%define api.parser.struct {Parser}` where `Parser` is the name of your parser struct. Optional, `Parser` is the default name.
+ `%define api.value.type {Value}` where `Value` is the name of the derivation result (and a stack item) struct. Optional, `Value` is the default name.
+ `%code use { }` allows you to specify a block of code that will be at the top of the file. Can be a multi-line block, optional, has no default value.
+ `%code parser_fields { }` allows you to specify additional custom fields for your `Parser` struct. Can be a multi-line block, optional, has no default value.
+ `%define api.parser.check_debug { /* expr */ }` allows you to configure printing debug information, `self` is an instance of your parser, so use something like this if you want to turn it into configurable field:


```bison
%code parser_fields {
    debug: bool
}
%define api.parser.check_debug { self.debug }
```

All other directives that available in Bison can be configured too, read official Bison docs.

## Basic usage

This skeleton generates an LALR(1) parser, and so parser has a stack. This stack is represented as `Vec<Value>` where `Value` is an enum that **must be defined by you**. The name of this enum must be set using `%define api.value.type {}` directive.

Let's build a simple calculator that handles lines like `1 + (4 - 3) * 2`.

First, let's define a boilerplate in `src/parser.y`:

```bison
%expect 0

%define api.parser.struct {Parser}
%define api.value.type {Value}

%define parse.error custom
%define parse.trace

%code use {
    // all use goes here
    use crate::Loc;
}

%code parser_fields {
    // custom parser fields
}

%token
    tPLUS   "+"
    tMINUS  "-"
    tMUL    "*"
    tDIV    "/"
    tLPAREN "("
    tRPAREN ")"
    tNUM    "number"

%left "-" "+"
%left "*" "/"

%%

// rules

%%

impl Parser {
    // parser implementation
}

enum Value {
    // variants to define
}
```

Currently this grammar has no rules, but it's a good start.

This code (once compiled) defines a `Parser` struct at the top of the file that looks like this:

```rust
#[derive(Debug)]
pub struct Parser {
    pub yylexer: Lexer,
    yy_error_verbose: bool,
    yynerrs: i32,
    yyerrstatus_: i32,

    /* "%code parser_fields" blocks.  */
}
```

Keep in mind that `Parser` auto-implements `std::fmt::Debug`, and so all custom fields also should implement it.

`Value` enum is what is returned by derivations and what's stored in the stack of the parser. This enum must be defined by you and **it has** to have the following variants:

+ `Uninitialized` - a variant that is stored in `$$` by default (and what's overwritten by you)
+ `Stolen` - a variant that stack value is replaced with when you get it from the stack by writing `$<N>`
+ `Token(TokenStruct)` - a variant that is used when shift if performed, holds your `TokenStruct` that is returned by a lexer

Additionally you can have as many variants as you want, however they must represent what you return from derivation rules.

In our case we want variants `Number` (to represent a numeric expression) and `None` (this is actually required to represent return value of the top-level rule).

```rust
#[derive(Clone, Debug)]
pub enum Value {
    None,
    Uninitialized,
    Stolen,
    Token(Token),
    Number(i32),
}

impl Default for Value {
    fn default() -> Self {
        Self::Stolen
    }
}
```

It must implement `Clone`, `Debug` and `Default` (`.take()` is used under the hood that swaps `&mut Value` with `Value::default()`, so `default()` **must** return `Stolen` variant).

Also skeleton defines a `Lexer` struct with a bunch of constants representing token numbers, it looks like this:

```rust
// AUTO-GENERATED
impl Lexer {
    /* Token kinds.  */
    // Token "end of file", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const YYEOF: i32 = 0;
    // Token error, to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const YYerror: i32 = 256;
    // Token "invalid token", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const YYUNDEF: i32 = 257;
    // Token "+", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tPLUS: i32 = 258;
    // Token "-", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tMINUS: i32 = 259;
    // Token "*", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tMUL: i32 = 260;
    // Token "/", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tDIV: i32 = 261;
    // Token "(", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tLPAREN: i32 = 262;
    // Token ")", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tRPAREN: i32 = 263;
    // Token "number", to be returned by the scanner.
    #[allow(non_upper_case_globals, dead_code)]
    pub const tNUM: i32 = 264;
}
```

Thus, we can define our lexer logic:

```rust
use crate::{Loc, Value};

/// A token that is emitted by a lexer and consumed by a parser
#[derive(Clone)]
pub struct Token {
    // Required field, used by a skeleton
    pub token_type: i32,

    // Optional field, used by our custom parser
    pub token_value: i32,

    // Required field, used by a skeleton
    pub loc: Loc,
}

/// `Debug` implementation
impl std::fmt::Debug for Token {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_> /*' fix quotes */) -> std::fmt::Result {
        f.write_str(&format!(
            "[{}, {:?}, {}...{}]",
            token_name(self.token_type()),
            self.token_value,
            self.loc.begin,
            self.loc.end
        ))
    }
}

impl Token {
    /// Used by a parser to "unwrap" `Value::Token` variant into a plain Token value
    pub(crate) fn from(value: Value) -> Token {
        match value {
            Value::Token(v) => v,
            other => panic!("expected Token, got {:?}", other),
        }
    }
}


#[allow(non_upper_case_globals)]
impl Lexer {
    pub fn new(src: &str) -> Self {
        let mut tokens = vec![];

        for (idx, c) in src.chars().enumerate() {
            let (token_type, token_value) = match c {
                '0' => (Self::tNUM, 0),
                '1' => (Self::tNUM, 1),
                '2' => (Self::tNUM, 2),
                '3' => (Self::tNUM, 3),
                '4' => (Self::tNUM, 4),
                '5' => (Self::tNUM, 5),
                '6' => (Self::tNUM, 6),
                '7' => (Self::tNUM, 7),
                '8' => (Self::tNUM, 8),
                '9' => (Self::tNUM, 9),
                '+' => (Self::tPLUS, -1),
                '-' => (Self::tMINUS, -1),
                '*' => (Self::tMUL, -1),
                '/' => (Self::tDIV, -1),
                '(' => (Self::tLPAREN, -1),
                ')' => (Self::tRPAREN, -1),
                ' ' => continue,
                _ => panic!("unknown char {}", c),
            };
            let token = Token {
                token_type,
                token_value,
                loc: Loc {
                    begin: idx,
                    end: idx + 1,
                },
            };
            tokens.push(token)
        }
        tokens.push(Token {
            token_type: Self::YYEOF,
            token_value: 0,
            loc: Loc {
                begin: src.len(),
                end: src.len() + 1,
            },
        });

        Self { tokens }
    }

    pub(crate) fn yylex(&mut self) -> Token {
        self.tokens.remove(0)
    }
}
```

This lexer is not buffered and it does unnecessary work in case of a syntax error, but let's use at it's easier to understand.

Now let's define `Parser` <-> `Lexer` composition:

```rust
impl Parser {
    pub fn new(lexer: Lexer) -> Self {
        Self {
            yy_error_verbose: true,
            yynerrs: 0,
            yyerrstatus_: 0,
            yylexer: lexer,
        }
    }

    fn next_token(&mut self) -> Token {
        self.yylexer.yylex()
    }

    fn report_syntax_error(&self, ctx: &Context) {
        eprintln!("syntax error: {:#?}", ctx)
    }
}
```

`Parser` encapsulates `Lexer` and calls it in a `next_token` method that is called by a skeleton.

Time to define rules:

```bison
%type <Number> expr number program

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

  number: tNUM
            {
                $$ = Value::Number($<Token>1.token_value());
            }

%%
```

As you can see our grammar has the following rules:

```bison
program: expr
       | error

   expr: number
       | '(' number ')'
       | number '+' number
       | number '-' number
       | number '*' number
       | number '/' number

 number: [0-9]
```

`$$` is a return value and it has type `Value`. You can use `$1`, `$2`, etc to get items 1, 2, etc that **are no unwrapped**, i.e. that also have type `Value`. To unwrap it you can use `$<Variant>1`, but then you must have the following method:

```rust
impl Variant {
    fn from(value: Value) -> Self {
        match value {
            Value::Variant(out) => out,
            other => panic!("wrong type, expected Variant, got {:?}", other),
        }
    }
}
```

In our case we want to have only one such variant - `Number`:

```rust
use crate::Value;

#[allow(non_snake_case)]
pub(crate) mod Number {
    use super::Value;

    pub(crate) fn from(value: Value) -> i32 {
        match value {
            Value::Number(out) => out,
            other => panic!("wrong type, expected Number, got {:?}", other),
        }
    }
}
```

Yes, it's a mod, but that's absolutely OK. It doesn't matter what `Variant` is, it's all about calling `Variant::from(Value)`.

Also, as you might notice, there's a `self.result = ...` assignment in the top-level rule `program`. The reason why it's required is that there's no way to get value that is left on the stack because stack is not a part of the parser's state.

This is why we also need to declare it:

```bison
%code parser_fields {
    result: Option<i32>,
}

// And Parser's constructor must return
fn new(lexer: Lexer) -> Self {
    Self {
        result: None,
        // ...
    }
}
```

Now we need a `build.rs` script:

```rust
extern crate rust_bison_skeleton;
use rust_bison_skeleton::{process_bison_file, BisonErr};
use std::path::Path;

fn main() {
    match process_bison_file(&Path::new("src/parser.y")) {
        Ok(_) => {}
        Err(BisonErr { message, .. }) => {
            eprintln!("Bison error:\n{}\nexiting with 1", message);
            std::process::exit(1);
        }
    }
}
```

And so after running `cargo build` we should get `src/parser.rs` with all auto-generated and manually written code combined into a single file.

You can find a full example in `tests/src/calc.y`.

## Error recovery

This skeleton full matches behavior of other built-in Bison skeletons:

+ If you want to return an error from a derivation you can either:
  + do `return Ok(Self::YYERROR);`
  + or just `Err(())?`
+ If you want to completely abort execution you can:
  + `return Ok(Self::YYACCEPT);` to abort with success-like status code
  + `return Ok(Self::YYABORT);` to abort with error-like status code

Once error is returned a special `error` rule can catch and "swallow" it:

```bison

 numbers: number
          {
              $$ = Value::NumbersList(vec![ $Number<1> ]);
          }
        | numbers number
          {
              $$ = Value::NumbersList( $<NumbersList>1.append($<Number>2) );
          }
        | error number
          {
              // ignore $1 and process only $<Number>2
              $$ = Value::NumbersList(vec![ $Number<2> ]);
          }


  number: tNUM         { $$ = $1 }
        | tINVALID_NUM { return Ok(Self::YYERROR); }
```

Information about the error is automatically passed to `Parser::report_syntax_error`. `Context` that it takes has methods `token()` and `location()`, so implementation of this method can look like this:

```rust
fn report_syntax_error(&mut self, ctx: &Context) {
    let token_id: usize = ctx.token().code().try_into().unwrap();
    let token_name: &'static str = Lexer::TOKEN_NAMES[id];
    let error_loc: &Loc = ctx.location();

    eprintln!("Unexpected token {} at {:?}", token_name, loc);
}
```

## Generic parser

To make `Parser` generic you need to configure the following directive:

```bison
%define api.parser.generic {<T1, T2>}
```

This code is added to `struct Parser` and `impl Parser`:

```rust
struct Parser<T1, T2> {
    // ...
}

impl<T1, T2> Parser<T1, T2> {
    // ...
}
```

If you wan to specify lifetimes make sure to fix quotes with comments:

```bison
%define api.parser.generic {<'a /* 'fix quotes */, T>}
```

## Performance

You can find a `perf` example that runs a `Parser` thousands times and creates a flamegraph.
