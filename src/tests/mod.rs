mod calc;
mod lexer;
mod loc;
mod token;
mod value;

pub use calc::{token_name, Parser};
pub use lexer::Lexer;
pub use loc::Loc;
pub use token::Token;
pub use value::Value;

pub use value::Number;

#[cfg(test)]
fn parse(input: &'static str, name: &str) -> Option<i32> {
    let lexer = Lexer::new(input);
    let mut parser = Parser::new(lexer, name);
    parser.debug = true;
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
