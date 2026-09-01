"""Self-tests for the from-scratch age ZKP. Run: python3 tests/test_age.py"""

from __future__ import annotations

import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

from zkp.age import (
    ADULT_AGE,
    MAX_AGE,
    N_BITS,
    issue_credential,
    proof_from_json,
    proof_to_json,
    prove_adult,
    verify_adult,
)
from zkp.group import PARAMS
from zkp.pedersen import commit, verify_opening
from zkp.sigma import bit_announce, bit_commit, bit_respond, bit_verify


class GroupTests(unittest.TestCase):
    def test_generators_have_order_q(self):
        self.assertEqual(pow(PARAMS.g, PARAMS.q, PARAMS.p), 1)
        self.assertEqual(pow(PARAMS.h, PARAMS.q, PARAMS.p), 1)
        self.assertNotEqual(PARAMS.g, 1)
        self.assertNotEqual(PARAMS.h, 1)
        self.assertNotEqual(PARAMS.g, PARAMS.h)


class PedersenTests(unittest.TestCase):
    def test_open_roundtrip(self):
        C, opening = commit(27)
        self.assertTrue(verify_opening(C, opening))

    def test_hiding_same_age_different_C(self):
        C1, _ = commit(30)
        C2, _ = commit(30)
        self.assertNotEqual(C1, C2)


class BitProofTests(unittest.TestCase):
    def test_bit_zero_and_one(self):
        for b in (0, 1):
            C, r = bit_commit(b)
            draft = bit_announce(C, b, r)
            proof = bit_respond(draft, challenge=12345)
            self.assertTrue(bit_verify(C, proof, 12345))


class AgeProofTests(unittest.TestCase):
    def test_honest_adults_verify(self):
        for age in (18, 21, 40, 99, MAX_AGE):
            cred = issue_credential(age)
            proof = prove_adult(cred)
            ok, reason = verify_adult(proof)
            self.assertTrue(ok, reason)

    def test_underage_cannot_prove(self):
        cred = issue_credential(17)
        with self.assertRaises(ValueError):
            prove_adult(cred)

    def test_json_roundtrip(self):
        cred = issue_credential(24)
        proof = prove_adult(cred)
        restored = proof_from_json(proof_to_json(proof))
        ok, _ = verify_adult(restored)
        self.assertTrue(ok)

    def test_tamper_commitment_fails(self):
        cred = issue_credential(30)
        proof = prove_adult(cred)
        payload = json.loads(proof_to_json(proof))
        payload["C"] = hex((int(payload["C"], 16) ^ 1) % PARAMS.p or 2)
        forged = proof_from_json(json.dumps(payload))
        ok, _ = verify_adult(forged)
        self.assertFalse(ok)

    def test_wrong_threshold_rejected(self):
        cred = issue_credential(17)
        proof = prove_adult(cred, threshold=16)
        ok, reason = verify_adult(proof, threshold=ADULT_AGE)
        self.assertFalse(ok)
        self.assertIn("threshold", reason)

    def test_proof_does_not_contain_age(self):
        cred = issue_credential(47)
        payload = json.loads(proof_to_json(prove_adult(cred)))
        self.assertNotIn("age", payload)
        self.assertNotIn("r", payload)
        self.assertNotIn("witness", payload)
        self.assertNotIn("bits", payload)
        # Witness r is a 256-bit scalar; it must not appear as a JSON number.
        self.assertTrue(all(not isinstance(v, int) or v in (18, 8) for v in payload.values()))

    def test_n_bits_constant(self):
        self.assertEqual(N_BITS, 8)


if __name__ == "__main__":
    unittest.main(verbosity=2)
