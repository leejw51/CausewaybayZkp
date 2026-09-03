//! C ABI for LuaJIT's `ffi` (the Love2D game) and anything else that can
//! load a shared library.
//!
//! Every function that returns `*mut c_char` hands out a NUL-terminated JSON
//! string the caller must give back to `gate18_snark_free`. Inputs are
//! NUL-terminated JSON lists of 16 numbers (0 = empty cell). Errors come back
//! as JSON too: `{"ok":false,"verdict":"ERROR","reason":"..."}` — never a
//! crash across the boundary.

use std::ffi::{c_char, CStr, CString};

use serde_json::json;

use crate::api;

const VERSION: &str = concat!(env!("CARGO_PKG_VERSION"), "\0");

fn out(s: String) -> *mut c_char {
    // JSON never contains NUL; fall back to an error object if it somehow does
    CString::new(s)
        .unwrap_or_else(|_| CString::new(r#"{"ok":false,"verdict":"ERROR","reason":"NUL in output"}"#).unwrap())
        .into_raw()
}

fn error(reason: impl std::fmt::Display) -> *mut c_char {
    out(json!({ "ok": false, "verdict": "ERROR", "reason": reason.to_string() }).to_string())
}

/// # Safety
/// `p` must be NULL or a NUL-terminated string that outlives the call.
unsafe fn read(p: *const c_char, what: &str) -> Result<String, String> {
    if p.is_null() {
        return Err(format!("{what} is NULL"));
    }
    CStr::from_ptr(p).to_str().map(|s| s.to_string()).map_err(|e| format!("{what} is not UTF-8: {e}"))
}

fn guard(f: impl FnOnce() -> *mut c_char + std::panic::UnwindSafe) -> *mut c_char {
    match std::panic::catch_unwind(f) {
        Ok(p) => p,
        Err(_) => error("internal panic"),
    }
}

/// Crate version, static; do not free.
#[no_mangle]
pub extern "C" fn gate18_snark_version() -> *const c_char {
    VERSION.as_ptr() as *const c_char
}

/// The demo board: `{"clues":[..16],"solution":[..16],"constraints":112}`.
#[no_mangle]
pub extern "C" fn gate18_snark_demo() -> *mut c_char {
    guard(|| out(serde_json::to_string(&api::demo()).unwrap()))
}

/// Circuit and key facts (runs the setup on first call).
#[no_mangle]
pub extern "C" fn gate18_snark_info() -> *mut c_char {
    guard(|| out(serde_json::to_string(&api::info()).unwrap()))
}

/// Prove that `solution` solves `clues`, then verify. Returns a Report.
///
/// # Safety
/// Both pointers must be NULL or NUL-terminated strings.
#[no_mangle]
pub unsafe extern "C" fn gate18_snark_prove(clues: *const c_char, solution: *const c_char) -> *mut c_char {
    let clues = match read(clues, "clues") {
        Ok(s) => s,
        Err(e) => return error(e),
    };
    let solution = match read(solution, "solution") {
        Ok(s) => s,
        Err(e) => return error(e),
    };
    guard(move || {
        let clues = match api::board_from_json(&clues) {
            Ok(b) => b,
            Err(e) => return error(e),
        };
        let solution = match api::board_from_json(&solution) {
            Ok(b) => b,
            Err(e) => return error(e),
        };
        out(serde_json::to_string(&api::prove(&clues, &solution)).unwrap())
    })
}

/// Verify a proof (`{"a":hex,"b":hex,"c":hex}`) against `clues`. Returns a Report.
///
/// # Safety
/// Both pointers must be NULL or NUL-terminated strings.
#[no_mangle]
pub unsafe extern "C" fn gate18_snark_verify(clues: *const c_char, proof: *const c_char) -> *mut c_char {
    let clues = match read(clues, "clues") {
        Ok(s) => s,
        Err(e) => return error(e),
    };
    let proof = match read(proof, "proof") {
        Ok(s) => s,
        Err(e) => return error(e),
    };
    guard(move || {
        let clues = match api::board_from_json(&clues) {
            Ok(b) => b,
            Err(e) => return error(e),
        };
        let proof: api::ProofHex = match serde_json::from_str(&proof) {
            Ok(p) => p,
            Err(e) => return error(format!("proof must be {{a,b,c}} hex: {e}")),
        };
        out(serde_json::to_string(&api::verify(&clues, &proof)).unwrap())
    })
}

/// Give back a string from any function above. NULL is ignored.
///
/// # Safety
/// `p` must come from this library and not be freed twice.
#[no_mangle]
pub unsafe extern "C" fn gate18_snark_free(p: *mut c_char) {
    if !p.is_null() {
        drop(CString::from_raw(p));
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    unsafe fn take(p: *mut c_char) -> String {
        let s = CStr::from_ptr(p).to_str().unwrap().to_string();
        gate18_snark_free(p);
        s
    }

    #[test]
    fn prove_and_verify_over_the_c_abi() {
        let clues = CString::new("[1,0,0,4,0,4,1,0,0,1,4,0,4,0,0,1]").unwrap();
        let sol = CString::new("[1,2,3,4,3,4,1,2,2,1,4,3,4,3,2,1]").unwrap();
        let r: serde_json::Value = unsafe { serde_json::from_str(&take(gate18_snark_prove(clues.as_ptr(), sol.as_ptr()))).unwrap() };
        assert_eq!(r["ok"], true);
        let proof = r["proof"].to_string();
        let proof = CString::new(proof).unwrap();
        let v: serde_json::Value = unsafe { serde_json::from_str(&take(gate18_snark_verify(clues.as_ptr(), proof.as_ptr()))).unwrap() };
        assert_eq!(v["ok"], true);
    }

    #[test]
    fn bad_input_is_an_error_object_not_a_crash() {
        let r: serde_json::Value = unsafe { serde_json::from_str(&take(gate18_snark_prove(std::ptr::null(), std::ptr::null()))).unwrap() };
        assert_eq!(r["verdict"], "ERROR");
        let junk = CString::new("not json").unwrap();
        let r: serde_json::Value = unsafe { serde_json::from_str(&take(gate18_snark_prove(junk.as_ptr(), junk.as_ptr()))).unwrap() };
        assert_eq!(r["verdict"], "ERROR");
        unsafe { gate18_snark_free(std::ptr::null_mut()) };
    }

    #[test]
    fn version_is_a_c_string() {
        let v = unsafe { CStr::from_ptr(gate18_snark_version()) }.to_str().unwrap();
        assert_eq!(v, env!("CARGO_PKG_VERSION"));
    }
}
