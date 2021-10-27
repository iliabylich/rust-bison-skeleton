use crate::tests::{Loc, Token};

/// Lexer struct.
/// Converts `&'static str` into a list of tokens
#[derive(Debug)]
pub struct Lexer {
    src: &'static [u8],
    pos: usize,
}

#[allow(non_upper_case_globals)]
impl Lexer {
    /// Constructor
    pub fn new(src: &'static str) -> Self {
        Self {
            src: src.as_bytes(),
            pos: 0,
        }
    }

    pub(crate) fn yylex(&mut self) -> Token {
        if self.pos == self.src.len() {
            return Token::new(
                Self::YYEOF,
                0,
                Loc {
                    begin: self.src.len() as u32,
                    end: (self.src.len() + 1) as u32,
                },
            );
        }
        while self.src[self.pos] == b' ' {
            self.pos += 1;
        }
        let (token_type, token_value) = match self.src[self.pos] {
            b'0' => (Self::tNUM, 0),
            b'1' => (Self::tNUM, 1),
            b'2' => (Self::tNUM, 2),
            b'3' => (Self::tNUM, 3),
            b'4' => (Self::tNUM, 4),
            b'5' => (Self::tNUM, 5),
            b'6' => (Self::tNUM, 6),
            b'7' => (Self::tNUM, 7),
            b'8' => (Self::tNUM, 8),
            b'9' => (Self::tNUM, 9),
            b'+' => (Self::tPLUS, -1),
            b'-' => (Self::tMINUS, -1),
            b'*' => (Self::tMUL, -1),
            b'/' => (Self::tDIV, -1),
            b'(' => (Self::tLPAREN, -1),
            b')' => (Self::tRPAREN, -1),
            b'E' => (Self::tERROR, -1),
            b'A' => (Self::tABORT, -1),
            b'C' => (Self::tACCEPT, -1),
            b' ' => return self.yylex(),
            other => panic!("unknown char {}", other as char),
        };
        let token = Token::new(
            token_type,
            token_value,
            Loc {
                begin: self.pos as u32,
                end: (self.pos + 1) as u32,
            },
        );
        self.pos += 1;
        token
    }
}
