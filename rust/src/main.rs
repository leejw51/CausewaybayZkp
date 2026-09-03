//! `gate18-snark` — the quest 2 SNARK from the terminal.
//!
//!   gate18-snark            prove + verify the demo board, print the report
//!   gate18-snark --cheat    prove with a wrong solution: the verifier says no
//!   gate18-snark --tamper   flip one byte of a good proof: the verifier says no
//!   gate18-snark --info     circuit and key facts, no proof
//!   gate18-snark --json     machine-readable output (any mode)
//!   gate18-snark --version  the version of record, and nothing else

use gate18_snark::api;
use gate18_snark::sudoku::{render, DEMO_CLUES, DEMO_SOLUTION};

fn print_report(r: &api::Report, json: bool) {
    if json {
        println!("{}", serde_json::to_string_pretty(r).unwrap());
        return;
    }
    println!("constraints   {}   (equations of the form (a)*(b)=(c))", r.constraints);
    println!("public inputs {}   (the printed cells)", r.public_inputs);
    println!("secret cells  {}   (never leave the prover)", r.secret_cells);
    println!("variables     {}", r.variables);
    println!("vk            {} bytes   id {}", r.vk_bytes, r.vk_id);
    println!("pk            {} bytes", r.pk_bytes);
    println!("setup         {:.2} ms", r.ms.setup);
    if let Some(p) = &r.proof {
        println!("proof         {} bytes = A {} + B {} + C {}", p.bytes, p.a.len() / 2, p.b.len() / 2, p.c.len() / 2);
        println!("  A {}", p.a);
        println!("  B {}", p.b);
        println!("  C {}", p.c);
        println!("prove         {:.2} ms", r.ms.prove);
        println!("verify        {:.2} ms   ({} pairings)", r.ms.verify, r.pairings);
    }
    println!("verdict       {}{}", r.verdict, if r.reason.is_empty() { String::new() } else { format!("   {}", r.reason) });
}

fn main() {
    let args: Vec<String> = std::env::args().skip(1).collect();
    let json = args.iter().any(|a| a == "--json");
    let mode = args.iter().find(|a| a.as_str() != "--json").map(|s| s.as_str()).unwrap_or("");

    // Before the banner and before any proving: packaging asks a binary what
    // it is, and the answer has to be cheap and the last word on the line.
    if mode == "--version" {
        println!("gate18-snark {}", env!("CARGO_PKG_VERSION"));
        return;
    }

    if !json {
        println!("GATE 18  quest 2  //  Groth16 on BN254 (arkworks)\n");
        println!("board (public clues)        solution (Mei's secret)");
        let a = render(&DEMO_CLUES);
        let b = render(&DEMO_SOLUTION);
        for (l, r) in a.lines().zip(b.lines()) {
            println!("  {l:<26}  {r}");
        }
        println!();
    }

    match mode {
        "--info" => print_report(&api::info(), json),
        "--cheat" => {
            let mut bad = DEMO_SOLUTION;
            bad[5] = 2;
            if !json {
                println!("cheating: cell 5 changed to 2 (row 1 becomes 3 2 1 2)\n");
            }
            print_report(&api::prove(&DEMO_CLUES, &bad), json);
        }
        "--tamper" => {
            // two honest proofs of the same board differ (fresh randomness);
            // A and B from one, C from the other: three valid points that
            // do not belong together
            let one = api::prove(&DEMO_CLUES, &DEMO_SOLUTION);
            let two = api::prove(&DEMO_CLUES, &DEMO_SOLUTION);
            let mut p = one.proof.clone().unwrap();
            p.c = two.proof.unwrap().c;
            if !json {
                println!("tampering: C taken from a different proof of the same board\n");
            }
            print_report(&api::verify(&DEMO_CLUES, &p), json);
        }
        "" => print_report(&api::prove(&DEMO_CLUES, &DEMO_SOLUTION), json),
        other => {
            eprintln!("unknown option {other}; try --info, --cheat, --tamper, --json, --version");
            std::process::exit(2);
        }
    }
}
