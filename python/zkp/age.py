"""Prove "this committed age is at least 18" without revealing the age.

Statement the verifier checks
-----------------------------
Public: Pedersen commitment C = g^{age} h^{r}, threshold T = 18.
Witness (kept by the holder): (age, r).

Prove:  I know (age, r) such that C opens to age  AND  age ∈ [T, T + 2^n).

How (range proof by bits)
-------------------------
Let δ = age − T. Write δ as n bits b_i ∈ {0,1}:

    δ = Σ b_i  2^i     (so age = T + δ ∈ [T, T + 2^n))

Commit to each bit:  C_i = g^{b_i} h^{r_i}.
For each i, an OR-proof shows C_i hides 0 or 1 (not 2, not 7, …).

Homomorphism gives the consistency check for free if we also prove
that the leftover randomness matches:

    D  =  C / ( g^T  ·  Π C_i^{2^i} )   =   h^{r − Σ r_i 2^i}

A Schnorr proof that D is a power of h shows D commits to 0, i.e. the
bits really sum to age − T.

Fiat–Shamir: one SHA-256 over the whole transcript is the challenge.
The verifier never sees age, r, the bits, or the r_i's.

Soundness sketch: if age < T then δ < 0, which is not an n-bit unsigned
integer. Forging bits that still satisfy the D-check means either
breaking the 0/1 OR proofs or opening a Pedersen commitment two ways.

Hiding: Pedersen is perfectly hiding, and each Sigma protocol is HVZK,
so the transcript is simulatable without the age.

This is a study protocol. A deployed ID system still needs a trusted
issuer (or a PKI) who binds C to a real person — otherwise anyone can
commit to 99 and prove they are "adult". The ZKP only proves a fact
about C, not about the human.
"""

from __future__ import annotations

import json
from dataclasses import asdict, dataclass

from zkp.group import PARAMS, GroupParams, fiat_shamir
from zkp.pedersen import commit
from zkp.sigma import (
    BitProof,
    SchnorrProof,
    bit_announce,
    bit_commit,
    bit_respond,
    bit_verify,
    schnorr_prove,
    schnorr_verify,
)

ADULT_AGE = 18
N_BITS = 8  # δ in [0, 255] → ages 18..273
MAX_AGE = ADULT_AGE + (1 << N_BITS) - 1


@dataclass(frozen=True)
class Credential:
    """Issued secret. The holder keeps this; the world only sees C."""

    age: int
    r: int
    C: int


@dataclass(frozen=True)
class AgeProof:
    threshold: int
    n_bits: int
    C: int
    bit_commitments: tuple[int, ...]
    bit_proofs: tuple[BitProof, ...]
    consistency: SchnorrProof


def issue_credential(age: int, params: GroupParams = PARAMS) -> Credential:
    """ID office: bind a real age into a Pedersen commitment.

    In a real deployment this step is the trusted issuer (passport
    office). The holder receives (age, r) and everyone can see C.
    """
    if age < 0 or age > MAX_AGE:
        raise ValueError(f"age must be in 0..{MAX_AGE} for this study range")
    C, opening = commit(age, params=params)
    return Credential(age=age, r=opening.randomness, C=C)


def _bits(delta: int, n: int) -> list[int]:
    return [(delta >> i) & 1 for i in range(n)]


def _challenge(proof_like: dict, announcements: list[int], params: GroupParams) -> int:
    return fiat_shamir(
        params.p,
        params.q,
        params.g,
        params.h,
        proof_like["threshold"],
        proof_like["n_bits"],
        proof_like["C"],
        *proof_like["bit_commitments"],
        *announcements,
        q=params.q,
    )


def prove_adult(cred: Credential, threshold: int = ADULT_AGE, n_bits: int = N_BITS, params: GroupParams = PARAMS) -> AgeProof:
    age = cred.age
    if age < threshold:
        raise ValueError(
            f"cannot prove age >= {threshold}: credential age is {age}. "
            "An honest prover refuses rather than trying to forge."
        )
    delta = age - threshold
    if delta >= (1 << n_bits):
        raise ValueError(f"age {age} exceeds the {n_bits}-bit range (max {threshold + (1 << n_bits) - 1})")

    bits = _bits(delta, n_bits)
    bit_Cs: list[int] = []
    bit_rs: list[int] = []
    drafts = []
    for b in bits:
        C_i, r_i = bit_commit(b, params=params)
        bit_Cs.append(C_i)
        bit_rs.append(r_i)
        drafts.append(bit_announce(C_i, b, r_i, params=params))

    r_bits = sum(r_i * (1 << i) for i, r_i in enumerate(bit_rs)) % params.q
    r_diff = (cred.r - r_bits) % params.q

    # D = C / (g^T · Π C_i^{2^i})  should equal h^{r_diff}
    gT = params.exp(params.g, threshold)
    product = 1
    for i, C_i in enumerate(bit_Cs):
        product = params.mul(product, params.exp(C_i, 1 << i))
    D = params.mul(cred.C, params.inv(params.mul(gT, product)))

    k_cons = params.rand_scalar()
    t_cons = params.exp(params.h, k_cons)

    announcements = [t_cons] + [x for d in drafts for x in (d.t0, d.t1)]
    c = _challenge(
        {"threshold": threshold, "n_bits": n_bits, "C": cred.C, "bit_commitments": bit_Cs},
        announcements,
        params,
    )

    cons = SchnorrProof(t=t_cons, s=(k_cons + c * r_diff) % params.q)
    bit_proofs = tuple(bit_respond(d, c, params=params) for d in drafts)
    return AgeProof(
        threshold=threshold,
        n_bits=n_bits,
        C=cred.C,
        bit_commitments=tuple(bit_Cs),
        bit_proofs=bit_proofs,
        consistency=cons,
    )


def _derived_D(proof: AgeProof, params: GroupParams) -> int:
    gT = params.exp(params.g, proof.threshold)
    product = 1
    for i, C_i in enumerate(proof.bit_commitments):
        product = params.mul(product, params.exp(C_i, 1 << i))
    return params.mul(proof.C, params.inv(params.mul(gT, product)))


def verify_adult(
    proof: AgeProof,
    threshold: int = ADULT_AGE,
    params: GroupParams = PARAMS,
) -> tuple[bool, str]:
    """Return (ok, reason). The verifier's policy threshold is an argument —
    a proof for '>= 16' must not be accepted at a door that requires 18.
    """
    if proof.threshold != threshold:
        return False, f"proof is for threshold {proof.threshold}, verifier requires {threshold}"
    if proof.n_bits != N_BITS:
        return False, f"unexpected bit length {proof.n_bits}"
    if len(proof.bit_commitments) != proof.n_bits or len(proof.bit_proofs) != proof.n_bits:
        return False, "bit commitment / proof count mismatch"

    announcements = [proof.consistency.t] + [x for bp in proof.bit_proofs for x in (bp.t0, bp.t1)]
    c = _challenge(
        {
            "threshold": proof.threshold,
            "n_bits": proof.n_bits,
            "C": proof.C,
            "bit_commitments": list(proof.bit_commitments),
        },
        announcements,
        params,
    )

    D = _derived_D(proof, params)
    if not schnorr_verify(D, proof.consistency, c, params=params):
        return False, "consistency Schnorr failed (bits do not sum to age − threshold)"

    for i, (C_i, bp) in enumerate(zip(proof.bit_commitments, proof.bit_proofs)):
        if not bit_verify(C_i, bp, c, params=params):
            return False, f"bit {i} is not proven to be 0 or 1"

    return True, "accept: committed age is in [{}, {}]".format(threshold, threshold + (1 << proof.n_bits) - 1)


def _hex(n: int) -> str:
    return hex(n)


def proof_to_json(proof: AgeProof) -> str:
    payload = {
        "threshold": proof.threshold,
        "n_bits": proof.n_bits,
        "C": _hex(proof.C),
        "bit_commitments": [_hex(c) for c in proof.bit_commitments],
        "bit_proofs": [
            {k: _hex(v) for k, v in asdict(bp).items()} for bp in proof.bit_proofs
        ],
        "consistency": {"t": _hex(proof.consistency.t), "s": _hex(proof.consistency.s)},
    }
    return json.dumps(payload, indent=2)


def proof_from_json(text: str) -> AgeProof:
    d = json.loads(text)
    return AgeProof(
        threshold=int(d["threshold"]),
        n_bits=int(d["n_bits"]),
        C=int(d["C"], 16),
        bit_commitments=tuple(int(x, 16) for x in d["bit_commitments"]),
        bit_proofs=tuple(
            BitProof(**{k: int(v, 16) for k, v in bp.items()}) for bp in d["bit_proofs"]
        ),
        consistency=SchnorrProof(t=int(d["consistency"]["t"], 16), s=int(d["consistency"]["s"], 16)),
    )


def inspect_delta_bits(age: int, threshold: int = ADULT_AGE, n_bits: int = N_BITS) -> dict:
    """Prover-side study helper: the bits of (age − T). Verifier never gets this."""
    if age < threshold:
        return {"ok": False, "reason": f"age {age} < {threshold}"}
    delta = age - threshold
    bits = _bits(delta, n_bits)
    return {
        "ok": True,
        "age": age,
        "threshold": threshold,
        "delta": delta,
        "bits": bits,
        "recombined": sum(b << i for i, b in enumerate(bits)),
    }
