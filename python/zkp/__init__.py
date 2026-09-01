"""Adult age verification with a from-scratch Sigma-protocol ZKP.

No zk-SNARK / Circom / arkworks / libsnark stack. The protocol is:

  Pedersen commitment  +  bit-wise 0/1 OR proofs  +  Fiat–Shamir

so a verifier can be convinced that a committed age is at least 18
without learning the age.
"""

from zkp.age import (
    ADULT_AGE,
    N_BITS,
    Credential,
    AgeProof,
    issue_credential,
    prove_adult,
    verify_adult,
    proof_to_json,
    proof_from_json,
)
from zkp.group import PARAMS
from zkp.pedersen import commit

__all__ = [
    "ADULT_AGE",
    "N_BITS",
    "PARAMS",
    "Credential",
    "AgeProof",
    "commit",
    "issue_credential",
    "prove_adult",
    "verify_adult",
    "proof_to_json",
    "proof_from_json",
]
