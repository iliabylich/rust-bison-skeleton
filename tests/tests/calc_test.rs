use rust_bison_skeleton_tests::{CalcLexer, CalcLoc, CalcParser, CalcToken, CalcTokenValue};

#[test]
fn test() {
    let tokens: Vec<CalcToken> = vec![
        CalcToken {
            token_type: CalcLexer::NUM,
            token_value: CalcTokenValue::String("42".to_owned()),
            loc: CalcLoc { begin: 0, end: 2 },
        },
        CalcToken {
            token_type: CalcLexer::PLUS,
            token_value: CalcTokenValue::String("+".to_owned()),
            loc: CalcLoc { begin: 2, end: 3 },
        },
        CalcToken {
            token_type: CalcLexer::NUM,
            token_value: CalcTokenValue::String("17".to_owned()),
            loc: CalcLoc { begin: 3, end: 5 },
        },
        CalcToken {
            token_type: CalcLexer::EOL,
            token_value: CalcTokenValue::InvalidString(b"\n".to_vec()),
            loc: CalcLoc { begin: 5, end: 6 },
        },
        CalcToken {
            token_type: CalcLexer::YYEOF,
            token_value: CalcTokenValue::String("".to_owned()),
            loc: CalcLoc { begin: 6, end: 6 },
        },
    ];
    let lexer = CalcLexer::new(tokens);

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("\"42\" + \"17\"".to_owned()))
}

#[test]
fn test_invalid() {
    let tokens: Vec<CalcToken> = vec![
        CalcToken {
            token_type: CalcLexer::BANG,
            token_value: CalcTokenValue::String("!".to_owned()),
            loc: CalcLoc { begin: 5, end: 6 },
        },
        CalcToken {
            token_type: CalcLexer::EOL,
            token_value: CalcTokenValue::String("\n".to_owned()),
            loc: CalcLoc { begin: 5, end: 6 },
        },
        CalcToken {
            token_type: CalcLexer::YYEOF,
            token_value: CalcTokenValue::String("".to_owned()),
            loc: CalcLoc { begin: 6, end: 6 },
        },
    ];
    let lexer = CalcLexer::new(tokens);

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("ERR".to_owned()));
}
