#![warn(missing_debug_implementations)]
#![warn(missing_docs)]
#![warn(trivial_casts, trivial_numeric_casts)]
#![warn(unused_qualifications)]
#![warn(deprecated_in_future)]
#![warn(unused_lifetimes)]

/*!

Calc parser example

*/

mod calc;
mod lexer;
mod token;
mod value;

pub use calc::{token_name, Loc, Parser};
pub use lexer::Lexer;
pub use token::Token;
pub use value::Value;

pub(crate) use value::Number;
