"""Adult age verification with a from-scratch Sigma-protocol ZKP.

No zk-SNARK / Circom / arkworks / libsnark stack. The protocol is:

  Pedersen commitment  +  bit-wise 0/1 OR proofs  +  Fiat–Shamir
  +  holder key, issuer signature, per-check challenge (identity.py)

so a verifier can be convinced that a committed age is at least 18
without learning the age, and that the envelope was issued to the
person standing at the gate.
"""

from zkp.age import (
    ADULT_AGE,
    ISSUER,
    N_BITS,
    AgeProof,
    Credential,
    issue_credential,
    proof_from_json,
    proof_to_json,
    prove_adult,
    verify_adult,
)
from zkp.group import PARAMS
from zkp.identity import KeyPair, Signature, keygen, sign, verify_sig
from zkp.pedersen import commit

__all__ = [
    "ADULT_AGE",
    "ISSUER",
    "N_BITS",
    "PARAMS",
    "AgeProof",
    "Credential",
    "KeyPair",
    "Signature",
    "commit",
    "issue_credential",
    "keygen",
    "proof_from_json",
    "proof_to_json",
    "prove_adult",
    "sign",
    "verify_adult",
    "verify_sig",
]
