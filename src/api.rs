use std::error::Error;
use std::fmt;
use std::path::Path;
use std::process::Command;

#[derive(Debug)]
pub struct BisonErr {
    pub message: String,
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

    let bison_root_dir = Path::new(file!())
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("bison");

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
