use rust_bison_skeleton_tests::{Lexer, Parser};

fn parse(input: &str, name: &str) -> Option<i32> {
    let lexer = Lexer::new(input);
    let mut parser = Parser::new(lexer, name);
    parser.yydebug = true;
    let (result, stored_name) = parser.do_parse();

    assert_eq!(stored_name, name);
    result
}

#[test]
fn test_valid() {
    assert_eq!(parse("1 + (4 - 3) * 4 / 2", "test_valid"), Some(3));
}

#[test]
fn test_error_recovery_manual() {
    assert_eq!(parse("1 + E + 2", "test_error_recovery_manual"), None);
}

#[test]
fn test_error_recovery_on_syntax_error() {
    assert_eq!(parse("1 2", "test_error_recovery_on_syntax_error"), None)
}

#[test]
fn test_abort() {
    assert_eq!(parse("1 + A + 2", "test_abort"), Some(Parser::ABORTED))
}

#[test]
fn test_accept() {
    assert_eq!(parse("1 + C + 2", "test_accept"), Some(Parser::ACCEPTED))
}
