use crate::Token;

#[derive(Clone, Debug)]
pub enum Value {
    None,
    Uninitialized,
    Stolen,
    Token(Token),
    Number(i32),
}

impl Default for Value {
    fn default() -> Self {
        Self::Stolen
    }
}

impl Value {
    pub fn from_token(value: Token) -> Self {
        Self::Token(value)
    }
}

#[allow(non_snake_case)]
pub(crate) mod Number {
    use super::Value;

    pub(crate) fn from(value: Value) -> i32 {
        match value {
            Value::Number(out) => out,
            other => panic!("wrong type, expected Number, got {:?}", other),
        }
    }
}
