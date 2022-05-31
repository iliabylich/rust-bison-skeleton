#[global_allocator]
static GLOBAL: jemallocator::Jemalloc = jemallocator::Jemalloc;

use tests::{Lexer, Parser};

fn main() {
    use std::fs::File;
    let times = std::env::var("TIMES")
        .unwrap_or_else(|_| String::from("100_000"))
        .parse::<usize>()
        .expect("TIMES env var must be set");

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
