use crate::{token_name, Loc, Value};

/// A token that is emitted by a lexer and consumed by a parser
#[derive(Clone)]
pub struct Token {
    /// Type of the token (i.e. tNUM, tPLUS or YYEOF)
    pub token_type: i32,

    /// Value of the token (i.e. `0`, `1` etc)
    pub token_value: i32,

    /// Location of the token (i.e. range in source code that it refers to)
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
    pub(crate) fn from(value: Value) -> Token {
        match value {
            Value::Token(v) => v,
            other => panic!("expected Token, got {:?}", other),
        }
    }
}
