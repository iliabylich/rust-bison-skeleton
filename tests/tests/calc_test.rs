use rust_bison_skeleton_tests::{CalcLexer, CalcLoc, CalcParser, CalcToken};

#[test]
fn test() {
    let tokens: Vec<CalcToken> = vec![
        (
            CalcLexer::NUM,
            String::from("42"),
            CalcLoc { begin: 0, end: 2 },
        ),
        (
            CalcLexer::PLUS,
            String::from("+"),
            CalcLoc { begin: 2, end: 3 },
        ),
        (
            CalcLexer::NUM,
            String::from("17"),
            CalcLoc { begin: 3, end: 5 },
        ),
        (
            CalcLexer::EOL,
            String::from("\n"),
            CalcLoc { begin: 5, end: 6 },
        ),
        (
            CalcLexer::YYEOF,
            String::from(""),
            CalcLoc { begin: 6, end: 6 },
        ),
    ];
    let lexer = Box::new(CalcLexer::new(tokens));

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 0;
    let result = parser.do_parse();

    assert_eq!(result, Some("\"42\" + \"17\"".to_owned()))
}
