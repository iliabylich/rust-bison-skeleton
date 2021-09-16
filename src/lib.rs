#![warn(missing_debug_implementations)]
#![warn(missing_docs)]
#![warn(trivial_casts, trivial_numeric_casts)]
#![warn(unused_qualifications)]
#![warn(deprecated_in_future)]
#![warn(unused_lifetimes)]
#![doc = include_str!("../README.md")]

mod api;
pub use api::process_bison_file;

#[cfg(any(feature = "dummy-parser", feature = "examples"))]
/// Test module with a dummy zero-copy parser that is used for testing and benchmarking
pub mod tests;
