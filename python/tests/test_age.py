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
    Credential,
    issue_credential,
    proof_from_json,
    proof_to_json,
    prove_adult,
    verify_adult,
)
from zkp.group import PARAMS
from zkp.identity import KeyPair, keygen, sign, verify_sig
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


class OwnershipTests(unittest.TestCase):
    """The gate must know the proof is the holder's own, fresh, and issued."""

    def test_signature_roundtrip(self):
        kp = keygen()
        sig = sign(kp.sk, [1234, "hello"])
        self.assertTrue(verify_sig(kp.pk, [1234, "hello"], sig))
        self.assertFalse(verify_sig(kp.pk, [1234, "hellp"], sig))

    def test_answers_the_gates_challenge(self):
        cred = issue_credential(30)
        proof = prove_adult(cred, nonce="gate-session-1")
        ok, reason = verify_adult(proof, nonce="gate-session-1")
        self.assertTrue(ok, reason)

    def test_replay_with_new_challenge_rejected(self):
        cred = issue_credential(30)
        old_proof = prove_adult(cred, nonce="yesterday")
        ok, reason = verify_adult(old_proof, nonce="today")
        self.assertFalse(ok)
        self.assertIn("challenge", reason)

    def test_stolen_envelope_without_private_key_fails(self):
        victim = issue_credential(30)
        thief_key = keygen()
        # The thief has everything public (C, pk, signature) and even the
        # opening (age, r) - but not sk. The proof must still fail.
        stolen = Credential(
            age=victim.age,
            r=victim.r,
            C=victim.C,
            holder=KeyPair(sk=thief_key.sk, pk=victim.holder.pk),
            issuer_sig=victim.issuer_sig,
        )
        ok, reason = verify_adult(prove_adult(stolen, nonce="n"), nonce="n")
        self.assertFalse(ok)
        self.assertIn("owner", reason)

    def test_self_issued_envelope_rejected(self):
        # Anyone can seal age 99 and sign it with *their own* key. The gate
        # only trusts the ID office's key.
        rogue_office = keygen()
        cred = issue_credential(99, issuer=rogue_office)
        ok, reason = verify_adult(prove_adult(cred, nonce="n"), nonce="n")
        self.assertFalse(ok)
        self.assertIn("issuer", reason)

    def test_json_never_carries_the_private_key(self):
        cred = issue_credential(40)
        text = proof_to_json(prove_adult(cred, nonce="n"))
        self.assertNotIn("sk", json.loads(text))
        self.assertNotIn(hex(cred.holder.sk), text)
        self.assertNotIn(hex(cred.r), text)


class HostileInputTests(unittest.TestCase):
    def _payload(self):
        return json.loads(proof_to_json(prove_adult(issue_credential(30), nonce="n")))

    def test_zero_element_is_rejected_cleanly(self):
        d = self._payload()
        d["bit_commitments"][0] = "0x0"
        with self.assertRaises(ValueError):
            proof_from_json(json.dumps(d))

    def test_out_of_range_scalar_is_rejected(self):
        d = self._payload()
        d["consistency"]["s"] = hex(PARAMS.q)
        with self.assertRaises(ValueError):
            proof_from_json(json.dumps(d))

    def test_missing_field_is_a_value_error(self):
        d = self._payload()
        del d["owner"]
        with self.assertRaises(ValueError):
            proof_from_json(json.dumps(d))


if __name__ == "__main__":
    unittest.main(verbosity=2)
