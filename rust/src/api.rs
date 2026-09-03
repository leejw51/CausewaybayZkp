//! Groth16 over BN254 for the sudoku circuit: setup, prove, verify, and a
//! JSON report the game prints on screen.
//!
//! Words, in the order they appear on the game's streets:
//!
//!   setup       made once per circuit, before any proof. Picks secret random
//!               numbers (tau, alpha, beta, gamma, delta — the "toxic waste"),
//!               hides them inside curve points and throws the numbers away.
//!               Out come two keys.
//!   pk          proving key. Big (many curve points). Mei uses it to prove.
//!   vk          verifying key. Small. Uncle Wing uses it to check.
//!   proof       three curve points A, B, C — 128 bytes compressed — no matter
//!               how big the circuit is. That is the "S" of SNARK: succinct.
//!   pairing     e(P, Q): the one operation that can multiply two hidden
//!               numbers. Verifying is four pairings and a comparison.
//!
//! The study desk seeds the setup from a fixed seed so every run prints the
//! same vk. In real life the seed IS the toxic waste: a fixed seed means
//! anyone who reads this file could forge proofs. A real deployment runs a
//! ceremony where many people each add randomness and delete their share.

use std::time::Instant;

use ark_bn254::{Bn254, Fr};
use ark_groth16::{prepare_verifying_key, Groth16, PreparedVerifyingKey, Proof, ProvingKey, VerifyingKey};
use ark_relations::r1cs::{ConstraintSynthesizer, ConstraintSystem, SynthesisMode};
use ark_serialize::{CanonicalDeserialize, CanonicalSerialize};
use ark_snark::SNARK;
use rand::SeedableRng;
use rand_chacha::ChaCha20Rng;
use serde::{Deserialize, Serialize};

use crate::sudoku::{check_plain, Board, SudokuCircuit, CELLS, CONSTRAINTS, DEMO_CLUES, DEMO_SOLUTION};

/// Seed of the study-desk ceremony. See the module note: this is the toxic
/// waste, printed in the open, on purpose, so the game can talk about it.
pub const SETUP_SEED: [u8; 32] = *b"GATE18 quest2 toxic waste seed!!";

pub struct Keys {
    pub pk: ProvingKey<Bn254>,
    pub vk: VerifyingKey<Bn254>,
    pub pvk: PreparedVerifyingKey<Bn254>,
    pub setup_ms: f64,
}

fn ms(since: Instant) -> f64 {
    (since.elapsed().as_secs_f64() * 1000.0 * 100.0).round() / 100.0
}

fn hex(bytes: &[u8]) -> String {
    bytes.iter().map(|b| format!("{b:02x}")).collect()
}

fn unhex(s: &str) -> Result<Vec<u8>, String> {
    let s = s.trim().trim_start_matches("0x");
    if s.len() % 2 != 0 {
        return Err("hex string has odd length".into());
    }
    (0..s.len())
        .step_by(2)
        .map(|i| u8::from_str_radix(&s[i..i + 2], 16).map_err(|e| format!("bad hex: {e}")))
        .collect()
}

fn compressed<T: CanonicalSerialize>(t: &T) -> Vec<u8> {
    let mut out = Vec::new();
    t.serialize_compressed(&mut out).expect("serialize");
    out
}

/// Run the trusted setup for the sudoku circuit.
pub fn setup() -> Keys {
    let t = Instant::now();
    let mut rng = ChaCha20Rng::from_seed(SETUP_SEED);
    let circuit = SudokuCircuit::new(DEMO_CLUES, None);
    let (pk, vk) = Groth16::<Bn254>::circuit_specific_setup(circuit, &mut rng).expect("setup");
    let pvk = prepare_verifying_key(&vk);
    Keys { pk, vk, pvk, setup_ms: ms(t) }
}

/// Keys made once per process. The setup is the slow step (tens of ms).
pub fn keys() -> &'static Keys {
    use std::sync::OnceLock;
    static KEYS: OnceLock<Keys> = OnceLock::new();
    KEYS.get_or_init(setup)
}

/// The proof as the game shows it: three hex strings.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct ProofHex {
    /// A: a point of G1 (32 bytes compressed)
    pub a: String,
    /// B: a point of G2 (64 bytes compressed)
    pub b: String,
    /// C: a point of G1 (32 bytes compressed)
    pub c: String,
    /// total size in bytes (informational; not needed to verify)
    #[serde(default)]
    pub bytes: usize,
}

impl ProofHex {
    pub fn from_proof(p: &Proof<Bn254>) -> Self {
        let a = compressed(&p.a);
        let b = compressed(&p.b);
        let c = compressed(&p.c);
        Self { bytes: a.len() + b.len() + c.len(), a: hex(&a), b: hex(&b), c: hex(&c) }
    }

    pub fn to_proof(&self) -> Result<Proof<Bn254>, String> {
        let a = CanonicalDeserialize::deserialize_compressed(&unhex(&self.a)?[..]).map_err(|e| format!("A: {e}"))?;
        let b = CanonicalDeserialize::deserialize_compressed(&unhex(&self.b)?[..]).map_err(|e| format!("B: {e}"))?;
        let c = CanonicalDeserialize::deserialize_compressed(&unhex(&self.c)?[..]).map_err(|e| format!("C: {e}"))?;
        Ok(Proof { a, b, c })
    }
}

#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Timings {
    pub setup: f64,
    pub prove: f64,
    pub verify: f64,
}

/// Everything the game prints for one prove + verify round.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Report {
    /// did the verifier accept?
    pub ok: bool,
    /// "ACCEPT" or "REJECT"
    pub verdict: String,
    /// why, when rejected (empty when accepted)
    pub reason: String,
    /// the printed cells (public input)
    pub clues: Vec<u8>,
    /// the secret never leaves the prover; only its size is reported
    pub secret_cells: usize,
    /// number of (a)*(b)=(c) equations in the circuit
    pub constraints: usize,
    /// number of public inputs the verifier feeds in (the 16 clues)
    pub public_inputs: usize,
    /// number of variables in the witness vector (1, inputs, secrets, temporaries)
    pub variables: usize,
    pub proof: Option<ProofHex>,
    /// verifying key, compressed, in bytes
    pub vk_bytes: usize,
    /// proving key, compressed, in bytes
    pub pk_bytes: usize,
    /// short fingerprint of the vk so the game can show "the same key every run"
    pub vk_id: String,
    /// pairings the verifier computes
    pub pairings: usize,
    pub ms: Timings,
}

fn base_report(clues: &Board) -> Report {
    let k = keys();
    let vk = compressed(&k.vk);
    let pk = compressed(&k.pk);
    // cheap fingerprint: first 8 bytes of the compressed vk
    let vk_id = hex(&vk[..8]);
    // count the equations without a witness: setup mode never asks for values
    let cs = ConstraintSystem::<Fr>::new_ref();
    cs.set_mode(SynthesisMode::Setup);
    SudokuCircuit::new(*clues, None).generate_constraints(cs.clone()).expect("shape");
    Report {
        ok: false,
        verdict: "REJECT".into(),
        reason: String::new(),
        clues: clues.to_vec(),
        secret_cells: CELLS,
        constraints: cs.num_constraints(),
        public_inputs: CELLS,
        variables: cs.num_instance_variables() + cs.num_witness_variables(),
        proof: None,
        vk_bytes: vk.len(),
        pk_bytes: pk.len(),
        vk_id,
        pairings: 4,
        ms: Timings { setup: k.setup_ms, prove: 0.0, verify: 0.0 },
    }
}

/// Facts about the circuit and the keys, no proof.
pub fn info() -> Report {
    let mut r = base_report(&DEMO_CLUES);
    r.verdict = "INFO".into();
    r
}

/// Mei proves: the solution stays here, a 128-byte proof goes out. The
/// report also runs the verifier once so the game can show both halves.
pub fn prove(clues: &Board, solution: &Board) -> Report {
    let mut r = base_report(clues);
    if let Err(e) = check_plain(clues, solution) {
        // An honest prover would notice before proving. (A dishonest one
        // gets a proof the verifier rejects; try `--cheat` on the CLI.)
        r.reason = format!("the solution does not solve the board: {e}");
    }
    let k = keys();
    let t = Instant::now();
    let mut rng = ChaCha20Rng::from_entropy();
    let circuit = SudokuCircuit::new(*clues, Some(*solution));
    let proof = match Groth16::<Bn254>::prove(&k.pk, circuit, &mut rng) {
        Ok(p) => p,
        Err(e) => {
            r.reason = format!("prove failed: {e}");
            return r;
        }
    };
    r.ms.prove = ms(t);
    r.proof = Some(ProofHex::from_proof(&proof));
    let t = Instant::now();
    let inputs = SudokuCircuit::public_inputs(clues);
    let ok = Groth16::<Bn254>::verify_with_processed_vk(&k.pvk, &inputs, &proof).unwrap_or(false);
    r.ms.verify = ms(t);
    r.ok = ok;
    r.verdict = if ok { "ACCEPT" } else { "REJECT" }.into();
    if ok {
        r.reason.clear();
    } else if r.reason.is_empty() {
        r.reason = "the proof does not verify against these clues".into();
    }
    r
}

/// Uncle Wing verifies: clues + proof + vk, nothing else.
pub fn verify(clues: &Board, proof: &ProofHex) -> Report {
    let mut r = base_report(clues);
    r.proof = Some(proof.clone());
    let k = keys();
    let t = Instant::now();
    let parsed = match proof.to_proof() {
        Ok(p) => p,
        Err(e) => {
            r.reason = format!("proof bytes are not curve points: {e}");
            r.ms.verify = ms(t);
            return r;
        }
    };
    let inputs = SudokuCircuit::public_inputs(clues);
    let ok = Groth16::<Bn254>::verify_with_processed_vk(&k.pvk, &inputs, &parsed).unwrap_or(false);
    r.ms.verify = ms(t);
    r.ok = ok;
    r.verdict = if ok { "ACCEPT" } else { "REJECT" }.into();
    if !ok {
        r.reason = "the proof does not verify against these clues".into();
    }
    r
}

/// Parse a board from JSON: a list of 16 integers 0..4.
pub fn board_from_json(json: &str) -> Result<Board, String> {
    let v: Vec<u8> = serde_json::from_str(json).map_err(|e| format!("board must be a JSON list of 16 numbers: {e}"))?;
    if v.len() != CELLS {
        return Err(format!("board has {} cells, need {CELLS}", v.len()));
    }
    if let Some(bad) = v.iter().find(|&&x| x > 4) {
        return Err(format!("cell value {bad} is not 0..4"));
    }
    let mut b = [0u8; CELLS];
    b.copy_from_slice(&v);
    Ok(b)
}

/// The demo board, for callers that do not want to type one.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Demo {
    pub clues: Vec<u8>,
    pub solution: Vec<u8>,
    pub constraints: usize,
}

pub fn demo() -> Demo {
    Demo { clues: DEMO_CLUES.to_vec(), solution: DEMO_SOLUTION.to_vec(), constraints: CONSTRAINTS }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn honest_proof_verifies() {
        let r = prove(&DEMO_CLUES, &DEMO_SOLUTION);
        assert!(r.ok, "{}", r.reason);
        let p = r.proof.unwrap();
        assert_eq!(p.bytes, 128, "A(32) + B(64) + C(32) compressed");
        assert_eq!(r.constraints, CONSTRAINTS);
        assert_eq!(r.public_inputs, CELLS);
    }

    #[test]
    fn verify_is_independent_of_the_prover() {
        let r = prove(&DEMO_CLUES, &DEMO_SOLUTION);
        let v = verify(&DEMO_CLUES, r.proof.as_ref().unwrap());
        assert!(v.ok);
    }

    #[test]
    fn wrong_solution_is_rejected() {
        let mut bad = DEMO_SOLUTION;
        bad[5] = 2;
        let r = prove(&DEMO_CLUES, &bad);
        assert!(!r.ok);
    }

    #[test]
    fn different_clues_reject_a_good_proof() {
        let r = prove(&DEMO_CLUES, &DEMO_SOLUTION);
        let mut other = DEMO_CLUES;
        other[1] = 3; // claims cell 1 is printed as 3; the solution has 2
        let v = verify(&other, r.proof.as_ref().unwrap());
        assert!(!v.ok);
    }

    #[test]
    fn tampered_proof_is_rejected() {
        let r = prove(&DEMO_CLUES, &DEMO_SOLUTION);
        let mut p = r.proof.unwrap();
        // flip the last hex digit of C
        let last = p.c.pop().unwrap();
        p.c.push(if last == '0' { '1' } else { '0' });
        let v = verify(&DEMO_CLUES, &p);
        assert!(!v.ok);
    }

    #[test]
    fn setup_is_reproducible() {
        let a = setup();
        let b = setup();
        assert_eq!(compressed(&a.vk), compressed(&b.vk));
    }

    #[test]
    fn board_json_roundtrip() {
        let b = board_from_json("[1,0,0,4,0,4,1,0,0,1,4,0,4,0,0,1]").unwrap();
        assert_eq!(b, DEMO_CLUES);
        assert!(board_from_json("[1,2]").is_err());
        assert!(board_from_json("[9,0,0,4,0,4,1,0,0,1,4,0,4,0,0,1]").is_err());
    }
}
