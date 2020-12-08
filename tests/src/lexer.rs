use crate::{Loc, Token, TokenValue};

#[derive(Debug)]
pub struct Lexer {
    tokens: Vec<Token>,
}

impl Lexer {
    pub fn new(src: &str) -> Self {
        let mut tokens = vec![];

        for (idx, c) in src.chars().enumerate() {
            let token_type = match c {
                '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9' => Self::tNUM,
                '+' => Self::tPLUS,
                '-' => Self::tMINUS,
                '(' => Self::tLPAREN,
                ')' => Self::tRPAREN,
                '\n' => Self::tEOL,
                'E' => Self::tERROR,
                'A' => Self::tABORT,
                'C' => Self::tACCEPT,
                ' ' => continue,
                _ => panic!("unknown char {}", c),
            };
            let token = Token {
                token_type,
                token_value: TokenValue { s: c.to_string() },
                loc: Loc {
                    begin: idx,
                    end: idx + 1,
                },
            };
            tokens.push(token)
        }
        tokens.push(Token {
            token_type: Self::YYEOF,
            token_value: TokenValue { s: "".to_owned() },
            loc: Loc {
                begin: src.len(),
                end: src.len() + 1,
            },
        });

        Self { tokens }
    }

    pub(crate) fn yylex(&mut self) -> Token {
        self.tokens.remove(0)
    }
}
