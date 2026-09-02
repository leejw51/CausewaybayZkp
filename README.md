# GATE 18 — adult age ZKP, from scratch

Prove you are 18 or over **without revealing your age**. No Circom, snarkjs, arkworks, or other ZKP frameworks. The core is Python `pow` + SHA-256.

## Protocol (study version)

Everything runs in a **Schnorr group**: the 256-bit prime-order subgroup of the integers modulo a 259-bit prime \(p\).
A group element is an ordinary integer, \(g^{x}\) is `pow(g, x, p)`, and there are **no elliptic curves anywhere** in this
repo. ECDSA and Ed25519 run the same protocols in a different group, where an element is an \((x, y)\) point and the
operation is chord-and-tangent point addition. The algebra below is the same either way; only the group changes.

1. **Pedersen commitment** \(C = g^{age}\, h^{r}\) hides the age.
2. **Range proof by bits.** \(\delta = age - 18\) is 8 bits. Each bit is committed and proven to be 0 or 1 (Schnorr OR).
3. **Consistency Schnorr** shows those bits really sum to \(age - 18\).
4. **Fiat–Shamir** turns the interactive Sigma protocol into a JSON proof.
5. **Ownership.** Steps 1–4 only say *"whoever wrote this knows an opening of \(C\)"*. So the holder has a key pair
   \(pk = g^{sk}\), the ID office **signs** \((C, pk)\), the gate hands out a fresh **nonce** that goes into the
   Fiat–Shamir hash, and the proof carries a Schnorr proof of knowledge of \(sk\). The gate checks, in order:
   threshold → nonce → issuer signature → owner proof → consistency → bits.

What the gate learns: this envelope was sealed by the ID office for the person holding \(sk\), and the age inside is ≥ 18. Nothing else. A copied proof answers the wrong nonce; a stolen envelope cannot be answered for without \(sk\).

The ID office key here is a demo key made at start-up; a real deployment has a long-lived one whose public half every gate is configured with.

## Play it (Love2D)

Wonder Boy / Super Mario World 16-bit game of the same protocol.

```bash
brew install love
cd love2d
love .
```

Setup is written as JSONL to `~/.causewaybayzkp/setup.jsonl`. F11 fullscreen, F1 portrait/landscape. Details in `love2d/README.md`.

## Run the study desk

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
python/zkp/identity.py   holder keys, issuer signature, challenge
python/zkp/age.py        issue / prove / verify
python/app.py            Gradio GATE 18 desk
```

## License

MIT for the code. Fonts under `love2d/assets/fonts` are SIL Open Font License 1.1 (see the `*-OFL.txt` files next to them).
Scene art was generated with Grok (xAI) and Higgsfield; no third-party game characters appear.
