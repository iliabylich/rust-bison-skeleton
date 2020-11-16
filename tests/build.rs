extern crate rust_bison_skeleton;
use rust_bison_skeleton::{process_bison_file, BisonErr};
use std::path::Path;

fn main() {
    match process_bison_file(&Path::new("src/calc.y")) {
        Ok(_) => {},
        Err(BisonErr { message, .. }) => {
            eprintln!("Bison error:\n{}\nexiting with 1", message);
            std::process::exit(1);
        }
    }
}
