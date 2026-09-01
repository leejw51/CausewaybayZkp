"""Schnorr group used by every protocol in this repo.

We work in the prime-order subgroup of Z_p^*:

    G = { g^k mod p  |  k in 0..q-1 }

with |G| = q, both p and q prime, q | (p-1). Discrete log in G is
assumed hard. All exponents are taken modulo q; all group elements
live in 1..p-1.

Parameters were generated locally (nothing-up-my-sleeve generators:
g and h are hash-to-subgroup, so nobody knows log_g(h)). That unknown
discrete log is what makes Pedersen commitments binding.
"""

from __future__ import annotations

import hashlib
from dataclasses import dataclass


def _int(hex_str: str) -> int:
    return int(hex_str, 16)


@dataclass(frozen=True)
class GroupParams:
    p: int  # modulus
    q: int  # prime order of the subgroup
    g: int  # generator
    h: int  # second generator; log_g(h) unknown

    def exp(self, base: int, exponent: int) -> int:
        """base^exponent in the subgroup (exponent mod q)."""
        return pow(base, exponent % self.q, self.p)

    def mul(self, a: int, b: int) -> int:
        return (a * b) % self.p

    def inv(self, a: int) -> int:
        return pow(a, -1, self.p)

    def rand_scalar(self) -> int:
        import secrets

        # Uniform in 1..q-1 (0 would make some announcements trivial).
        return secrets.randbelow(self.q - 1) + 1


# 256-bit prime-order subgroup inside a 259-bit prime field.
# k = 12 so p = 12q + 1.
PARAMS = GroupParams(
    p=_int("646c2d6591a893974106a55e4e3cb0fd7a358b92adf6fa70301eaa43e1ce395ad"),
    q=_int("85e591dcc2361a1f015e31d312fb96a74d9cba18e7f3f895957e385a82684c79"),
    g=_int("4f52513364fb04597cbd9b1a278f4ca96daa07ba9c4e55426759dfc385dc9de4f"),
    h=_int("352c5fac5ce061f6f55e1382c1c656d099f164b3919490ba157775fdf82c7aaa9"),
)


def encode_int(n: int) -> bytes:
    length = max(1, (n.bit_length() + 7) // 8)
    return n.to_bytes(length, "big")


def fiat_shamir(*parts: int | str | bytes, q: int = PARAMS.q) -> int:
    """Deterministic challenge from a transcript (Fiat–Shamir).

    Each part is length-prefixed so the encoding is unambiguous.
    The interactive Sigma-protocol challenge is replaced by a hash
    of everything the verifier would have seen before issuing it.
    """
    h = hashlib.sha256()
    h.update(b"causewaybay-age-zkp-v1")
    for part in parts:
        if isinstance(part, int):
            blob = encode_int(part)
        elif isinstance(part, str):
            blob = part.encode("utf-8")
        else:
            blob = part
        h.update(len(blob).to_bytes(4, "big"))
        h.update(blob)
    # 256-bit hash into a 256-bit q: negligible bias, fine for study.
    c = int.from_bytes(h.digest(), "big") % q
    return c if c != 0 else 1
