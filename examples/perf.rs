#[cfg(feature = "examples")]
extern crate jemallocator;
#[cfg(feature = "examples")]
extern crate pprof;

#[cfg(feature = "examples")]
#[global_allocator]
static GLOBAL: jemallocator::Jemalloc = jemallocator::Jemalloc;

#[cfg(feature = "examples")]
fn main() {
    use rust_bison_skeleton::tests::{Lexer, Parser};
    use std::fs::File;
    let times = std::env::var("TIMES")
        .unwrap_or_else(|_| String::from("100_000"))
        .parse::<usize>()
        .unwrap();

    let source = "1 + 2 - (4 - 3)";
    let guard = pprof::ProfilerGuard::new(100).unwrap();
    let start = std::time::Instant::now();

    for _ in 0..times {
        let lexer = Lexer::new(source);
        let parser = Parser::new(lexer, "perf_test");
        parser.do_parse();
    }

    let end = std::time::Instant::now();
    let diff = (end - start).as_secs_f64();
    println!(
        "Time taken to parse `{}` {} times : {:.10}",
        source, times, diff
    );

    println!("Creating flamegraph.svg");

    let report = guard.report().build().unwrap();
    let file = File::create("flamegraph.svg").unwrap();
    report.flamegraph(file).unwrap();
}

#[cfg(not(feature = "examples"))]
fn main() {
    eprintln!("To run this example make sure to pass --features=examples")
}
