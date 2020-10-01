use rust_bison_skeleton_tests::{CalcLexer, CalcLoc, CalcParser, CalcToken};

#[test]
fn test() {
    let tokens: Vec<CalcToken> = vec![
        (
            CalcLexer::NUM,
            b"42".to_vec(),
            CalcLoc { begin: 0, end: 2 },
        ),
        (
            CalcLexer::PLUS,
            b"+".to_vec(),
            CalcLoc { begin: 2, end: 3 },
        ),
        (
            CalcLexer::NUM,
            b"17".to_vec(),
            CalcLoc { begin: 3, end: 5 },
        ),
        (
            CalcLexer::EOL,
            b"\n".to_vec(),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::YYEOF,
            b"".to_vec(),
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
            b"!".to_vec(),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::EOL,
            b"\n".to_vec(),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::YYEOF,
            b"".to_vec(),
            CalcLoc { begin: 6, end: 6 },
        ),
    ];
    let lexer = CalcLexer::new(tokens);

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("ERR".to_owned()));
}
