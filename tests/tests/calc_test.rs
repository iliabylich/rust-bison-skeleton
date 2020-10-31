use rust_bison_skeleton_tests::{CalcLexer, CalcParser};

#[test]
fn test() {
    let lexer = CalcLexer::new("2 + 3 - 1\n");
    let mut parser = CalcParser::new(lexer);
    parser.yydebug = true;
    let result = parser.do_parse();

    assert_eq!(result, Some("((2 + 3) - 1)".to_owned()))
}

#[test]
fn test_invalid() {
    let lexer = CalcLexer::new("!\n");
    let mut parser = CalcParser::new(lexer);
    parser.yydebug = true;
    let result = parser.do_parse();

    assert_eq!(result, Some("Recovered error".to_owned()));
}

#[test]
fn test_errors_propagation() {
    let lexer = CalcLexer::new("1 = 2\n");
    let mut parser = CalcParser::new(lexer);
    parser.yydebug = true;
    let result = parser.do_parse();

    assert_eq!(result, Some("Recovered error".to_owned()))
}

#[test]
fn test_errors_propagation_no_error() {
    let lexer = CalcLexer::new("1 = 1\n");
    let mut parser = CalcParser::new(lexer);
    parser.yydebug = true;
    let result = parser.do_parse();

    assert_eq!(result, Some("LHS == RHS".to_owned()))
}
