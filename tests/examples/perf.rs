extern crate jemallocator;
extern crate pprof;
extern crate rust_bison_skeleton_tests;

use rust_bison_skeleton_tests::*;
use std::fs::File;

#[global_allocator]
static GLOBAL: jemallocator::Jemalloc = jemallocator::Jemalloc;

fn main() {
    let source = "1 + 2 - (4 - 3)\n";
    let expected = vec![2];
    let guard = pprof::ProfilerGuard::new(100).unwrap();

    for _ in 0..100_000 {
        let lexer = Lexer::new(source);
        let mut parser = Parser::new(lexer, "perf_test");
        let actual = parser.do_parse();
        assert_eq!(actual, expected);
    }

    println!("Creating flamegraph.svg");
    let report = guard.report().build().unwrap();
    let file = File::create("flamegraph.svg").unwrap();
    report.flamegraph(file).unwrap();
}
