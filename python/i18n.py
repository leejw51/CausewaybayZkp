"""English / Korean strings for the GATE 18 desk.

Every user-facing string lives here, keyed by language. `t(lang, key)` looks
one up; missing Korean falls back to English so a half-finished translation
never blanks the page.

Maths is language-neutral, so the lecture bodies keep their LaTeX and only
the prose around it is translated. Those bodies use `__T__`, `__N__`,
`__MAX__`, `__NB__` placeholders rather than f-string `{{ }}` doubling —
LaTeX is full of braces and the escaping made the source unreadable.
"""

from __future__ import annotations

LANGS = {"en": "English", "ko": "한국어"}
DEFAULT_LANG = "en"

UI: dict[str, dict[str, str]] = {
    "en": {
        "lang_label": "Language",
        "phone_bar_phone": "iPhone (same Wi-Fi)",
        "phone_bar_here": "this machine",
        "hero_eyebrow": "Causeway Bay · from-scratch Sigma protocol",
        "hero_title": "The door doesn't need your birthday.",
        "hero_lede": "Commit an age. Prove it is at least 18. The gate learns the inequality — never the number.",
        "left_kicker": "Left page · holder",
        "left_title": "Issue &amp; prove",
        "left_note": (
            "You still type an age here because this is a study desk. "
            "The JSON you hand to the gate does not contain it."
        ),
        "age_label": "Private age (holder only)",
        "issue_btn": "Issue credential",
        "prove_btn": "Write the proof",
        "public_label": "Public commitment C",
        "study_idle": "Issue a credential, then write a proof. Bit decomposition of $\\delta$ appears here.",
        "right_kicker": "Right page · gate",
        "right_title": "Verify",
        "right_note": (
            "Policy is fixed: age ≥ {threshold}. The officer hands out a fresh challenge, "
            "then receives only the proof — never the age, never the private key."
        ),
        "nonce_label": "Gate's challenge — a fresh nonce; the proof must answer this one",
        "stamp_label": "Visa stamp",
        "verdict_idle": "*Awaiting a proof at the window.*",
        "verify_btn": "Check at the gate",
        "tamper_btn": "Tamper one hex digit",
        "nonce_btn": "New challenge — old proofs stop working",
        "proof_label": "Proof handed to the gate (JSON)",
        "tab_flow": "Flow",
        "tab_math": "Mathematics",
        "tab_pseudo": "Pseudocode",
        "tab_why": "Why it works",
        # runtime messages
        "err_issue_first": "Issue a credential first — the ID office has to bind the age.",
        "err_slider_moved": "Age slider moved after issue. Re-issue the credential for this age.",
        "err_no_proof": "No proof at the window.",
        "err_prove_first": "Generate a proof first, then tamper it.",
        "err_no_c": "Could not find C in the JSON.",
        "issued_status": "Credential issued and signed by the ID office for pk. Envelope C is {c}.",
        "public_body": (
            "C  = {c}\n"
            "pk = {pk}   holder's public key (sk stays here)\n"
            "ID office signature on (C, pk):  R = {sig}\n"
            "group order q = {q}\n"
            "threshold T = {threshold}   bits n = {nbits}   max age = {maxage}\n\n"
            "The world may see C, pk and the signature. Age, r and sk stay on this page."
        ),
        "proved_status": "Proof written for challenge {nonce}. Hand the JSON to the gate — not the age, not sk.",
        "deny_parse": "DENY — could not parse proof ({err})",
        "admit": "ADMIT — {reason}",
        "deny": "DENY — {reason}",
        "refuse_title": "**Honest prover refuses.**",
        "refuse_body": (
            "A negative $\\delta$ is not an unsigned ${nbits}$-bit integer "
            "$\\sum b_i 2^i$ with $b_i \\in \\{{0,1\\}}$. That is the range-proof trapdoor."
        ),
        "study_run": "This run (holder only — the JSON below does **not** contain $\\mathrm{age}$):",
        "study_tail": (
            "Eight 0/1 OR proofs + one consistency Schnorr. "
            "Challenge $c = \\mathrm{{SHA256}}(\\text{{nonce}}, C, \\mathrm{{pk}}, \\ldots) \\bmod q$ "
            "with the gate's nonce `{nonce}` inside, plus an owner proof "
            "$s_{{\\mathrm{{own}}}} = k + c\\,\\mathrm{{sk}}$ that only the holder of "
            "$\\mathrm{{sk}}$ can write."
        ),
        "bits_caption": "b₀ (LSB) → b₇",
    },
    "ko": {
        "lang_label": "언어",
        "phone_bar_phone": "아이폰 (같은 Wi-Fi)",
        "phone_bar_here": "이 컴퓨터",
        "hero_eyebrow": "코즈웨이베이 · 처음부터 만든 시그마 프로토콜",
        "hero_title": "문지기는 생년월일을 알 필요가 없습니다.",
        "hero_lede": "나이를 봉인하고, 18세 이상임만 증명합니다. 문지기는 부등식만 알 뿐, 숫자는 결코 알지 못합니다.",
        "left_kicker": "왼쪽 페이지 · 소지자",
        "left_title": "발급 &amp; 증명",
        "left_note": (
            "여기서 나이를 직접 입력하는 것은 이것이 학습용 데스크이기 때문입니다. "
            "문지기에게 건네는 JSON에는 나이가 들어 있지 않습니다."
        ),
        "age_label": "비공개 나이 (소지자만 봄)",
        "issue_btn": "자격증명 발급",
        "prove_btn": "증명 작성",
        "public_label": "공개 커밋먼트 C",
        "study_idle": "자격증명을 발급한 뒤 증명을 작성하세요. $\\delta$ 의 비트 분해가 여기에 나타납니다.",
        "right_kicker": "오른쪽 페이지 · 게이트",
        "right_title": "검증",
        "right_note": (
            "정책은 고정입니다: 나이 ≥ {threshold}. 심사관은 새 챌린지를 건네주고 "
            "증명만 받습니다 — 나이도, 개인키도 받지 않습니다."
        ),
        "nonce_label": "게이트의 챌린지 — 새로 만든 논스입니다. 증명은 바로 이 값에 답해야 합니다",
        "stamp_label": "비자 도장",
        "verdict_idle": "*창구에서 증명을 기다리는 중입니다.*",
        "verify_btn": "게이트에서 확인",
        "tamper_btn": "16진수 한 자리 조작",
        "nonce_btn": "새 챌린지 — 이전 증명은 무효가 됩니다",
        "proof_label": "게이트에 건네는 증명 (JSON)",
        "tab_flow": "흐름",
        "tab_math": "수학",
        "tab_pseudo": "의사코드",
        "tab_why": "왜 성립하는가",
        "err_issue_first": "먼저 자격증명을 발급하세요 — 신분증 발급소가 나이를 봉인해야 합니다.",
        "err_slider_moved": "발급 후 나이 슬라이더가 움직였습니다. 이 나이로 자격증명을 다시 발급하세요.",
        "err_no_proof": "창구에 제출된 증명이 없습니다.",
        "err_prove_first": "먼저 증명을 생성한 뒤 조작하세요.",
        "err_no_c": "JSON에서 C를 찾을 수 없습니다.",
        "issued_status": "신분증 발급소가 pk 앞으로 자격증명을 발급하고 서명했습니다. 봉투 C는 {c} 입니다.",
        "public_body": (
            "C  = {c}\n"
            "pk = {pk}   소지자의 공개키 (sk는 이 페이지에 남습니다)\n"
            "(C, pk)에 대한 발급소 서명:  R = {sig}\n"
            "군의 위수 q = {q}\n"
            "기준 T = {threshold}   비트 수 n = {nbits}   최대 나이 = {maxage}\n\n"
            "세상은 C, pk, 서명을 볼 수 있습니다. 나이와 r, sk는 이 페이지에 남습니다."
        ),
        "proved_status": "챌린지 {nonce} 에 대한 증명을 작성했습니다. 게이트에는 JSON만 건네세요 — 나이도, sk도 아닙니다.",
        "deny_parse": "거부 — 증명을 해석할 수 없습니다 ({err})",
        "admit": "통과 — {reason}",
        "deny": "거부 — {reason}",
        "refuse_title": "**정직한 증명자는 거부합니다.**",
        "refuse_body": (
            "음수인 $\\delta$ 는 $b_i \\in \\{{0,1\\}}$ 인 $\\sum b_i 2^i$ 형태의 "
            "부호 없는 ${nbits}$비트 정수가 될 수 없습니다. 이것이 범위 증명의 핵심입니다."
        ),
        "study_run": "이번 실행 (소지자 전용 — 아래 JSON에는 $\\mathrm{age}$ 가 **들어 있지 않습니다**):",
        "study_tail": (
            "0/1 OR 증명 8개 + 일관성 슈노어 증명 1개. "
            "챌린지 $c = \\mathrm{{SHA256}}(\\text{{nonce}}, C, \\mathrm{{pk}}, \\ldots) \\bmod q$ 안에 "
            "게이트의 논스 `{nonce}` 가 들어가며, 여기에 더해 "
            "$\\mathrm{{sk}}$ 를 가진 사람만 쓸 수 있는 소유 증명 "
            "$s_{{\\mathrm{{own}}}} = k + c\\,\\mathrm{{sk}}$ 가 붙습니다."
        ),
        "bits_caption": "b₀ (최하위) → b₇",
    },
}

# Words drawn inside the SVG diagrams, kept short so the boxes still fit.
SVG: dict[str, dict[str, str]] = {
    "en": {
        "legend_secret": "secret — stays with the holder",
        "legend_public": "public — the gate sees this",
        "d1_office": "ID OFFICE", "d1_holder": "HOLDER", "d1_gate": "GATE",
        "d1_o1": "sees the real age", "d1_o2": "seals it in envelope C",
        "d1_o3": "signs (C, pk)", "d1_o4": "trusted, once",
        "d1_h1": "keeps age, r and sk", "d1_h2": "publishes C and pk",
        "d1_h3": "answers with proof π", "d1_h4": "nothing here leaves",
        "d1_g1": "hands out a challenge", "d1_g2": "checks signature, key, π",
        "d1_g3": "learns: age ≥ 18", "d1_g4": "and nothing else",
        "d1_arr1": "(age, r, sig)", "d1_arr2": "← challenge", "d1_arr3": "π (JSON) →",
        "d1_foot": "The secret lives in the middle box. No arrow out of it carries age, r or sk.",
        "d2_delta": "δ = age − 18", "d2_bits": "bits b7 … b1 b0",
        "d2_note": "must be 0…255 to have an 8-bit form",
        "d2_or": "8 × OR-proof", "d2_or2": "each Cᵢ hides 0 or 1",
        "d2_or3": "→ the switches are honest",
        "d2_d2": "Schnorr: D is a pure power of h", "d2_d3": "→ they add up to age − 18",
        "d2_fs": "the gate's nonce is in the hash",
        "d2_hand": "→ hand this JSON to the gate",
        "d2_foot": "Nothing manila ever enters π. The gate cannot recover age, r, sk, δ or any bit.",
        "d3_prover": "PROVER", "d3_verifier": "VERIFIER",
        "d3_t": "pick k,  t = h^k", "d3_announce": "announce",
        "d3_c": "pick random c", "d3_challenge": "challenge",
        "d3_s": "s = k + c·x  (mod q)", "d3_respond": "respond",
        "d3_check": "h^s  ==  t · Y^c ?",
        "d3_fs1": "Fiat–Shamir: delete the verifier's turn.",
        "d3_fs2": "c = SHA-256(statement, t)   →   π is now just a file",
        "swipe": "swipe sideways to see the whole picture  →",
    },
    "ko": {
        "legend_secret": "비밀 — 소지자에게만 남습니다",
        "legend_public": "공개 — 게이트가 봅니다",
        "d1_office": "발급소", "d1_holder": "소지자", "d1_gate": "게이트",
        "d1_o1": "실제 나이를 봅니다", "d1_o2": "봉투 C에 봉인합니다",
        "d1_o3": "(C, pk)에 서명합니다", "d1_o4": "단 한 번만 신뢰",
        "d1_h1": "나이, r, sk를 보관", "d1_h2": "C와 pk를 공개",
        "d1_h3": "증명 π로 답합니다", "d1_h4": "여기서 나가는 비밀 없음",
        "d1_g1": "챌린지를 건넵니다", "d1_g2": "서명·키·π를 확인",
        "d1_g3": "알게 됨: 나이 ≥ 18", "d1_g4": "그 외에는 아무것도",
        "d1_arr1": "(나이, r, 서명)", "d1_arr2": "← 챌린지", "d1_arr3": "π (JSON) →",
        "d1_foot": "비밀은 가운데 상자에 있습니다. 거기서 나가는 화살표는 나이·r·sk를 나르지 않습니다.",
        "d2_delta": "δ = 나이 − 18", "d2_bits": "비트 b7 … b1 b0",
        "d2_note": "8비트로 쓰려면 0…255 이어야 합니다",
        "d2_or": "OR 증명 8개", "d2_or2": "각 Cᵢ는 0 또는 1을 숨김",
        "d2_or3": "→ 스위치가 정직함",
        "d2_d2": "슈노어: D는 h의 거듭제곱", "d2_d3": "→ 합이 나이 − 18",
        "d2_fs": "게이트의 논스가 해시에 들어갑니다",
        "d2_hand": "→ 이 JSON을 게이트에 제출",
        "d2_foot": "π에는 비밀이 들어가지 않습니다. 게이트는 나이·r·sk·δ·비트를 복원할 수 없습니다.",
        "d3_prover": "증명자", "d3_verifier": "검증자",
        "d3_t": "k 선택,  t = h^k", "d3_announce": "선언",
        "d3_c": "무작위 c 선택", "d3_challenge": "챌린지",
        "d3_s": "s = k + c·x  (mod q)", "d3_respond": "응답",
        "d3_check": "h^s  ==  t · Y^c ?",
        "d3_fs1": "피아트–샤미르: 검증자의 차례를 없앱니다.",
        "d3_fs2": "c = SHA-256(문장, t)   →   π는 이제 하나의 파일",
        "swipe": "옆으로 밀어 그림 전체를 보세요  →",
    },
}


def t(lang: str, key: str) -> str:
    """UI string, falling back to English when a Korean key is missing."""
    return UI.get(lang, UI["en"]).get(key) or UI["en"][key]


def sv(lang: str, key: str) -> str:
    """Diagram string, same fallback."""
    return SVG.get(lang, SVG["en"]).get(key) or SVG["en"][key]


# --- Flow tab prose. __T__/__N__/__MAX__ are filled in by app.py. -----------

FLOW_INTRO = {
    "en": """
  <p class="eyebrow">Start here · no maths</p>
  <h3>The bouncer problem</h3>
  <p>To get into a club you show your ID. The bouncer needs <em>one</em> fact — are you 18 or over? —
  but your card hands over your name, your exact birthday, your address, your photo.
  A <b>zero-knowledge proof</b> is a way to convince the bouncer of that one fact while they learn
  <em>nothing else</em>. Not your birthday. Not even whether you are 19 or 45.</p>

  <h3>Four ideas, in plain words</h3>
  <ol>
    <li><b>The sealed envelope.</b> Your age goes into an envelope and it is sealed. Everyone can see
      the envelope — call it <code>C</code> — but not what is inside. Crucially, you cannot quietly swap
      the contents later. (Maths name: <em>commitment</em>.)</li>
    <li><b>The check.</b> The proof is a bundle of arithmetic that anyone can run against the envelope.
      The arithmetic only works out if the number inside is 18 or more. If it were 17, no bundle exists
      that passes. (Maths name: <em>range proof</em>.)</li>
    <li><b>The surprise question.</b> Why can't you fake the bundle? Because half-way through, a
      random question is thrown at you that you could not have prepared for. Here the gate hands
      you a fresh random number and the rest of the question is a hash of it, so the answer
      is good for this one conversation only. (Maths name: <em>challenge</em>, <em>nonce</em>,
      <em>Fiat–Shamir</em>.)</li>
    <li><b>The name tag.</b> How does the bouncer know the envelope is <em>yours</em>? The ID office
      writes your public key on it and signs both. At the gate you also prove you hold the matching
      private key. A stolen envelope, or a copied proof, is useless to anyone else.
      (Maths name: <em>issuer signature</em>, <em>proof of knowledge of sk</em>.)</li>
  </ol>
  <p>That is the whole idea. Everything below is those four sentences, drawn.</p>
""",
    "ko": """
  <p class="eyebrow">여기서 시작 · 수식 없음</p>
  <h3>문지기 문제</h3>
  <p>클럽에 들어가려면 신분증을 보여줍니다. 문지기에게 필요한 사실은 <em>단 하나</em> — 18세 이상인가? — 뿐인데,
  신분증은 이름과 정확한 생년월일, 주소, 사진까지 전부 넘겨줍니다.
  <b>영지식 증명</b>은 그 하나의 사실만 문지기에게 확신시키면서 <em>그 외에는 아무것도</em> 알려주지 않는 방법입니다.
  생년월일도, 심지어 19세인지 45세인지도 알려주지 않습니다.</p>

  <h3>네 가지 아이디어, 쉬운 말로</h3>
  <ol>
    <li><b>봉인된 봉투.</b> 나이를 봉투에 넣고 봉인합니다. 봉투 자체는 누구나 볼 수 있지만
      — 이것을 <code>C</code> 라고 부릅니다 — 안에 든 것은 볼 수 없습니다. 그리고 결정적으로,
      나중에 몰래 내용물을 바꿔치기할 수 없습니다. (수학 용어: <em>커밋먼트</em>.)</li>
    <li><b>검산.</b> 증명은 누구나 그 봉투에 대해 돌려볼 수 있는 계산 묶음입니다.
      안에 든 수가 18 이상일 때만 계산이 맞아떨어집니다. 만약 17이었다면, 통과하는 묶음은
      아예 존재하지 않습니다. (수학 용어: <em>범위 증명</em>.)</li>
    <li><b>기습 질문.</b> 왜 그 묶음을 위조할 수 없을까요? 도중에 미리 준비할 수 없었던
      무작위 질문이 던져지기 때문입니다. 여기서는 게이트가 새로 만든 무작위 수를 건네주고
      질문의 나머지는 그 수의 해시입니다. 그래서 답은 이번 한 번의 대화에만 유효합니다.
      (수학 용어: <em>챌린지</em>, <em>논스</em>, <em>피아트–샤미르</em>.)</li>
    <li><b>이름표.</b> 문지기는 그 봉투가 <em>당신 것</em>인지 어떻게 알까요? 발급소가 봉투에
      당신의 공개키를 적고 둘 다에 서명합니다. 게이트에서는 그에 대응하는 개인키를 가지고 있다는 것도
      증명합니다. 훔친 봉투나 복사한 증명은 다른 사람에게는 쓸모가 없습니다.
      (수학 용어: <em>발급자 서명</em>, <em>sk 지식 증명</em>.)</li>
  </ol>
  <p>이것이 전부입니다. 아래는 이 네 문장을 그림으로 옮긴 것입니다.</p>
""",
}

FLOW_CAPS = {
    "en": {
        "c1": """<b>1 · Who sees what.</b> The ID office is the one party you trust to look at your real
age — once. It seals that age into the envelope <code>C</code>, writes your public key <code>pk</code>
on it and signs both; you keep the opening (<code>r</code>) and your private key (<code>sk</code>).
At the gate you are handed a fresh challenge and answer it with a proof only <code>sk</code> can write.
The bouncer checks the office's signature, your key, and the proof — and holds nothing else.""",
        "c2": """<b>2 · Building the proof.</b> Read top to bottom. Manila = secret, navy = public.
The clever step is the second row: "I am 18 or over" is the <em>same claim</em> as "my age minus 18 is
a small positive number", and any small positive number can be written as eight on/off switches (bits).
Each switch gets its own little sealed envelope. The proof then shows two things: every switch is really
just on or off (not a 5 hiding in there), and the switches add up to what is in the big envelope minus 18.
If the age were 17, "age minus 18" is negative and has no switch form — the proof simply cannot be built.""",
        "c3": """<b>3 · The surprise question.</b> This is the pattern inside every check. The prover first
commits to a random scribble (<code>t</code>). Only <em>then</em> does the question (<code>c</code>) arrive, so the
answer (<code>s</code>) could not have been prepared in advance — yet it can be checked by anyone. The secret
is mixed into <code>s</code> so thoroughly with randomness that <code>s</code> alone tells you nothing.
Fiat–Shamir is the last trick: let a hash of the scribble <em>be</em> the question. In this desk the gate still
contributes: its random nonce is hashed in too, so the answer is fresh for each check and cannot be copied from an
earlier one. The proof becomes a file you can paste into the box above — for this challenge only.""",
    },
    "ko": {
        "c1": """<b>1 · 누가 무엇을 보는가.</b> 발급소는 당신의 실제 나이를 보는 — 단 한 번만 — 신뢰 대상입니다.
발급소는 그 나이를 봉투 <code>C</code> 에 봉인하고, 그 위에 당신의 공개키 <code>pk</code> 를 적은 뒤 둘 다에 서명합니다.
당신은 봉투를 여는 값 (<code>r</code>) 과 개인키 (<code>sk</code>) 를 보관합니다.
게이트에서는 새 챌린지를 받고, <code>sk</code> 를 가진 사람만 쓸 수 있는 증명으로 답합니다.
문지기는 발급소의 서명과 당신의 키, 그리고 증명을 확인할 뿐 그 외에는 아무것도 갖지 않습니다.""",
        "c2": """<b>2 · 증명 만들기.</b> 위에서 아래로 읽으세요. 미색 = 비밀, 남색 = 공개.
핵심은 두 번째 줄입니다. "나는 18세 이상이다" 는 "내 나이에서 18을 뺀 값이 작은 양수다" 와 <em>같은 주장</em>이고,
작은 양수는 모두 여덟 개의 켜짐/꺼짐 스위치(비트)로 쓸 수 있습니다.
각 스위치는 자기만의 작은 봉투에 담깁니다. 그러면 증명은 두 가지를 보입니다. 모든 스위치가 정말로 켜짐 아니면 꺼짐일 뿐이라는 것
(안에 5 같은 값이 숨어 있지 않다는 것), 그리고 스위치들의 합이 큰 봉투 안의 값에서 18을 뺀 것과 같다는 것입니다.
나이가 17이었다면 "나이 − 18" 은 음수라 스위치 형태가 없고, 증명은 아예 만들어지지 않습니다.""",
        "c3": """<b>3 · 기습 질문.</b> 모든 검사 안에 들어 있는 공통 패턴입니다. 증명자는 먼저
무작위 낙서 (<code>t</code>) 를 확정해 둡니다. 질문 (<code>c</code>) 은 <em>그 다음에야</em> 도착하므로
답 (<code>s</code>) 을 미리 준비할 수 없지만, 누구나 검산할 수는 있습니다. 비밀은 무작위성과 함께
<code>s</code> 안에 충분히 섞이므로 <code>s</code> 만으로는 아무것도 알 수 없습니다.
피아트–샤미르가 마지막 요령입니다. 낙서의 해시를 질문으로 <em>삼는</em> 것이죠. 이 데스크에서는 게이트도 기여합니다.
게이트의 무작위 논스가 함께 해시되므로 답은 매 검사마다 새롭고, 이전 것을 복사해 쓸 수 없습니다.
증명은 위 상자에 붙여넣을 수 있는 파일이 됩니다 — 오직 이번 챌린지에 한해서요.""",
    },
}

# --- Technical tabs. English bodies live in app.py (they are the originals);
#     these are the Korean prose replacements, applied line-for-line by key.

MATH_KO = {
"## What is being proven": "## 무엇을 증명하는가",
"The gate sees a Pedersen commitment $C$ and a non-interactive proof $\\pi$.\nIt must be convinced of this relation — and learn nothing else:":
  "게이트는 페더슨 커밋먼트 $C$ 와 비대화형 증명 $\\pi$ 를 봅니다.\n게이트는 다음 관계만 확신해야 하며, 그 외에는 아무것도 알지 못합니다:",
"### Notation": "### 기호",
"| symbol | meaning |": "| 기호 | 의미 |",
"| $p,\\ q$ | primes, $q \\mid (p-1)$, $\\lvert\\mathbb{G}\\rvert = q$ |":
  "| $p,\\ q$ | 소수, $q \\mid (p-1)$, $\\lvert\\mathbb{G}\\rvert = q$ |",
"| $g,\\ h$ | generators of $\\mathbb{G}$; $\\log_g h$ is unknown |":
  "| $g,\\ h$ | $\\mathbb{G}$ 의 생성원; $\\log_g h$ 는 아무도 모름 |",
"| $r,\\ r_i$ | blinding factors in $\\mathbb{Z}_q$ |": "| $r,\\ r_i$ | $\\mathbb{Z}_q$ 의 블라인딩 값 |",
"### 1. Pedersen commitment (hide the age)": "### 1. 페더슨 커밋먼트 (나이 감추기)",
"### 2. Range by bits": "### 2. 비트로 표현하는 범위",
"### 3. Bit is 0 or 1 (Schnorr OR)": "### 3. 비트는 0 또는 1 (슈노어 OR)",
"### 5. Schnorr check, Fiat–Shamir challenge": "### 5. 슈노어 검사와 피아트–샤미르 챌린지",
"### 6. Who owns the envelope": "### 6. 봉투는 누구의 것인가",
"and cannot tell which branch was real (honest-verifier zero-knowledge).":
  "그리고 어느 쪽 가지가 진짜였는지 알 수 없습니다 (정직한 검증자 영지식).",
"The interactive challenge is replaced by a hash of everything the verifier would have seen:":
  "대화형 챌린지는 검증자가 보았을 모든 것의 해시로 대체됩니다:",
"Verifier order: threshold → nonce → issuer signature → owner proof → consistency → bits.":
  "검증 순서: 기준 → 논스 → 발급자 서명 → 소유 증명 → 일관성 → 비트.",
}

PSEUDO_KO = {
"## Algorithms (this repo, no ZKP framework)": "## 알고리즘 (이 저장소, ZKP 프레임워크 없음)",
"### Issue — ID office binds an age": "### 발급 — 발급소가 나이를 봉인",
"### Prove — holder writes a proof for the gate": "### 증명 — 소지자가 게이트를 위한 증명을 작성",
"### OR_ANNOUNCE / OR_RESPOND (one bit)": "### OR_ANNOUNCE / OR_RESPOND (비트 하나)",
}

WHY_KO = {
"## Completeness, soundness, zero-knowledge": "## 완전성, 건전성, 영지식성",
"### Completeness": "### 완전성",
"### Zero-knowledge (why the gate does not learn the age)": "### 영지식성 (게이트가 나이를 알지 못하는 이유)",
"### What this study desk does *not* prove": "### 이 학습용 데스크가 증명하지 *않는* 것",
"the prover would need either": "증명자는 다음 중 하나가 필요합니다",
}

# --- Verifier reasons. zkp/ stays English (it is a library); the desk
#     translates the sentence it shows. Patterns are matched in order.

import re as _re

_REASON_KO = [
    (r"^accept: committed age is in \[(\d+), (\d+)\], issued to this key$",
     lambda m: f"봉인된 나이가 [{m.group(1)}, {m.group(2)}] 범위에 있으며, 이 키 앞으로 발급되었습니다"),
    (r"^proof is for threshold (\d+), verifier requires (\d+)$",
     lambda m: f"이 증명은 기준 {m.group(1)} 용입니다. 검증자는 {m.group(2)} 을(를) 요구합니다"),
    (r"^unexpected bit length (\d+)$", lambda m: f"예상치 못한 비트 길이 {m.group(1)}"),
    (r"^bit commitment / proof count mismatch$", lambda m: "비트 커밋먼트와 증명 개수가 맞지 않습니다"),
    (r"^challenge mismatch: this proof answers a different conversation \(replay\?\)$",
     lambda m: "챌린지 불일치: 이 증명은 다른 대화에 대한 답입니다 (재사용?)"),
    (r"^issuer signature invalid: envelope was not issued by the ID office for this key$",
     lambda m: "발급자 서명이 유효하지 않습니다: 이 봉투는 발급소가 이 키 앞으로 발급한 것이 아닙니다"),
    (r"^owner proof failed: prover does not hold the private key for pk$",
     lambda m: "소유 증명 실패: 증명자가 pk에 대응하는 개인키를 가지고 있지 않습니다"),
    (r"^consistency Schnorr failed \(bits do not sum to age . threshold\)$",
     lambda m: "일관성 슈노어 검사 실패 (비트의 합이 나이 − 기준과 다릅니다)"),
    (r"^bit (\d+) is not proven to be 0 or 1$",
     lambda m: f"비트 {m.group(1)} 이(가) 0 또는 1임이 증명되지 않았습니다"),
]


def reason(lang: str, text: str) -> str:
    """Translate a verifier reason, or hand it back unchanged."""
    if lang != "ko":
        return text
    for pat, fn in _REASON_KO:
        m = _re.match(pat, text)
        if m:
            return fn(m)
    return text
