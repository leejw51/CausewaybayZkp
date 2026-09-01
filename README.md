# GATE 18 — adult age ZKP, from scratch

Prove you are 18 or over **without revealing your age**. No Circom, snarkjs, arkworks, or other ZKP frameworks. The core is Python `pow` + SHA-256.

## Protocol (study version)

1. **Pedersen commitment** \(C = g^{age}\, h^{r}\) hides the age.
2. **Range proof by bits.** \(\delta = age - 18\) is 8 bits. Each bit is committed and proven to be 0 or 1 (Schnorr OR).
3. **Consistency Schnorr** shows those bits really sum to \(age - 18\).
4. **Fiat–Shamir** turns the interactive Sigma protocol into a JSON proof.

A real deployment still needs a trusted issuer who binds \(C\) to a person. The ZKP only proves a fact about \(C\).

## Run

```bash
cd python
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python3 tests/test_age.py
python3 app.py
```

The Gradio desk **binds to `0.0.0.0:7860`**.

- This machine: `http://127.0.0.1:7860`
- iPhone on the same Wi-Fi: `http://<your-lan-ip>:7860` (printed in the terminal and the gold bar at the top)

If the phone cannot connect, allow Python incoming connections in **System Settings → Network → Firewall**.

## Layout

```
python/zkp/group.py      Schnorr group, Fiat–Shamir hash
python/zkp/pedersen.py   Pedersen commitment
python/zkp/sigma.py      Schnorr + bit 0/1 OR proofs
python/zkp/age.py        issue / prove / verify
python/app.py            Gradio GATE 18 desk
```
