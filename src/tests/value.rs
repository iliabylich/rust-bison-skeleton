use crate::tests::Token;

/// Enum that represents all kinds of values that can be returned
/// from parser derivations.
///
/// This values has to be in a single enum, because LALR parsers
/// have a stack, and it's better for it to be heterogeneous.
#[derive(Clone, Debug)]
pub enum Value {
    /// Required variant, parser expects it to be defined
    None,
    /// Required variant, parser expects it to be defined
    Uninitialized,
    /// Required variant, parser expects it to be defined
    Stolen,

    /// Required variant, parser expects it to be defined.
    /// Represents a token that is returned from a Lexer
    Token(Token),

    /// Represents a number
    Number(i32),
}

impl Default for Value {
    fn default() -> Self {
        Self::Stolen
    }
}

impl Value {
    /// Required method, parser expects it to be defined.
    ///
    /// Constructor for `Value::Token(token)` variant.
    pub(crate) fn from_token(value: Token) -> Self {
        Self::Token(value)
    }

    pub(crate) fn new_uninitialized() -> Self {
        Self::Uninitialized
    }

    pub(crate) fn is_uninitialized(&self) -> bool {
        matches!(self, Self::Uninitialized)
    }
}

/// All other variants also must have according `from` methods.
///
/// Number is not really a struct, but `Variant::from(Value)` must be provided,
/// so here we define a `mod` with the same name.
#[allow(non_snake_case)]
pub mod Number {
    use super::Value;

    pub(crate) fn from(value: Value) -> i32 {
        match value {
            Value::Number(out) => out,
            other => panic!("wrong type, expected Number, got {:?}", other),
        }
    }
}
