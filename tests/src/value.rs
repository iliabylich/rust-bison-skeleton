use crate::Token;

#[derive(Clone, Debug)]
pub enum Value {
    None,
    Uninitialized,
    Stolen,
    Token(Box<Token>),
    Number(i32),
    Numbers(Vec<i32>),
}

impl Value {
    pub fn from_token(value: Token) -> Self {
        Self::Token(Box::new(value))
    }
}

#[allow(non_snake_case)]
pub(crate) mod Numbers {
    use super::Value;

    pub(crate) fn boxed_from(value: Value) -> Vec<i32> {
        match value {
            Value::Numbers(ns) => ns,
            other => panic!("wrong type, expected Numbers, got {:?}", other),
        }
    }
}

#[allow(non_snake_case)]
pub(crate) mod Number {
    use super::Value;

    pub(crate) fn boxed_from(value: Value) -> i32 {
        match value {
            Value::Number(n) => n,
            other => panic!("wrong type, expected Number, got {:?}", other),
        }
    }
}
