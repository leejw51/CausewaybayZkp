# GATE 18 — Causeway Bay (Love2D)

English · 한국어 · 粵語 (F3 or the top-right button; remembered between runs).

A Wonder Boy-style 16-bit beer run. Same ZKP as `python/zkp`,
played as a quiz: seven streets, 24 blanks, type the answer. Some blanks are
words, some are sums in a toy group small enough to do by hand
(p = 23, g = 2, h = 3 for Pedersen; p = 23, h = 2, q = 11 for Schnorr), and
three of them are DENY: a cheater's guess, a replayed proof, a tampered C.

```bash
cd love2d
make help
make start    # run in the background
make stop
make test     # unit tests + the title -> map -> play -> win state machine
make drive SCRIPT=tests/drive/all.lua    # replay every street with screenshots
make format   # stylua
```

## Flow

```
title  --ENTER-->  map  --ENTER / click / 1-7-->  play  --CLEAR, ENTER-->  next street ... --> win
  ^                 ^                              |
  |                 +---- ESC / F2 / MAP ----------+   (ESC on the map goes back to the street)
  +---- ESC on the map
```

- **Quests**: two of them, two kinds of ZKP. **Q1 GATE 18** is the hand-made Sigma protocol (`src/data.lua`); **Q2 PUZZLE** is a real Groth16 zk-SNARK for a 4×4 sudoku (`src/data_snark.lua`, backed by `../rust` over `ffi`, see `src/snark.lua`). **Q** on the title or the map switches; the map also has Q1 / Q2 tabs. Each quest keeps its own seven streets, its own map cursor and its own stamp screen (ADMIT / SOLVED); CLEAR streets of both are kept in `progress.jsonl`. Q2's PROOF street proves and verifies for real when `cd ../rust && cargo build --release` has been run, and says so when it has not.
- **Title**: ENTER or click opens the street map. **C** continues from `progress.jsonl`. 1–7 jump straight in. ESC quits.
- **Map**: a 16-bit overworld of Causeway Bay. Seven level dots on a dotted path; Alex walks the path with the ARROW keys (one dot per press), ENTER or a click on a dot starts that street, 1–7 jump. Cleared dots turn green with a star, the street you left shows **HERE**, and the box at the bottom names the street under Alex. ESC goes back. The scene backdrops (`assets/bg_*.png`, `title_bg.png`) were generated with Grok (xAI `grok-imagine-image-quality`), the overworld backdrops `map_bg*.png` with Higgsfield's auto model; without them the map draws its own hills. No third-party game characters appear in any asset.
- **Play**: read the story and the question, type the answer, ENTER or **OK**. Wrong answers shake and open the hint. **HINT** (TAB or the button) is two-tier: first a nudge, second the answer, third hides it. 30 s idle opens the nudge once. After the last blank the street is **CLEAR**: ENTER / SPACE / N / **NEXT** / walking off the right edge moves on. ESC, F2 or **MAP** open the map without losing the street. **AUTO** (F5) plays the street for you - reads, opens the nudge, types the answer key by key, submits, sits on the explanation, and after CLEAR walks on to the next open street until the stamp - so a reader can watch the whole flow; any key or click of your own stops it. **< PREV** / **NEXT >** (PGUP / PGDN) page through the blanks of the current street, answered or not, to re-read a line or peek ahead; they stop at the street's first and last blank. Browsing answers nothing: a blank skipped with NEXT is asked again before the street is CLEAR, and `progress.jsonl` records the first open blank, not the one on screen.
- **Win**: only when all seven streets are CLEAR, whichever order. Shows the ADMIT stamp and one lesson per street. ENTER returns to the map, ESC to the title.

Every variable in a code block carries a trailing `#` comment saying what it means (p, g, h, r, C, T, delta, b_i, x, k, t, c, s, sk, pk, D ...), in the current language; the python itself is the same in every language. The answer is never printed in the code panel. Answers are matched loosely (case, spaces, quotes, `_`, `-`, `.` ignored), so `SHA-256` and `sha256` both pass.

| Map | Blanks (in order) |
| --- | --- |
| Street | `>=` |
| Mart | `25`, `soundness`, `completeness` |
| Office | `r`, `16` (C = 9·12 mod 23), `hiding`, `binding` |
| Bits | `7`, `111`, `-1`, `273` |
| Sigma | `s`, `2` (s = 3+2·5 mod 11), `4` (8·81 mod 23), `9` (a cheater's 2^5 mod 23), `sha256` |
| Nonce | `sk`, `pk`, `nonce`, `DENY` (replay) |
| Fridge | `threshold`, `DENY` (tampered C), `ADMIT` |

## Keys

- **F3** / the language button — English → 한국어 → 粵語. Localized answers count too (건전성, 可靠性, 은닉, 隱藏 ...). CJK text uses Noto Sans CJK (`assets/fonts`, OFL) as a glyph fallback behind the pixel fonts. The shipped file is a 4 MB subset (all Hangul, common Traditional Chinese incl. HKSCS Cantonese, CJK punctuation); `tools/subset_cjk.py` regenerates it from the full font.
- **F4** — sound on/off (remembered). Every effect is synthesized at load from square, triangle, saw and noise waves at 8-bit depth: key blips, map steps, a rising arpeggio for a right answer, a falling buzz for a wrong one, a DENY thud, a street-clear fanfare and a win jingle. No audio files.
- **F2** / **MAP** — street map · **F11** / **WIND/FULL** — window / fullscreen · **F1** / **LAND/PORT** — landscape 1280×720 / portrait 720×1280. A portrait display starts in portrait; the choice is remembered.

## Persist (`~/.causewaybayzkp`)

JSONL, one object per line:

| file | what |
| --- | --- |
| `setup.jsonl` | first-run `event=setup`, then `event=display` / `event=boot` |
| `progress.jsonl` | `event=progress` after every solved blank and street change. `cleared` lists the map ids marked **CLEAR**. |

Override the folder with `GATE18_HOME`. Last readable line of each kind wins on launch.

## Scripted sessions

`GATE18_DRIVE=script.lua love .` replays keys, text, clicks and window resizes on
a timeline and saves screenshots to the LOVE save directory. `tests/drive/all.lua`
plays every street; `tests/drive/map.lua` walks the overworld; `tests/drive/layout.lua` checks the minimum window, a large
window, and fullscreen in both orientations.
