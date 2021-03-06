use crate::{Loc, Token};

/// Lexer struct.
/// Converts `&str` into `Vec<Token>`
#[derive(Debug)]
pub struct Lexer {
    tokens: Vec<Token>,
}

#[allow(non_upper_case_globals)]
impl Lexer {
    /// Constructor
    pub fn new(src: &str) -> Self {
        let mut tokens = vec![];

        for (idx, c) in src.chars().enumerate() {
            let (token_type, token_value) = match c {
                '0' => (Self::tNUM, 0),
                '1' => (Self::tNUM, 1),
                '2' => (Self::tNUM, 2),
                '3' => (Self::tNUM, 3),
                '4' => (Self::tNUM, 4),
                '5' => (Self::tNUM, 5),
                '6' => (Self::tNUM, 6),
                '7' => (Self::tNUM, 7),
                '8' => (Self::tNUM, 8),
                '9' => (Self::tNUM, 9),
                '+' => (Self::tPLUS, -1),
                '-' => (Self::tMINUS, -1),
                '*' => (Self::tMUL, -1),
                '/' => (Self::tDIV, -1),
                '(' => (Self::tLPAREN, -1),
                ')' => (Self::tRPAREN, -1),
                'E' => (Self::tERROR, -1),
                'A' => (Self::tABORT, -1),
                'C' => (Self::tACCEPT, -1),
                ' ' => continue,
                _ => panic!("unknown char {}", c),
            };
            let token = Token::new(
                token_type,
                token_value,
                Loc::new(idx as u32, (idx + 1) as u32),
            );
            tokens.push(token)
        }
        tokens.push(Token::new(
            Self::YYEOF,
            0,
            Loc::new(src.len() as u32, (src.len() + 1) as u32),
        ));

        Self { tokens }
    }

    pub(crate) fn yylex(&mut self) -> Token {
        self.tokens.remove(0)
    }
}
