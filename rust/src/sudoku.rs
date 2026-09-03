//! The mission of quest 2: "I solved this 4x4 mini-sudoku" as an arithmetic
//! circuit.
//!
//! Words used everywhere below (the game explains them the same way):
//!
//!   cell        one of the 16 squares of the board, numbered 0..15 left to
//!               right, top to bottom. Every cell holds 1, 2, 3 or 4.
//!   clue        a cell whose value is printed on the board. Everyone sees it.
//!               0 means "not printed" (hidden).
//!   solution    all 16 values. Only the solver knows them. This is the
//!               SECRET, called the *witness* in SNARK language.
//!   row / col / box
//!               the 4 rows, 4 columns and 4 two-by-two boxes. Each must hold
//!               1, 2, 3, 4 exactly once.
//!   constraint  one equation the circuit forces to be true. Groth16 only
//!               understands equations of the shape  (a) * (b) = (c).
//!
//! The whole puzzle becomes 112 such equations (see `CONSTRAINTS`):
//!
//!   16 x  clue * (cell - clue) = 0     a printed cell must match its clue
//!   16 x  (v-1)(v-2)(v-3)(v-4) = 0     each cell is one of 1..4 (3 mults)
//!   12 x  v1+v2+v3+v4 = 10             row / col / box: the four add to 10
//!   12 x  v1*v2*v3*v4 = 24             ...and multiply to 24 (3 mults)
//!
//! Four values in 1..4 that add to 10 AND multiply to 24 are always a
//! permutation of 1,2,3,4 (the other candidates give 16, 27, 32 or 36), so
//! "sum = 10, product = 24" is a cheap way to say "each number once".

use ark_bn254::Fr;
use ark_ff::Field;
use ark_r1cs_std::alloc::AllocVar;
use ark_r1cs_std::eq::EqGadget;
use ark_r1cs_std::fields::fp::FpVar;
use ark_r1cs_std::fields::FieldVar;
use ark_relations::r1cs::{ConstraintSynthesizer, ConstraintSystemRef, SynthesisError};

/// Board side. The circuit is written for 4x4 only (2x2 boxes).
pub const N: usize = 4;
/// Number of cells.
pub const CELLS: usize = N * N;
/// Number of R1CS constraints the circuit produces. The game quotes this
/// number; `tests::constraint_count_is_documented` keeps it honest.
pub const CONSTRAINTS: usize = 16 + 16 * 3 + 12 * 4;
/// What the four values of a row / column / box add up to.
pub const LINE_SUM: u64 = 1 + 2 + 3 + 4;
/// What the four values of a row / column / box multiply to.
pub const LINE_PRODUCT: u64 = 1 * 2 * 3 * 4;

/// A board: 16 values in reading order, 0 = empty.
pub type Board = [u8; CELLS];

/// The demo board the game and the CLI use. Clues are printed cells, the
/// solution fills them all. Any valid solution would pass; this one is the
/// one Mei found.
pub const DEMO_CLUES: Board = [
    1, 0, 0, 4, //
    0, 4, 1, 0, //
    0, 1, 4, 0, //
    4, 0, 0, 1, //
];
pub const DEMO_SOLUTION: Board = [
    1, 2, 3, 4, //
    3, 4, 1, 2, //
    2, 1, 4, 3, //
    4, 3, 2, 1, //
];

/// The 12 lines that must each be a permutation of 1..4: four rows, four
/// columns, four 2x2 boxes. Each entry lists 4 cell indexes.
pub fn lines() -> Vec<[usize; N]> {
    let mut out = Vec::with_capacity(12);
    for r in 0..N {
        out.push([r * N, r * N + 1, r * N + 2, r * N + 3]);
    }
    for c in 0..N {
        out.push([c, c + N, c + 2 * N, c + 3 * N]);
    }
    for br in 0..2 {
        for bc in 0..2 {
            let o = br * 2 * N + bc * 2;
            out.push([o, o + 1, o + N, o + N + 1]);
        }
    }
    out
}

/// Plain-integer check of a solution against clues: the same rules the
/// circuit enforces, written the ordinary way. Used by tests and the CLI so a
/// reader can compare the two.
pub fn check_plain(clues: &Board, solution: &Board) -> Result<(), String> {
    for i in 0..CELLS {
        let v = solution[i];
        if !(1..=4).contains(&v) {
            return Err(format!("cell {i} holds {v}, must be 1..4"));
        }
        if clues[i] != 0 && clues[i] != v {
            return Err(format!("cell {i} is printed as {} but the solution says {v}", clues[i]));
        }
    }
    for (k, line) in lines().iter().enumerate() {
        let sum: u64 = line.iter().map(|&i| solution[i] as u64).sum();
        let product: u64 = line.iter().map(|&i| solution[i] as u64).product();
        if sum != LINE_SUM || product != LINE_PRODUCT {
            return Err(format!("line {k} {:?} is not 1,2,3,4 once each", line.map(|i| solution[i])));
        }
    }
    Ok(())
}

/// The circuit. `clues` are public inputs (Uncle Wing sees them), `solution`
/// is the private witness (only Mei has it; `None` while the keys are made).
#[derive(Clone, Debug)]
pub struct SudokuCircuit {
    pub clues: Board,
    pub solution: Option<Board>,
}

impl SudokuCircuit {
    pub fn new(clues: Board, solution: Option<Board>) -> Self {
        Self { clues, solution }
    }

    /// Public inputs in the order the verifier must supply them: the 16
    /// clue values as field elements.
    pub fn public_inputs(clues: &Board) -> Vec<Fr> {
        clues.iter().map(|&v| Fr::from(v as u64)).collect()
    }
}

impl ConstraintSynthesizer<Fr> for SudokuCircuit {
    fn generate_constraints(self, cs: ConstraintSystemRef<Fr>) -> Result<(), SynthesisError> {
        let zero = FpVar::<Fr>::zero();

        // clue[i]  public: what is printed in cell i (0 = nothing printed)
        let clue: Vec<FpVar<Fr>> = (0..CELLS)
            .map(|i| FpVar::new_input(cs.clone(), || Ok(Fr::from(self.clues[i] as u64))))
            .collect::<Result<_, _>>()?;

        // cell[i]  secret: what Mei wrote in cell i
        let cell: Vec<FpVar<Fr>> = (0..CELLS)
            .map(|i| {
                FpVar::new_witness(cs.clone(), || {
                    self.solution
                        .map(|s| Fr::from(s[i] as u64))
                        .ok_or(SynthesisError::AssignmentMissing)
                })
            })
            .collect::<Result<_, _>>()?;

        for i in 0..CELLS {
            // printed cells must match:  clue * (cell - clue) = 0
            // (if clue is 0 the equation is 0 = 0 and says nothing)
            clue[i].mul_equals(&(&cell[i] - &clue[i]), &zero)?;

            // each cell is 1, 2, 3 or 4:  (v-1)(v-2)(v-3)(v-4) = 0
            // three multiplications, so three constraints
            let v = &cell[i];
            let t1 = (v - Fr::from(1u64)) * (v - Fr::from(2u64));
            let t2 = &t1 * (v - Fr::from(3u64));
            t2.mul_equals(&(v - Fr::from(4u64)), &zero)?;
        }

        let ten = FpVar::<Fr>::constant(Fr::from(LINE_SUM));
        let twenty_four = FpVar::<Fr>::constant(Fr::from(LINE_PRODUCT));
        for line in lines() {
            let [a, b, c, d] = line;
            // the four add to 10: additions are free, the "= 10" is 1 constraint
            (&cell[a] + &cell[b] + &cell[c] + &cell[d]).enforce_equal(&ten)?;
            // the four multiply to 24: three multiplications
            let p1 = &cell[a] * &cell[b];
            let p2 = &p1 * &cell[c];
            p2.mul_equals(&cell[d], &twenty_four)?;
        }
        Ok(())
    }
}

/// Human-readable board, four rows of four, `.` for empty.
pub fn render(board: &Board) -> String {
    let mut s = String::new();
    for r in 0..N {
        let row: Vec<String> = (0..N)
            .map(|c| {
                let v = board[r * N + c];
                if v == 0 {
                    ".".to_string()
                } else {
                    v.to_string()
                }
            })
            .collect();
        s.push_str(&row.join(" "));
        s.push('\n');
    }
    s
}

#[cfg(test)]
mod tests {
    use super::*;
    use ark_relations::r1cs::ConstraintSystem;

    #[test]
    fn demo_solution_is_valid() {
        check_plain(&DEMO_CLUES, &DEMO_SOLUTION).unwrap();
    }

    #[test]
    fn sum_and_product_single_out_permutations() {
        // every multiset of four values in 1..4 with sum 10: only 1,2,3,4 has product 24
        let mut hits = 0;
        for a in 1..=4u64 {
            for b in 1..=4u64 {
                for c in 1..=4u64 {
                    for d in 1..=4u64 {
                        if a + b + c + d == LINE_SUM && a * b * c * d == LINE_PRODUCT {
                            let mut s = [a, b, c, d];
                            s.sort();
                            assert_eq!(s, [1, 2, 3, 4]);
                            hits += 1;
                        }
                    }
                }
            }
        }
        assert_eq!(hits, 24, "4! orderings of 1,2,3,4");
    }

    #[test]
    fn constraint_count_is_documented() {
        let cs = ConstraintSystem::<Fr>::new_ref();
        SudokuCircuit::new(DEMO_CLUES, Some(DEMO_SOLUTION))
            .generate_constraints(cs.clone())
            .unwrap();
        assert!(cs.is_satisfied().unwrap());
        assert_eq!(cs.num_constraints(), CONSTRAINTS);
        assert_eq!(cs.num_instance_variables(), 1 + CELLS, "the constant 1 plus 16 clues");
    }

    #[test]
    fn a_wrong_cell_breaks_the_circuit() {
        let mut bad = DEMO_SOLUTION;
        bad[5] = 2; // row 1 becomes 3 2 1 2
        assert!(check_plain(&DEMO_CLUES, &bad).is_err());
        let cs = ConstraintSystem::<Fr>::new_ref();
        SudokuCircuit::new(DEMO_CLUES, Some(bad)).generate_constraints(cs.clone()).unwrap();
        assert!(!cs.is_satisfied().unwrap());
    }
}
