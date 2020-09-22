use std::error::Error;
use std::path::Path;
use std::process::Command;

pub fn process_bison_file(filepath: &Path) -> Result<(), Box<dyn Error>> {
    let input = filepath;
    let output = filepath.with_extension("rs");

    println!("cargo:rerun-if-changed={}", input.to_str().unwrap());
    let bison_root_dir = Path::new(file!())
        .parent()
        .unwrap()
        .parent()
        .unwrap()
        .join("bison");

    println!(
        "cargo:rerun-if-changed={}",
        bison_root_dir.join("c-like.m4").to_str().unwrap()
    );
    println!(
        "cargo:rerun-if-changed={}",
        bison_root_dir.join("lalr1-rust.m4").to_str().unwrap()
    );
    println!(
        "cargo:rerun-if-changed={}",
        bison_root_dir.join("main.m4").to_str().unwrap()
    );
    println!(
        "cargo:rerun-if-changed={}",
        bison_root_dir.join("rust.m4").to_str().unwrap()
    );

    let bison_root_file = bison_root_dir.join("main.m4");

    let args = &[
        "-S",
        bison_root_file.to_str().unwrap(),
        "-o",
        output.to_str().unwrap(),
        input.to_str().unwrap(),
    ];

    let output = Command::new("bison").args(args).output()?;
    println!("output = {:#?}", output);

    Ok(())
}
