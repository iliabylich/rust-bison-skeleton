use rust_bison_skeleton_tests::{Lexer, Parser};

fn parse(input: &str, name: &str) -> Vec<i32> {
    let lexer = Lexer::new(input);
    let mut parser = Parser::new(lexer, name);
    parser.yydebug = true;
    let result = parser.do_parse();

    assert_eq!(parser.name, name);
    result
}

#[test]
fn test_valid() {
    assert_eq!(parse("9\n3 + (3 - 2)\n", "test_valid"), vec![9, 4]);
}

#[test]
fn test_error_recovery_manual() {
    assert_eq!(
        parse("1\nE\n2\n", "test_error_recovery_manual"),
        vec![1, -1, 2]
    );
}

#[test]
fn test_error_recovery_on_syntax_error() {
    assert_eq!(
        parse("1\n4 2\n3\n", "test_error_recovery_on_syntax_error"),
        vec![1, -1, 3]
    )
}

#[test]
fn test_abort() {
    assert_eq!(parse("1\nA\n2\n", "test_abort"), vec![])
}

#[test]
fn test_accept() {
    assert_eq!(parse("1\nC\n2\n", "test_accept"), vec![])
}
