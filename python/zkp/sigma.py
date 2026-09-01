"""Sigma protocols: Schnorr proof of discrete log, and 0/1 OR proofs.

A Sigma protocol is a 3-move dance:

    Prover → Verifier :  announcement  t
    Verifier → Prover :  challenge     c
    Prover → Verifier :  response      s

Honest-verifier zero-knowledge: if c is random (or a hash of t), a
simulator can produce (t, c, s) that look like a real transcript
without knowing the witness.

We compile the interactive protocol to non-interactive with Fiat–Shamir:
c = Hash(public statement || announcements).
"""

from __future__ import annotations

from dataclasses import dataclass

from zkp.group import PARAMS, GroupParams


@dataclass(frozen=True)
class SchnorrProof:
    """PoK{ x : Y = h^x }. Completeness: h^s = t * Y^c."""

    t: int
    s: int


def schnorr_prove(Y: int, x: int, challenge: int, params: GroupParams = PARAMS, base: int | None = None) -> SchnorrProof:
    """Interactive form: the challenge is already known. With Fiat-Shamir the
    challenge depends on t, so age.py announces t first and responds later."""
    base = params.h if base is None else base
    k = params.rand_scalar()
    t = params.exp(base, k)
    s = (k + challenge * (x % params.q)) % params.q
    return SchnorrProof(t=t, s=s)


def schnorr_verify(Y: int, proof: SchnorrProof, challenge: int, params: GroupParams = PARAMS, base: int | None = None) -> bool:
    """base^s == t * Y^c. Base h for commitment randomness, base g for keys."""
    base = params.h if base is None else base
    left = params.exp(base, proof.s)
    right = params.mul(proof.t, params.exp(Y, challenge))
    return left == right


@dataclass(frozen=True)
class BitProof:
    """OR-proof that C is a Pedersen commitment to 0 or to 1.

    Branch 0: C = h^r          (bit = 0)
    Branch 1: C = g * h^r      (bit = 1)

    The true branch is a real Schnorr; the false branch is simulated
    by picking (c_fake, s_fake) first and solving for t_fake.
    The verifier sees both branches and cannot tell which is real
    because c0 + c1 = challenge.
    """

    t0: int
    t1: int
    c0: int
    c1: int
    s0: int
    s1: int


@dataclass
class _BitDraft:
    """Prover state between announcement and response."""

    bit: int
    r: int
    C: int
    t0: int
    t1: int
    c_sim: int
    s_sim: int
    k_real: int


def bit_commit(bit: int, r: int | None = None, params: GroupParams = PARAMS) -> tuple[int, int]:
    if bit not in (0, 1):
        raise ValueError("bit must be 0 or 1")
    if r is None:
        r = params.rand_scalar()
    C = params.mul(params.exp(params.g, bit), params.exp(params.h, r))
    return C, r


def bit_announce(C: int, bit: int, r: int, params: GroupParams = PARAMS) -> _BitDraft:
    """Phase 1: produce t0, t1. The true branch uses a fresh nonce;
    the false branch is simulated so we can pick its challenge later.
    """
    if bit not in (0, 1):
        raise ValueError("bit must be 0 or 1")
    c_sim = params.rand_scalar()
    s_sim = params.rand_scalar()
    k_real = params.rand_scalar()
    g_inv = params.inv(params.g)
    C_over_g = params.mul(C, g_inv)

    if bit == 0:
        t0 = params.exp(params.h, k_real)
        # Simulate branch 1: t1 = h^{s1} / (C/g)^{c1}
        t1 = params.mul(params.exp(params.h, s_sim), params.inv(params.exp(C_over_g, c_sim)))
    else:
        t1 = params.exp(params.h, k_real)
        # Simulate branch 0: t0 = h^{s0} / C^{c0}
        t0 = params.mul(params.exp(params.h, s_sim), params.inv(params.exp(C, c_sim)))

    return _BitDraft(bit=bit, r=r, C=C, t0=t0, t1=t1, c_sim=c_sim, s_sim=s_sim, k_real=k_real)


def bit_respond(draft: _BitDraft, challenge: int, params: GroupParams = PARAMS) -> BitProof:
    """Phase 2: split the global challenge across the two branches."""
    q = params.q
    if draft.bit == 0:
        c1 = draft.c_sim
        s1 = draft.s_sim
        c0 = (challenge - c1) % q
        s0 = (draft.k_real + c0 * draft.r) % q
    else:
        c0 = draft.c_sim
        s0 = draft.s_sim
        c1 = (challenge - c0) % q
        s1 = (draft.k_real + c1 * draft.r) % q
    return BitProof(t0=draft.t0, t1=draft.t1, c0=c0, c1=c1, s0=s0, s1=s1)


def bit_verify(C: int, proof: BitProof, challenge: int, params: GroupParams = PARAMS) -> bool:
    if (proof.c0 + proof.c1) % params.q != challenge % params.q:
        return False
    C_over_g = params.mul(C, params.inv(params.g))
    check0 = params.exp(params.h, proof.s0) == params.mul(proof.t0, params.exp(C, proof.c0))
    check1 = params.exp(params.h, proof.s1) == params.mul(proof.t1, params.exp(C_over_g, proof.c1))
    return check0 and check1


def bit_announcements_for_hash(proof_or_draft: BitProof | _BitDraft) -> tuple[int, int]:
    return proof_or_draft.t0, proof_or_draft.t1
