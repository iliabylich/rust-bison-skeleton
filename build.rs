include!("src/api.rs");

fn main() {
    match process_bison_file(&Path::new("src/tests/calc.y")) {
        Ok(_) => {}
        Err(BisonErr { message, .. }) => {
            eprintln!("Bison error:\n{}\nexiting with 1", message);
            std::process::exit(1);
        }
    }
}
