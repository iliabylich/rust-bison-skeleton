use crate::{token_name, Loc, Value};

#[derive(Debug, Clone)]
pub struct TokenValue {
    pub(crate) s: String,
}
impl TokenValue {
    /// Converts TokenValue to string, replaces unknown chars to `U+FFFD`
    pub fn to_string_lossy(&self) -> String {
        self.s.clone()
    }

    /// Converts TokenValue to a vector of bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.s.as_bytes().to_vec()
    }
}

/// A token that is emitted by a lexer and consumed by a parser
#[derive(Clone)]
pub struct Token {
    pub token_type: i32,
    pub token_value: TokenValue,
    pub loc: Loc,
}
use std::fmt;
impl fmt::Debug for Token {
    fn fmt(&self, f: &mut fmt::Formatter<'_> /*'*/) -> fmt::Result {
        f.write_str(&format!(
            "[{}, {:?}, {}...{}]",
            token_name(self.token_type),
            self.token_value,
            self.loc.begin,
            self.loc.end
        ))
    }
}

impl Token {
    /// Converts Token to a string, replaces unknown chars to `U+FFFD`
    pub fn to_string_lossy(&self) -> String {
        self.token_value.to_string_lossy()
    }

    /// Converts Token to a vector of bytes
    pub fn to_bytes(&self) -> Vec<u8> {
        self.token_value.to_bytes()
    }

    pub(crate) fn boxed_from(value: Value) -> Box<Token> {
        match value {
            Value::Token(v) => v,
            other => panic!("expected Token, got {:?}", other),
        }
    }
}
