#!/usr/bin/env python3
"""Subset Noto Sans CJK KR for the game's fallback font.

The full font is 16 MB. The game only needs enough to render every language
it ships and anything a player might type as an answer:

  * every Hangul syllable and jamo                      (Korean)
  * hiragana, katakana and the JIS X 0208 kanji         (Japanese)
  * the GB 2312 hanzi                                   (Simplified Chinese)
  * Big5 level 1 plus its HKSCS characters              (Cantonese)
  * CJK punctuation, fullwidth forms, general punctuation
  * every CJK character that appears in the Lua sources

Czech and Spanish need no fallback: Press Start 2P and VT323 both carry the
accented Latin themselves.

Run this again whenever new CJK text lands in src/, so a character used in a
story line cannot go missing.

    pip install fonttools
    python3 tools/subset_cjk.py path/to/NotoSansCJKkr-Regular.otf

Writes assets/fonts/NotoSansCJKkr-Regular.otf. Run from love2d/.
"""

import glob
import subprocess
import sys
import tempfile

OUT = "assets/fonts/NotoSansCJKkr-Regular.otf"


def used_in_sources():
    chars = set()
    for path in glob.glob("src/*.lua") + ["main.lua"]:
        with open(path, encoding="utf8") as f:
            chars.update(ch for ch in f.read() if ord(ch) > 0x2E7F)
    return {ord(c) for c in chars}


def big5_level1_hkscs():
    cps = set()
    for cp in range(0x3400, 0x30000):
        try:
            lead = chr(cp).encode("big5hkscs")[0]
        except UnicodeEncodeError:
            continue
        if 0xA4 <= lead <= 0xC6:
            cps.add(cp)
    return cps


def encodable(codec):
    """Every CJK code point the legacy codec can represent.

    gb2312 gives the 6763 Simplified hanzi of the mainland standard;
    shift_jis gives the JIS X 0208 kanji, kana and all.
    """
    cps = set()
    for cp in range(0x3000, 0x30000):
        try:
            chr(cp).encode(codec)
        except UnicodeEncodeError:
            continue
        cps.add(cp)
    return cps


def main():
    if len(sys.argv) != 2:
        sys.exit(__doc__)
    cps = used_in_sources() | big5_level1_hkscs()
    cps |= encodable("gb2312")  # Simplified Chinese
    cps |= encodable("shift_jis")  # Japanese kanji and kana
    cps |= set(range(0xAC00, 0xD7A4))  # Hangul syllables
    cps |= set(range(0x1100, 0x1200))  # Hangul Jamo
    cps |= set(range(0x3130, 0x3190))  # Hangul compatibility Jamo
    cps |= set(range(0x3000, 0x3040))  # CJK punctuation
    cps |= set(range(0x3040, 0x3100))  # hiragana and katakana
    cps |= set(range(0x31F0, 0x3200))  # katakana phonetic extensions
    cps |= set(range(0xFF00, 0xFFF0))  # fullwidth and halfwidth forms
    cps |= set(range(0x2000, 0x2070))  # general punctuation
    with tempfile.NamedTemporaryFile("w", suffix=".txt", delete=False) as f:
        f.write("\n".join("U+%04X" % c for c in sorted(cps)))
        unicodes = f.name
    subprocess.check_call(
        [
            sys.executable, "-m", "fontTools.subset", sys.argv[1],
            f"--unicodes-file={unicodes}",
            f"--output-file={OUT}",
            "--layout-features=*",
            "--no-hinting",
        ]
    )
    print(f"{len(cps)} code points -> {OUT}")


if __name__ == "__main__":
    main()
