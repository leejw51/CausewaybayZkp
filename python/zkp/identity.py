"""Who owns the envelope?  Holder keys, issuer signature, session challenge.

The range proof in age.py only shows this:

    "whoever wrote this proof knows an opening (age, r) of C with age >= 18"

It says nothing about *whose* envelope C is. Anyone can seal a fresh C with
age = 99 and prove it, and a valid proof file can be copied and replayed.
Three additions close that gap, all built from the same Schnorr group:

1. Holder key.        sk is random in Z_q and never leaves the holder;
                      pk = g^sk is public. This is the prover's private key.
2. Issuer signature.  The ID office signs (C, pk). The gate trusts the
                      office's public key, so a good signature means
                      "this envelope was sealed by the office for the
                      owner of pk".
3. Session challenge. The gate picks a fresh random nonce for each check
                      and the prover mixes it into the Fiat-Shamir hash.
                      A proof is therefore valid for one conversation
                      only; yesterday's JSON is worthless today.

The age proof then also carries a Schnorr proof of knowledge of sk under
that same challenge. Only the holder of sk can write it, so the proof is
bound to the person, not just to the envelope.

The signature is textbook Schnorr over base g:

    sign:    k random,  R = g^k,  c = H(R, pk, msg),  s = k + c * sk  (mod q)
    verify:  g^s  ==  R * pk^c
"""

from __future__ import annotations

from dataclasses import dataclass

from zkp.group import PARAMS, GroupParams, fiat_shamir


@dataclass(frozen=True)
class KeyPair:
    """sk stays with its owner. pk = g^sk is what the world sees."""

    sk: int
    pk: int


@dataclass(frozen=True)
class Signature:
    R: int
    s: int


def keygen(params: GroupParams = PARAMS) -> KeyPair:
    sk = params.rand_scalar()
    return KeyPair(sk=sk, pk=params.exp(params.g, sk))


def sign(sk: int, parts: list[int | str | bytes], params: GroupParams = PARAMS) -> Signature:
    """Schnorr signature of a transcript by the holder of sk."""
    pk = params.exp(params.g, sk)
    k = params.rand_scalar()
    R = params.exp(params.g, k)
    c = fiat_shamir("sig", R, pk, *parts, q=params.q)
    return Signature(R=R, s=(k + c * sk) % params.q)


def verify_sig(pk: int, parts: list[int | str | bytes], sig: Signature, params: GroupParams = PARAMS) -> bool:
    c = fiat_shamir("sig", sig.R, pk, *parts, q=params.q)
    return params.exp(params.g, sig.s) == params.mul(sig.R, params.exp(pk, c))
