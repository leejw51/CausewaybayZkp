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

Or just `make start` (and `make stop`).

## Open it on a phone

The Gradio desk **binds to `0.0.0.0:7860`**. `make start` prints every address it is
reachable on:

```
started   pid 13970
local     http://127.0.0.1:7860
wifi      http://192.168.x.x:7860
tailscale http://100.x.x.x:7860
magicdns  http://<machine>.<tailnet>.ts.net:7860
```

- **Same Wi-Fi** — use the `wifi` line. If the phone cannot connect, allow Python
  incoming connections in **System Settings → Network → Firewall**.
- **Anywhere** — use the `tailscale` line, with [Tailscale](https://tailscale.com)
  running on both the Mac and the phone. This also works on cellular and on captive
  networks that block peer-to-peer traffic. `make tailscale` prints it on its own.

The Tailscale lines are queried live from the local `tailscale` CLI and are skipped
with a one-line note if it is not installed or not connected.

> The desk has **no authentication**. Anyone who can reach the port can use it. That is
> fine on a tailnet or a home LAN; do not run it on open Wi-Fi.

## Layout

```
python/zkp/group.py      Schnorr group, Fiat–Shamir hash
python/zkp/pedersen.py   Pedersen commitment
python/zkp/sigma.py      Schnorr + bit 0/1 OR proofs
python/zkp/age.py        issue / prove / verify
python/app.py            Gradio GATE 18 desk
```
