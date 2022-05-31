#![warn(missing_debug_implementations)]
#![warn(missing_docs)]
#![warn(trivial_casts, trivial_numeric_casts)]
#![warn(unused_qualifications)]
#![warn(deprecated_in_future)]
#![warn(unused_lifetimes)]
#![doc = include_str!("../README.md")]

use std::error::Error;
use std::fmt;
use std::path::Path;
use std::process::Command;

/// An error returned from `bison` executable
#[derive(Debug)]
pub struct BisonErr {
    /// stderr
    pub message: String,
    /// exit code
    pub code: Option<i32>,
}

impl fmt::Display for BisonErr {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        write!(f, "BisonErr: {:#?} ({:#?})", self.message, self.code)
    }
}

impl Error for BisonErr {}

/// Creates a `.rs` file from the given `.y` file
/// Output file is created in the same directory
pub fn process_bison_file(filepath: &Path) -> Result<(), BisonErr> {
    let input = filepath;
    let output = filepath.with_extension("rs");

    let bison_root_dir = Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("bison");

    eprintln!("CARGO_MANIFEST_DIR = {:?}", env!("CARGO_MANIFEST_DIR"));
    eprintln!("file = {:?}", file!());
    eprintln!("current dir = {:?}", std::env::current_dir());
    let bison_root_file = bison_root_dir.join("main.m4");

    let args = &[
        "-S",
        bison_root_file.to_str().unwrap(),
        "-o",
        output.to_str().unwrap(),
        input.to_str().unwrap(),
    ];

    let output = Command::new("bison").args(args).output().unwrap();

    if output.status.success() {
        Ok(())
    } else {
        let stderr = String::from_utf8(output.stderr).unwrap();
        Err(BisonErr {
            message: stderr,
            code: output.status.code(),
        })
    }
}
