"""GATE 18 — adult age verification, from-scratch ZKP, Gradio study desk.

Binds to 0.0.0.0 so a phone on the same Wi-Fi can open the lab.
"""

from __future__ import annotations

import base64
import socket
from pathlib import Path

import gradio as gr

from zkp.age import (
    ADULT_AGE,
    MAX_AGE,
    N_BITS,
    Credential,
    inspect_delta_bits,
    issue_credential,
    proof_from_json,
    proof_to_json,
    prove_adult,
    verify_adult,
)
from zkp.group import PARAMS

ROOT = Path(__file__).resolve().parent
ASSETS = ROOT / "assets"

PORT = 7860
HOST = "0.0.0.0"


def _uri(name: str) -> str:
    path = ASSETS / name
    b64 = base64.b64encode(path.read_bytes()).decode("ascii")
    return f"data:image/jpeg;base64,{b64}"


def lan_ip() -> str:
    try:
        sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        sock.connect(("8.8.8.8", 80))
        ip = sock.getsockname()[0]
        sock.close()
        return ip
    except OSError:
        return "127.0.0.1"


PAPER = _uri("paper-texture.jpg")
HERO = _uri("hero-gate.jpg")
ID_CARD = _uri("id-redacted.jpg")
STAMP_ADMIT = str(ASSETS / "stamp-admit.jpg")
STAMP_DENY = str(ASSETS / "stamp-deny.jpg")
STAMP_IDLE = str(ASSETS / "plaque-gate18.jpg")

HEAD = """
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Cormorant+Garamond:ital,wght@0,500;0,600;0,700;1,500&family=Figtree:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap" rel="stylesheet">
<meta name="viewport" content="width=device-width, initial-scale=1, viewport-fit=cover">
<meta name="apple-mobile-web-app-capable" content="yes">
<meta name="apple-mobile-web-app-status-bar-style" content="black-translucent">
<meta name="theme-color" content="#12182A">
<style>
  /* Lives in <head> on purpose: Gradio re-scopes the css= string under
     `.gradio-container .contain`, which cannot reach .main (an ancestor of
     .contain). Gradio's default 32px side padding wastes a sixth of a phone. */
  @media (max-width: 768px) {
    .gradio-container > .main.app { padding: 12px 12px 32px !important; }
  }
</style>
"""

CSS = f"""
:root {{
  --ink: #12182A;
  --navy: #1C2A4A;
  --manila: #E4D2AE;
  --cream: #F3E6CC;
  --gold: #C9A45C;
  --stamp: #8F1D1D;
  --admit: #2C5A3F;
  --graphite: #3A342C;
}}

html, body {{
  background: var(--ink) !important;
}}

.gradio-container {{
  max-width: 1120px !important;
  /* Gradio 6 makes <body> a flex column and the container a flex item. With
     the default min-width:auto the container grows to its content's minimum
     width (the tab bar, a wide formula) instead of the viewport, so the whole
     page scrolls sideways on a phone. Let it shrink. */
  min-width: 0 !important;
  width: 100% !important;
  margin: 0 auto !important;
  padding: 0 0 4rem !important;
  font-family: "Figtree", sans-serif !important;
  background: var(--ink) !important;
  color: var(--cream) !important;
}}

footer {{
  display: none !important;
}}

#phone-bar {{
  position: sticky;
  top: 0;
  z-index: 40;
  background: #0c1020;
  color: var(--gold);
  font-family: "IBM Plex Mono", monospace;
  font-size: 12px;
  letter-spacing: 0.04em;
  padding: 10px 16px;
  padding-top: max(10px, env(safe-area-inset-top));
  border-bottom: 1px solid rgba(201, 164, 92, 0.35);
  text-align: center;
}}

.hero {{
  position: relative;
  margin: 0;
  overflow: hidden;
  min-height: 280px;
}}
.hero img {{
  width: 100%;
  height: 42vw;
  max-height: 420px;
  min-height: 240px;
  object-fit: cover;
  display: block;
  filter: saturate(0.85) contrast(1.05);
}}
.hero-veil {{
  position: absolute;
  inset: 0;
  background: linear-gradient(180deg, rgba(18,24,42,0.15) 0%, rgba(18,24,42,0.55) 45%, rgba(18,24,42,0.92) 100%);
}}
.hero-copy {{
  position: absolute;
  left: 0; right: 0; bottom: 0;
  padding: 28px 24px 32px;
}}
.eyebrow {{
  font-family: "IBM Plex Mono", monospace;
  font-size: 11px;
  letter-spacing: 0.28em;
  text-transform: uppercase;
  color: var(--gold);
  margin: 0 0 8px;
}}
.hero h1 {{
  font-family: "Cormorant Garamond", serif;
  font-weight: 600;
  font-size: clamp(32px, 6vw, 64px);
  line-height: 0.95;
  color: #F7ECD4;
  margin: 0 0 10px;
  max-width: 16ch;
}}
.lede {{
  font-size: 16px;
  color: rgba(243, 230, 204, 0.82);
  margin: 0;
  max-width: 42ch;
}}

.page {{
  background-image: url("{PAPER}");
  background-size: cover;
  background-color: var(--manila);
  color: var(--ink);
  border: 1px solid rgba(18, 24, 42, 0.25);
  box-shadow: 0 18px 40px rgba(0,0,0,0.35);
  padding: 22px 20px 26px !important;
  border-radius: 2px !important;
}}

.kicker {{
  font-family: "IBM Plex Mono", monospace;
  font-size: 10px;
  letter-spacing: 0.32em;
  text-transform: uppercase;
  color: var(--stamp) !important;
  margin: 0 0 4px;
}}
.page-title {{
  font-family: "Cormorant Garamond", serif;
  font-size: 32px;
  font-weight: 600;
  margin: 0 0 6px;
  color: var(--navy) !important;
}}
.page-note {{
  font-size: 14px;
  color: var(--graphite) !important;
  margin: 0 0 16px;
}}

button {{
  min-height: 48px !important;
  border-radius: 2px !important;
  font-family: "Figtree", sans-serif !important;
  font-weight: 600 !important;
  letter-spacing: 0.04em !important;
  text-transform: uppercase !important;
  font-size: 13px !important;
}}

#issue-btn button {{
  background: var(--navy) !important;
  color: var(--cream) !important;
  border: none !important;
}}
#prove-btn button {{
  background: var(--gold) !important;
  color: var(--ink) !important;
  border: none !important;
}}
#verify-btn button {{
  background: var(--stamp) !important;
  color: #f7ecd4 !important;
  border: none !important;
}}
#tamper-btn button {{
  background: transparent !important;
  color: var(--ink) !important;
  border: 1px solid var(--ink) !important;
}}

textarea, input {{
  font-family: "IBM Plex Mono", monospace !important;
  font-size: 12px !important;
}}

#stamp-frame img {{
  width: 100%;
  max-width: 280px;
  margin: 0 auto;
  display: block;
  mix-blend-mode: multiply;
  transform: rotate(-8deg);
}}

#id-preview img {{
  width: 100%;
  max-height: 280px;
  object-fit: cover;
  border: 1px solid rgba(18,24,42,0.2);
}}

@media (max-width: 768px) {{
  .hero h1 {{ font-size: 36px; }}
  .hero img {{ height: 52vw; min-height: 200px; }}
  .page {{ margin-bottom: 12px; }}
  button {{ width: 100% !important; }}
}}

#lab-notes {{
  background: #161d32 !important;
  border: 1px solid rgba(201, 164, 92, 0.28);
  margin: 16px 0 0;
  padding: 8px 10px 18px;
}}
/* Gradio hides tabs that do not fit behind an overflow menu it never shows
   on this layout, so the 4th tab was unreachable on a phone. Wrap instead. */
#lab-notes [role="tablist"] {{
  flex-wrap: wrap !important;
  overflow: visible !important;
  height: auto !important;
}}
/* the mobile `button {{ width: 100% }}` rule below must not stretch tab buttons */
#lab-notes [role="tab"] {{
  width: auto !important;
  flex: 0 0 auto !important;
}}
#lab-notes h2, #lab-notes h3 {{
  font-family: "Cormorant Garamond", serif !important;
  color: var(--gold) !important;
}}
#lab-notes p, #lab-notes li, #lab-notes td, #lab-notes th {{
  color: var(--cream) !important;
}}
/* Gradio ships `.prose * {{ color: var(--body-text-color) }}`, which repaints
   every KaTeX glyph span individually. Colouring only the .katex container is
   therefore invisible to the glyphs — the descendants must be targeted too,
   with !important, exactly as the p/li/td rules above do. Scoped to #lab-notes
   because the study box renders math on light parchment, where dark ink is
   correct. */
#lab-notes .katex, #lab-notes .katex-display,
#lab-notes .katex *, #lab-notes .katex-display * {{
  color: var(--cream) !important;
}}
#lab-notes .katex-display {{
  overflow-x: auto;
  overflow-y: hidden;
  padding: 8px 0;
}}
#lab-notes pre, #lab-notes code {{
  font-family: "IBM Plex Mono", monospace !important;
  font-size: 12px !important;
}}
#lab-notes table {{
  width: 100%;
  font-size: 14px;
}}
"""


LATEX = [
    {"left": "$$", "right": "$$", "display": True},
    {"left": "$", "right": "$", "display": False},
]


def lecture_flow() -> str:
    """Three pictures, no library: who sees what, how the proof is built,
    and the three-move Sigma dance that Fiat-Shamir collapses into a hash.

    Inline SVG so it renders offline and scales on a phone. Colour is the
    lesson: manila boxes are SECRET (never leave the holder), navy boxes
    with a gold tag are PUBLIC (what the gate actually receives).
    """
    return """
<style>
  .flow { font-family: "Figtree", sans-serif; color: #F3E6CC; }
  /* Gradio's theme paints b/em/span/code with its own (light-theme) ink,
     which beats a colour set on the parent. Pin every inline element. */
  .flow p, .flow li, .flow ol, .flow span, .flow em, .flow i { color: inherit !important; }
  .flow b, .flow strong { color: #C9A45C !important; font-weight: 700; }
  .flow em { font-style: italic; }
  .flow code { color: #E4D2AE !important; background: transparent !important; }
  .flow figcaption, .flow figcaption * { color: #E4D2AE !important; }
  .flow figcaption b { color: #C9A45C !important; }
  .flow .legend, .flow .legend span { color: #E4D2AE !important; }
  .flow figure { margin: 0 0 28px; overflow-x: auto; -webkit-overflow-scrolling: touch; }
  .flow .intro { background: #1C2A4A; border: 1px solid rgba(201,164,92,.35); border-radius: 10px;
                 padding: 14px 18px 6px; margin: 4px 0 22px; color: #F3E6CC; font-size: 15px; line-height: 1.55; }
  .flow .intro .eyebrow { color: #C9A45C; font-size: 12px; letter-spacing: 2px; text-transform: uppercase; margin: 0 0 4px; }
  .flow .intro h3 { font-family: "Cormorant Garamond", serif; color: #C9A45C; font-size: 22px; margin: 6px 0 6px; }
  .flow .intro p, .flow .intro li { color: #F3E6CC; margin: 0 0 10px; }
  .flow .intro ol { padding-left: 22px; margin: 0 0 6px; }
  .flow .intro code { font-family: "IBM Plex Mono", monospace; font-size: 13px; color: #E4D2AE; }
  .flow figcaption { color: #E4D2AE; font-size: 14px; line-height: 1.5; margin-top: 8px; }
  /* On a phone the 640-unit canvas would shrink text below 9px. Hold a floor
     and let the figure scroll sideways instead of the page. */
  .flow svg { width: 100%; min-width: 480px; height: auto; display: block; }
  .flow .t   { fill: #F3E6CC; font-size: 15px; }
  .flow .m   { fill: #F3E6CC; font-size: 14px; font-family: "IBM Plex Mono", monospace; }
  .flow .h   { fill: #C9A45C; font-size: 13px; letter-spacing: 2px; font-weight: 600; }
  .flow .cap { fill: #E4D2AE; font-size: 13px; }
  .flow .ink { fill: #12182A; }
  .flow .pub  { fill: #1C2A4A; stroke: #C9A45C; stroke-opacity: .6; }
  .flow .sec  { fill: #E4D2AE; stroke: #C9A45C; }
  .flow .tag  { fill: #C9A45C; }
  .flow .tagt { fill: #12182A; font-size: 10px; font-weight: 700; letter-spacing: 1.5px; }
  .flow .ar   { stroke: #C9A45C; stroke-width: 1.6; fill: none; marker-end: url(#arr); }
  .flow .lane { stroke: #C9A45C; stroke-opacity: .25; stroke-dasharray: 4 4; }
  /* iOS hides scrollbars, so say that the picture continues to the right */
  @media (max-width: 600px) {
    .flow figure::before { content: "swipe sideways to see the whole picture  →"; display: block;
      color: #C9A45C; font-size: 11px; letter-spacing: 1px; text-transform: uppercase; margin: 0 0 6px; }
  }
  .flow .legend { display: flex; gap: 18px; align-items: center; color: #E4D2AE; font-size: 13px; margin: 0 0 14px; }
  .flow .sw { display: inline-block; width: 14px; height: 14px; border-radius: 3px; vertical-align: -2px; margin-right: 6px; border: 1px solid #C9A45C; }
</style>
<div class="flow">

<div class="intro">
  <p class="eyebrow">Start here · no maths</p>
  <h3>The bouncer problem</h3>
  <p>To get into a club you show your ID. The bouncer needs <em>one</em> fact — are you 18 or over? —
  but your card hands over your name, your exact birthday, your address, your photo.
  A <b>zero-knowledge proof</b> is a way to convince the bouncer of that one fact while they learn
  <em>nothing else</em>. Not your birthday. Not even whether you are 19 or 45.</p>

  <h3>Three ideas, in plain words</h3>
  <ol>
    <li><b>The sealed envelope.</b> Your age goes into an envelope and it is sealed. Everyone can see
      the envelope — call it <code>C</code> — but not what is inside. Crucially, you cannot quietly swap
      the contents later. (Maths name: <em>commitment</em>.)</li>
    <li><b>The check.</b> The proof is a bundle of arithmetic that anyone can run against the envelope.
      The arithmetic only works out if the number inside is 18 or more. If it were 17, no bundle exists
      that passes. (Maths name: <em>range proof</em>.)</li>
    <li><b>The surprise question.</b> Why can't you fake the bundle? Because half-way through, a
      random question is thrown at you that you could not have prepared for. Passing a question you
      did not choose is only possible if you actually know the secret. Here the "question" is a
      hash, so nobody has to be present to ask it. (Maths name: <em>challenge</em>, <em>Fiat–Shamir</em>.)</li>
  </ol>
  <p>That is the whole idea. Everything below is those three sentences, drawn.</p>
</div>

<div class="legend">
  <span><i class="sw" style="background:#E4D2AE"></i>secret — stays with the holder</span>
  <span><i class="sw" style="background:#1C2A4A"></i>public — the gate sees this</span>
</div>

<figure>
<svg viewBox="0 0 640 250" role="img" aria-label="Three parties: ID office, holder, gate">
  <defs><marker id="arr" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto">
    <path d="M0,0 L10,5 L0,10 z" fill="#C9A45C"/></marker></defs>

  <text x="115" y="42" class="h" text-anchor="middle">ID OFFICE</text>
  <text x="320" y="42" class="h" text-anchor="middle">HOLDER</text>
  <text x="525" y="42" class="h" text-anchor="middle">GATE</text>

  <rect x="20"  y="56" width="190" height="118" rx="8" class="pub"/>
  <rect x="225" y="56" width="190" height="118" rx="8" class="sec"/>
  <rect x="430" y="56" width="190" height="118" rx="8" class="pub"/>

  <text x="115" y="86"  class="t" text-anchor="middle">sees the real age</text>
  <text x="115" y="112" class="t" text-anchor="middle">seals it in envelope C</text>
  <text x="115" y="138" class="t" text-anchor="middle">hands back (age, r)</text>
  <text x="115" y="160" class="cap" text-anchor="middle">trusted, once</text>

  <text x="320" y="86"  class="t ink" text-anchor="middle">keeps age and r</text>
  <text x="320" y="112" class="t ink" text-anchor="middle">publishes C</text>
  <text x="320" y="138" class="t ink" text-anchor="middle">writes proof π</text>
  <text x="320" y="160" class="cap ink" text-anchor="middle">nothing here leaves</text>

  <text x="525" y="86"  class="t" text-anchor="middle">receives C and π</text>
  <text x="525" y="112" class="t" text-anchor="middle">runs the checks</text>
  <text x="525" y="138" class="t" text-anchor="middle">learns: age ≥ 18</text>
  <text x="525" y="160" class="cap" text-anchor="middle">and nothing else</text>

  <path d="M210,115 L223,115" class="ar"/>
  <path d="M415,115 L428,115" class="ar"/>
  <text x="217" y="200" class="m" text-anchor="middle">(age, r)</text>
  <text x="422" y="200" class="m" text-anchor="middle">π  (JSON)</text>
  <path d="M217,186 L217,178" class="lane"/>
  <path d="M422,186 L422,178" class="lane"/>

  <text x="320" y="236" class="cap" text-anchor="middle">The secret lives in the middle box. No arrow out of it carries the age.</text>
</svg>
<figcaption><b>1 · Who sees what.</b> Think of the ID office as the one party you trust to look at
your real age — once. It seals that age into the envelope <code>C</code> and gives you the key
(<code>r</code>). From then on you can prove things about the envelope without ever opening it.
The bouncer only ever holds the envelope and your proof.</figcaption>
</figure>

<figure>
<svg viewBox="0 0 640 572" role="img" aria-label="How the proof is built, top to bottom">
  <rect x="40" y="16" width="220" height="44" rx="8" class="sec"/>
  <text x="150" y="43" class="m ink" text-anchor="middle">age,  r</text>
  <path d="M260,38 L338,38" class="ar"/>
  <rect x="340" y="16" width="260" height="44" rx="8" class="pub"/>
  <text x="470" y="43" class="m" text-anchor="middle">C = g^age · h^r</text>
  <rect x="540" y="8" width="58" height="16" rx="8" class="tag"/><text x="569" y="20" class="tagt" text-anchor="middle">PUBLIC</text>

  <path d="M150,60 L150,96" class="ar"/>
  <rect x="40" y="98" width="220" height="44" rx="8" class="sec"/>
  <text x="150" y="125" class="m ink" text-anchor="middle">δ = age − 18</text>
  <path d="M260,120 L338,120" class="ar"/>
  <rect x="340" y="98" width="260" height="44" rx="8" class="sec"/>
  <text x="470" y="125" class="m ink" text-anchor="middle">bits  b7 … b1 b0</text>
  <text x="150" y="160" class="cap" text-anchor="middle">must be 0…255 to have an 8-bit form</text>

  <path d="M470,142 L470,178" class="ar"/>
  <rect x="120" y="180" width="400" height="44" rx="8" class="pub"/>
  <text x="320" y="207" class="m" text-anchor="middle">Cᵢ = g^bᵢ · h^rᵢ    (one per bit, ×8)</text>
  <rect x="460" y="172" width="58" height="16" rx="8" class="tag"/><text x="489" y="184" class="tagt" text-anchor="middle">PUBLIC</text>

  <path d="M200,224 L200,262" class="ar"/>
  <path d="M440,224 L440,262" class="ar"/>
  <rect x="40"  y="264" width="270" height="92" rx="8" class="pub"/>
  <text x="175" y="290" class="t" text-anchor="middle">8 × OR-proof</text>
  <text x="175" y="314" class="m" text-anchor="middle">each Cᵢ hides 0 or 1</text>
  <text x="175" y="340" class="cap" text-anchor="middle">→ the switches are honest</text>
  <rect x="330" y="264" width="270" height="92" rx="8" class="pub"/>
  <text x="465" y="290" class="m" text-anchor="middle">D = C / (g^18 · Π Cᵢ^(2^i))</text>
  <text x="465" y="314" class="t" text-anchor="middle">Schnorr: D is a pure power of h</text>
  <text x="465" y="340" class="cap" text-anchor="middle">→ they add up to age − 18</text>

  <path d="M175,356 L175,378 L320,378 L320,392" class="ar"/>
  <path d="M465,356 L465,378 L320,378" class="ar" style="marker-end:none"/>
  <rect x="80" y="394" width="480" height="44" rx="8" class="pub"/>
  <text x="320" y="421" class="m" text-anchor="middle">c = SHA-256( C, all Cᵢ, all announcements t )</text>
  <text x="306" y="462" class="cap" text-anchor="end">Fiat–Shamir: the question is a hash</text>

  <path d="M320,438 L320,478" class="ar"/>
  <rect x="120" y="480" width="400" height="52" rx="8" class="pub"/>
  <text x="320" y="502" class="m" text-anchor="middle">π = { C, Cᵢ, t, c, s }</text>
  <text x="320" y="522" class="t" text-anchor="middle">→ hand this JSON to the gate</text>
  <rect x="460" y="472" width="58" height="16" rx="8" class="tag"/><text x="489" y="484" class="tagt" text-anchor="middle">PUBLIC</text>
  <text x="320" y="556" class="cap" text-anchor="middle">Nothing manila ever enters π. The gate cannot recover age, r, δ or any bit.</text>
</svg>
<figcaption><b>2 · Building the proof.</b> Read top to bottom. Manila = secret, navy = public.
The clever step is the second row: "I am 18 or over" is the <em>same claim</em> as "my age minus 18 is
a small positive number", and any small positive number can be written as eight on/off switches (bits).
Each switch gets its own little sealed envelope. The proof then shows two things: every switch is really
just on or off (not a 5 hiding in there), and the switches add up to what is in the big envelope minus 18.
If the age were 17, "age minus 18" is negative and has no switch form — the proof simply cannot be built.</figcaption>
</figure>

<figure>
<svg viewBox="0 0 640 330" role="img" aria-label="Three-move Sigma protocol, then Fiat-Shamir">
  <text x="150" y="30" class="h" text-anchor="middle">PROVER</text>
  <text x="490" y="30" class="h" text-anchor="middle">VERIFIER</text>
  <path d="M150,40 L150,240" class="lane"/>
  <path d="M490,40 L490,240" class="lane"/>

  <rect x="40" y="56" width="220" height="40" rx="8" class="sec"/>
  <text x="150" y="81" class="m ink" text-anchor="middle">pick k,  t = h^k</text>
  <path d="M262,76 L478,76" class="ar"/>
  <text x="370" y="70" class="m" text-anchor="middle">t</text>
  <text x="370" y="94" class="cap" text-anchor="middle">announce</text>

  <rect x="380" y="116" width="220" height="40" rx="8" class="pub"/>
  <text x="490" y="141" class="m" text-anchor="middle">pick random c</text>
  <path d="M378,136 L262,136" class="ar"/>
  <text x="320" y="130" class="m" text-anchor="middle">c</text>
  <text x="320" y="154" class="cap" text-anchor="middle">challenge</text>

  <rect x="40" y="176" width="220" height="40" rx="8" class="sec"/>
  <text x="150" y="201" class="m ink" text-anchor="middle">s = k + c·x  (mod q)</text>
  <path d="M262,196 L378,196" class="ar"/>
  <text x="320" y="190" class="m" text-anchor="middle">s</text>
  <text x="320" y="214" class="cap" text-anchor="middle">respond</text>
  <rect x="380" y="176" width="220" height="40" rx="8" class="pub"/>
  <text x="490" y="201" class="m" text-anchor="middle">h^s  ==  t · Y^c ?</text>

  <rect x="40" y="252" width="560" height="62" rx="8" class="pub"/>
  <text x="320" y="277" class="t" text-anchor="middle">Fiat–Shamir: delete the verifier's turn.</text>
  <text x="320" y="300" class="m" text-anchor="middle">c = SHA-256(statement, t)   →   π is now just a file</text>
</svg>
<figcaption><b>3 · The surprise question.</b> This is the pattern inside every check. The prover first
commits to a random scribble (<code>t</code>). Only <em>then</em> does the question (<code>c</code>) arrive, so the
answer (<code>s</code>) could not have been prepared in advance — yet it can be checked by anyone. The secret
is mixed into <code>s</code> so thoroughly with randomness that <code>s</code> alone tells you nothing.
Fiat–Shamir is the last trick: let a hash of the scribble <em>be</em> the question. Now no live verifier is needed
and the proof becomes a file you can paste into the box above.</figcaption>
</figure>

</div>
"""


def lecture_math() -> str:
    t, n, m = ADULT_AGE, N_BITS, MAX_AGE
    return f"""
## What is being proven

The gate sees a Pedersen commitment $C$ and a non-interactive proof $\\pi$.
It must be convinced of this relation — and learn nothing else:

$$
\\mathcal{{R}} = \\Bigl\\{{
  \\bigl(C,\\ (age,\\ r)\\bigr)
  \\;:\\;
  C = g^{{age}}\\, h^{{r}} \\pmod{{p}}
  \\wedge
  age \\in [{t},\\ {m}]
\\Bigr\\}}
$$

### Notation

| symbol | meaning |
| --- | --- |
| $p,\\ q$ | primes, $q \\mid (p-1)$, $\\lvert\\mathbb{{G}}\\rvert = q$ |
| $g,\\ h$ | generators of $\\mathbb{{G}}$; $\\log_g h$ is unknown |
| $T = {t}$ | adult threshold (verifier policy) |
| $n = {n}$ | bit length of $\\delta = age - T$ |
| $r,\\ r_i$ | blinding factors in $\\mathbb{{Z}}_q$ |

### 1. Pedersen commitment (hide the age)

$$
C = g^{{age}}\\, h^{{r}} \\pmod{{p}}
$$

- **Hiding.** For any $age$, uniform $r$ makes $C$ uniform in $\\mathbb{{G}}$. Two ages are indistinguishable.
- **Binding.** A second opening $(age', r')$ for the same $C$ would reveal $\\log_g h = (age-age')(r'-r)^{{-1}}$.

### 2. Range by bits

$$
\\delta = age - T = \\sum_{{i=0}}^{{n-1}} b_i\\, 2^{{i}},
\\qquad b_i \\in \\{{0,1\\}}
$$

so $age \\in [T,\\ T+2^n)$. Each bit is committed on its own:

$$
C_i = g^{{b_i}}\\, h^{{r_i}} \\pmod{{p}}
$$

### 3. Bit is 0 or 1 (Schnorr OR)

$$
C_i = h^{{r_i}}
\\quad\\lor\\quad
C_i \\cdot g^{{-1}} = h^{{r_i}}
$$

The true branch is a real Schnorr; the false branch is simulated by picking $(c', s')$ first and solving for the announcement $t' = h^{{s'}} Y^{{-c'}}$. The verifier only checks that the challenges add up:

$$
c_0 + c_1 \\equiv c \\pmod{{q}}
$$

and cannot tell which branch was real (honest-verifier zero-knowledge).

### 4. Consistency (the bits really sum to $age - T$)

$$
D
= \\frac{{C}}{{g^{{T}} \\displaystyle\\prod_{{i=0}}^{{n-1}} C_i^{{2^{{i}}}}}}
= h^{{\\,r - \\sum_i r_i 2^{{i}}\\,}}
$$

A Schnorr proof of knowledge of $\\log_h D$ shows $D$ is a commitment to $0$, i.e. the bits reconstruct $\\delta$.

### 5. Schnorr check, Fiat–Shamir challenge

PoK $\\{{x : Y = h^x\\}}$:

$$
t = h^{{k}},\\quad
c = H(\\text{{transcript}}),\\quad
s = k + c\\, x \\pmod{{q}}
$$

$$
h^{{s}} \\stackrel{{?}}{{=}} t \\cdot Y^{{c}}
$$

The interactive challenge is replaced by a hash of everything the verifier would have seen:

$$
c = \\mathrm{{SHA256}}\\bigl(p,q,g,h,T,n,C,\\{{C_i\\}}, t,\\ \\{{t_{{0,i}}, t_{{1,i}}\\}}\\bigr) \\bmod q
$$
"""


def lecture_pseudo() -> str:
    t, n = ADULT_AGE, N_BITS
    return f"""
## Algorithms (this repo, no ZKP framework)

All exponentiation is $\\bmod\\ p$; all scalars are $\\bmod\\ q$.
$T = {t}$, $n = {n}$.

### Issue — ID office binds an age

```
ISSUE(age) → credential
    r ← random in Z_q
    C ← g^age · h^r          # Pedersen
    holder keeps  (age, r)
    world  sees   C
```

### Prove — holder writes a proof for the gate

```
PROVE(age, r, C) → π
    assert age ≥ T
    δ ← age − T
    (b_0, …, b_{{n-1}}) ← binary digits of δ

    for i ← 0 .. n-1:
        r_i ← random in Z_q
        C_i ← g^{{b_i}} · h^{{r_i}}
        (t0_i, t1_i) ← OR_ANNOUNCE(C_i, bit=b_i, r_i)
            # true branch:  t = h^k
            # fake branch:  pick (c', s'); t' ← h^{{s'}} / Y^{{c'}}

    r_bits ← Σ_i r_i · 2^i
    D ← C / ( g^T · Π_i C_i^{{2^i}} )     # should equal h^{{r − r_bits}}
    k ← random in Z_q
    t ← h^k                                 # Schnorr announcement for D

    c ← SHA256(params, T, n, C, all C_i, t, all t0_i, t1_i)  mod q

    s ← k + c · (r − r_bits)                # Schnorr response
    for each i:
        split c = c0_i + c1_i
        real branch:  s_real ← k_real + c_real · r_i
        fake branch:  already chosen

    return π = (C, {{C_i}}, {{OR proofs}}, (t, s), T, n)
```

### Verify — gate policy is age ≥ $T$ (not whatever the JSON claims)

```
VERIFY(π, policy_T = {t}) → ADMIT | DENY
    reject if π.T ≠ policy_T or π.n ≠ {n}
    c ← SHA256(same transcript as prover)
    D ← C / ( g^T · Π_i C_i^{{2^i}} )

    # consistency Schnorr
    reject unless  h^s = t · D^c

    # each bit is 0 or 1
    for i ← 0 .. n-1:
        reject unless c0_i + c1_i ≡ c  (mod q)
        reject unless h^{{s0}} = t0 · C_i^{{c0}}
        reject unless h^{{s1}} = t1 · (C_i / g)^{{c1}}

    ADMIT     # committed age ∈ [{t}, {t}+2^{n}-1]
```

### OR_ANNOUNCE / OR_RESPOND (one bit)

```
# To prove C commits to b ∈ {{0,1}}
if b = 0:          # C = h^r, simulate the "bit=1" branch
    c1, s1 ← random
    t1 ← h^{{s1}} / (C/g)^{{c1}}
    k0 ← random;  t0 ← h^{{k0}}
    later: c0 ← c − c1;  s0 ← k0 + c0 · r
if b = 1:          # C = g h^r, simulate the "bit=0" branch
    c0, s0 ← random
    t0 ← h^{{s0}} / C^{{c0}}
    k1 ← random;  t1 ← h^{{k1}}
    later: c1 ← c − c0;  s1 ← k1 + c1 · r
```
"""


def lecture_why() -> str:
    t, n = ADULT_AGE, N_BITS
    return f"""
## Completeness, soundness, zero-knowledge

### Completeness

If $age \\ge {t}$ and the holder knows $(age, r)$ opening $C$, every check in `VERIFY` holds.
$\\delta = age - {t}$ fits in ${n}$ unsigned bits, so the OR proofs have a real witness.

### Soundness (why 17 cannot pass a door of {t})

If $age < T$ then $\\delta < 0$, which is **not** an unsigned ${n}$-bit integer.
To still satisfy

$$
D = C \\big/ \\bigl(g^{{T}} \\prod C_i^{{2^{{i}}}}\\bigr) \\in \\langle h\\rangle
$$

the prover would need either

1. a 0/1 opening of some $C_i$ that is not 0 or 1 — breaks the OR proof, or
2. two Pedersen openings of $C$ — breaks binding ($\\log_g h$).

Also: the verifier's policy $T$ is hashed into $c$. A proof made for $T=16$ is rejected at a door that requires ${t}$.

### Zero-knowledge (why the gate does not learn the age)

- Pedersen is **perfectly hiding**: $C$ is uniform, independent of $age$.
- Each Sigma protocol is **honest-verifier ZK**. Fiat–Shamir makes $c$ a hash of the announcements, so a simulator can still produce a transcript by picking $c$ after programming the hash (in the random-oracle model).
- The OR proof hides *which* branch is real, so the bits $b_i$ (and therefore $\\delta$ and $age$) stay secret.

### What this study desk does *not* prove

Anyone can `ISSUE(99)` to themselves. A real ID system still needs a passport office (or PKI) that binds $C$ to a person. The ZKP only proves a fact about $C$, not about the human at the door.

Cryptographic group: 256-bit prime-order subgroup of $\\mathbb{{Z}}_p^{{*}}$ — Python `pow` and SHA-256 only. No Circom, snarkjs, or arkworks.
"""


def _short(n: int, head: int = 18) -> str:
    h = hex(n)
    if len(h) <= head + 8:
        return h
    return f"{h[:head]}…{h[-6:]}"


def _bits_row(bits: list[int]) -> str:
    cells = "".join(
        f"<span style='display:inline-block;min-width:1.6em;text-align:center;"
        f"border:1px solid #1C2A4A;margin:1px;font-family:IBM Plex Mono,monospace;"
        f"font-size:12px;background:{'#C9A45C' if b else '#F3E6CC'}'>{b}</span>"
        for b in bits
    )
    return (
        f"<div>{cells}</div>"
        "<div style='font-family:IBM Plex Mono,monospace;font-size:11px;margin-top:4px'>b₀ (LSB) → b₇</div>"
    )


def issue(age: float):
    age_i = int(age)
    cred = issue_credential(age_i)
    public = (
        f"C = {_short(cred.C)}\n"
        f"group order q = {_short(PARAMS.q)}\n"
        f"threshold T = {ADULT_AGE}   bits n = {N_BITS}   max age = {MAX_AGE}\n\n"
        "The world may see C. Age and r stay on this page."
    )
    status = f"Credential issued for a private age. Commitment C is {_short(cred.C, 22)}."
    return cred, public, status


def prove(cred: Credential | None, age: float):
    if cred is None:
        raise gr.Error("Issue a credential first — the ID office has to bind the age.")
    age_i = int(age)
    if cred.age != age_i:
        raise gr.Error("Age slider moved after issue. Re-issue the credential for this age.")
    if age_i < ADULT_AGE:
        inspect = inspect_delta_bits(age_i)
        study = (
            f"**Honest prover refuses.** Age ${age_i} < T = {ADULT_AGE}$.\n\n"
            f"$$\\delta = age - T = {age_i} - {ADULT_AGE} < 0$$\n\n"
            f"A negative $\\delta$ is not an unsigned ${N_BITS}$-bit integer "
            f"$\\sum b_i 2^i$ with $b_i \\in \\{{0,1\\}}$. That is the range-proof trapdoor."
        )
        return "", study, inspect.get("reason", "underage")
    proof = prove_adult(cred)
    blob = proof_to_json(proof)
    info = inspect_delta_bits(age_i)
    bits_html = _bits_row(info["bits"])
    study = (
        f"This run (holder only — the JSON below does **not** contain $age$):\n\n"
        f"$$\\delta = {age_i} - {ADULT_AGE} = {info['delta']} "
        f"= \\sum_{{i=0}}^{{{N_BITS - 1}}} b_i\\, 2^{{i}}$$\n\n"
        f"{bits_html}\n\n"
        f"$$C_i = g^{{b_i}} h^{{r_i}},\\qquad "
        f"D = \\frac{{C}}{{g^{{{ADULT_AGE}}} \\prod_i C_i^{{2^{{i}}}}}} = h^{{r - \\sum r_i 2^{{i}}}}$$\n\n"
        f"Eight 0/1 OR proofs + one consistency Schnorr. "
        f"Challenge $c = \\mathrm{{SHA256}}(\\text{{transcript}}) \\bmod q$."
    )
    return blob, study, "Proof written. Hand the JSON to the gate — not the age."


def verify(blob: str):
    if not blob or not str(blob).strip():
        raise gr.Error("No proof at the window.")
    try:
        proof = proof_from_json(str(blob))
    except Exception as exc:
        return STAMP_DENY, f"DENY — could not parse proof ({exc})"
    ok, reason = verify_adult(proof, threshold=ADULT_AGE)
    if ok:
        return STAMP_ADMIT, f"ADMIT — {reason}"
    return STAMP_DENY, f"DENY — {reason}"


def tamper(blob: str) -> str:
    text = str(blob or "")
    if not text.strip():
        raise gr.Error("Generate a proof first, then tamper it.")
    chars = list(text)
    needle = '"C": "0x'
    i = text.find(needle)
    if i < 0:
        raise gr.Error("Could not find C in the JSON.")
    j = i + len(needle)
    chars[j] = "0" if chars[j] != "0" else "1"
    return "".join(chars)


def build() -> gr.Blocks:
    ip = lan_ip()
    phone_url = f"http://{ip}:{PORT}"

    with gr.Blocks(title="GATE 18 · Age ZKP", fill_width=True) as demo:
        gr.HTML(
            f'<div id="phone-bar">iPhone (same Wi-Fi) → {phone_url}'
            f" &nbsp;·&nbsp; this machine → http://127.0.0.1:{PORT}</div>"
        )
        gr.HTML(
            f"""
            <div class="hero">
              <img src="{HERO}" alt="Midnight immigration desk">
              <div class="hero-veil"></div>
              <div class="hero-copy">
                <p class="eyebrow">Causeway Bay · from-scratch Sigma protocol</p>
                <h1>The door doesn't need your birthday.</h1>
                <p class="lede">Commit an age. Prove it is at least 18. The gate learns the inequality — never the number.</p>
              </div>
            </div>
            """
        )

        cred_state = gr.State(None)

        with gr.Row():
            with gr.Column(elem_classes=["page"]):
                gr.HTML(
                    '<p class="kicker">Left page · holder</p>'
                    '<h2 class="page-title">Issue &amp; prove</h2>'
                    '<p class="page-note">You still type an age here because this is a study desk. '
                    "The JSON you hand to the gate does not contain it.</p>"
                )
                age = gr.Slider(
                    minimum=1,
                    maximum=99,
                    value=25,
                    step=1,
                    label="Private age (holder only)",
                )
                with gr.Row():
                    issue_btn = gr.Button("Issue credential", elem_id="issue-btn")
                    prove_btn = gr.Button("Write the proof", elem_id="prove-btn")
                public_view = gr.Textbox(
                    label="Public commitment C",
                    lines=5,
                )
                study = gr.Markdown(
                    "Issue a credential, then write a proof. Bit decomposition of $\\delta$ appears here.",
                    latex_delimiters=LATEX,
                )

            with gr.Column(elem_classes=["page"]):
                gr.HTML(
                    '<p class="kicker">Right page · gate</p>'
                    '<h2 class="page-title">Verify</h2>'
                    f'<p class="page-note">Policy is fixed: age ≥ {ADULT_AGE}. '
                    "The officer never receives the age field — only the proof.</p>"
                )
                gr.HTML(f'<div id="id-preview"><img src="{ID_CARD}" alt="Redacted identity card"></div>')
                stamp = gr.Image(
                    value=STAMP_IDLE,
                    label="Visa stamp",
                    show_label=False,
                    elem_id="stamp-frame",
                    height=220,
                )
                verdict = gr.Markdown("*Awaiting a proof at the window.*")
                verify_btn = gr.Button("Check at the gate", elem_id="verify-btn")
                tamper_btn = gr.Button("Tamper one hex digit", elem_id="tamper-btn")

        proof_box = gr.Code(label="Proof handed to the gate (JSON)", language="json", lines=14)
        status = gr.Markdown("")

        with gr.Tabs(elem_id="lab-notes"):
            with gr.Tab("Flow"):
                gr.HTML(lecture_flow())
            with gr.Tab("Mathematics"):
                gr.Markdown(lecture_math(), latex_delimiters=LATEX)
            with gr.Tab("Pseudocode"):
                gr.Markdown(lecture_pseudo(), latex_delimiters=LATEX)
            with gr.Tab("Why it works"):
                gr.Markdown(lecture_why(), latex_delimiters=LATEX)

        issue_btn.click(issue, inputs=[age], outputs=[cred_state, public_view, status])
        prove_btn.click(prove, inputs=[cred_state, age], outputs=[proof_box, study, status])
        verify_btn.click(verify, inputs=[proof_box], outputs=[stamp, verdict])
        tamper_btn.click(tamper, inputs=[proof_box], outputs=[proof_box])

    return demo


if __name__ == "__main__":
    ip = lan_ip()
    print(f"GATE 18  local  http://127.0.0.1:{PORT}", flush=True)
    print(f"GATE 18  phone  http://{ip}:{PORT}", flush=True)
    print("Same Wi-Fi. If the phone cannot connect, allow Python in macOS Firewall.", flush=True)
    demo = build()
    demo.launch(
        server_name=HOST,
        server_port=PORT,
        share=False,
        inbrowser=False,
        allowed_paths=[str(ASSETS)],
        favicon_path=str(ASSETS / "plaque-gate18.jpg"),
        theme=gr.themes.Base(
            font=[gr.themes.GoogleFont("Figtree"), "sans-serif"],
            font_mono=[gr.themes.GoogleFont("IBM Plex Mono"), "monospace"],
            primary_hue="stone",
            secondary_hue="stone",
            neutral_hue="stone",
        ),
        css=CSS,
        head=HEAD,
        pwa=True,
        show_error=True,
    )
