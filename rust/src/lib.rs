//! GATE 18, quest 2: a real zk-SNARK.
//!
//! Quest 1 (python/zkp) proves "age >= 18" with Sigma protocols in a plain
//! integer group. This crate is the other kind of zero-knowledge proof: a
//! Groth16 zk-SNARK over the BN254 pairing curve, built with arkworks, for a
//! different mission — "I solved this 4x4 sudoku" without showing the
//! solution.
//!
//!   sudoku.rs   the mission as 112 equations of the form (a)*(b)=(c)
//!   api.rs      setup / prove / verify and the report the game shows
//!   ffi.rs      C ABI for LuaJIT `ffi` (Love2D) — JSON in, JSON out
//!
//! Nothing here is written from scratch on purpose: the point of quest 2 is
//! to see what a production SNARK stack looks like next to quest 1's hand
//! rolled Sigma protocol.

pub mod api;
pub mod ffi;
pub mod sudoku;
