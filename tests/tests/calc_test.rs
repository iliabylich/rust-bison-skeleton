use rust_bison_skeleton_tests::{CalcLexer, CalcParser};

#[test]
fn test() {
    let lexer = CalcLexer::new("2 + 3 - 1\n");

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("((2 + 3) - 1)".to_owned()))
}

#[test]
fn test_invalid() {
    let lexer = CalcLexer::new("!\n");

    let mut parser = CalcParser::new(lexer);
    parser.yydebug = 1;
    let result = parser.do_parse();

    assert_eq!(result, Some("ERR".to_owned()));
}
