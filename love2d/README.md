# GATE 18 — Causeway Bay (Love2D)

English · 한국어 · 粵語 (F3 or the top-right button; remembered between runs).

Wonder Boy + Super Mario World 16-bit beer run. Same ZKP as `python/zkp`,
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

- **Title**: ENTER or click opens the street map. **C** continues from `progress.jsonl`. 1–7 jump straight in. ESC quits.
- **Map**: a Super Mario World overworld of Causeway Bay. Seven level dots on a dotted path; Alex walks the path with the ARROW keys (one dot per press), ENTER or a click on a dot starts that street, 1–7 jump. Cleared dots turn green with a star, the street you left shows **HERE**, and the box at the bottom names the street under Alex. ESC goes back. The backdrops `assets/map_bg.png` / `map_bg_p.png` were generated with Higgsfield's auto image model (Grok's image model is not in that catalog); without them the map draws its own hills.
- **Play**: read the story and the question, type the answer, ENTER or **OK**. Wrong answers shake and open the hint. **HINT** (TAB or the button) is two-tier: first a nudge, second the answer, third hides it. 30 s idle opens the nudge once. After the last blank the street is **CLEAR**: ENTER / SPACE / N / **NEXT** / walking off the right edge moves on. ESC, F2 or **MAP** open the map without losing the street.
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

- **F3** / the language button — English → 한국어 → 粵語. Localized answers count too (건전성, 可靠性, 은닉, 隱藏 ...). CJK text uses Noto Sans CJK (`assets/fonts`, OFL) as a glyph fallback behind the pixel fonts.
- **F2** / **MAP** — street map · **F11** / **WIND/FULL** — window / fullscreen · **F1** / **LAND/PORT** — landscape 1280×720 / portrait 720×1280. A portrait display starts in portrait; the choice is remembered.

## Persist (`~/.causewaybayzkp`)

JSONL, one object per line (same idea as Jarvis2):

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
