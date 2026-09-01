"""Pedersen commitment: hide a number, later prove things about it.

    C = g^x * h^r   (mod p)

Properties (under DL in the subgroup, and log_g(h) unknown):

- Perfectly hiding: for any x, r uniform ⇒ C is uniform in G.
  Two ages produce commitments that are indistinguishable.
- Computationally binding: finding (x, r) ≠ (x', r') with the same C
  means you know log_g(h) = (x - x') / (r' - r).

The holder keeps (x, r). Everyone else only sees C.
"""

from __future__ import annotations

from dataclasses import dataclass

from zkp.group import PARAMS, GroupParams


@dataclass(frozen=True)
class Opening:
    value: int
    randomness: int


def commit(value: int, randomness: int | None = None, params: GroupParams = PARAMS) -> tuple[int, Opening]:
    r = params.rand_scalar() if randomness is None else randomness % params.q
    C = params.mul(params.exp(params.g, value), params.exp(params.h, r))
    return C, Opening(value % params.q, r)


def verify_opening(C: int, opening: Opening, params: GroupParams = PARAMS) -> bool:
    expected = params.mul(
        params.exp(params.g, opening.value),
        params.exp(params.h, opening.randomness),
    )
    return expected == C
