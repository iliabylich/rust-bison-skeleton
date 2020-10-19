use rust_bison_skeleton_tests::{CalcLexer, CalcLoc, CalcParser, CalcToken, CalcTokenValue};

#[test]
fn test() {
    let tokens: Vec<CalcToken> = vec![
        (
            CalcLexer::NUM,
            CalcTokenValue::String("42".to_owned()),
            CalcLoc { begin: 0, end: 2 },
        ),
        (
            CalcLexer::PLUS,
            CalcTokenValue::String("+".to_owned()),
            CalcLoc { begin: 2, end: 3 },
        ),
        (
            CalcLexer::NUM,
            CalcTokenValue::String("17".to_owned()),
            CalcLoc { begin: 3, end: 5 },
        ),
        (
            CalcLexer::EOL,
            CalcTokenValue::InvalidString(b"\n".to_vec()),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::YYEOF,
            CalcTokenValue::String("".to_owned()),
            CalcLoc { begin: 6, end: 6 },
        ),
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
        (
            CalcLexer::BANG,
            CalcTokenValue::String("!".to_owned()),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::EOL,
            CalcTokenValue::String("\n".to_owned()),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::YYEOF,
            CalcTokenValue::String("".to_owned()),
            CalcLoc { begin: 6, end: 6 },
        ),
    ];
    let lexer = CalcLexer::new(tokens);

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("ERR".to_owned()));
}
