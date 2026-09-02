-- One map per ZKP step. Answers match python/zkp (age.py, pedersen.py,
-- sigma.py, identity.py, group.py). Alex is 25. The clerk must never learn it.
--
-- Each stage is a real quiz: the blank ___ is NOT written anywhere in the
-- code. The player types the answer. HINT gives a nudge, a second HINT the
-- answer. Compute stages use a toy group small enough to do by hand:
--
--   p = 23, g = 2, h = 3        (Pedersen, Office)
--   p = 23, h = 2, q = 11       (Schnorr: 2 has order 11 mod 23, Sigma)
--
--   q       what is being asked, in one line
--   code    pseudo-python with one ___ blank (7 lines max)
--   accept  spellings that count (case/space/punctuation-insensitive)
--   answer  canonical spelling shown by HINT and after CLEAR
--   hint    one sentence of help (shown before the answer)
--   ok      what the player just learned
--   lesson  (per map) the one line kept for the recap

local maps = {
  {
    id = "street",
    station = "STREET",
    name = "Percival Street",
    title = "The fact, not the number",
    lesson = "The gate needs one FACT (age >= 18), never the number.",
    bg = "bg_street",
    portrait = "portrait_friends",
    speaker = "Mei + Ken",
    ground = 348,
    spawn = 160,
    width = 1680,
    npcs = {
      { kind = "mei", x = 520, facing = -1, line = "Alex!! Beer run. Lucky Mart. Move it." },
      { kind = "ken", x = 780, facing = -1, line = "Don't flash your ID. Uncle Wing gossips on the block." },
    },
    viz = "street",
    story = "Lucky Mart has ONE public rule: you must be an adult. Alex is 25. "
      .. "The goal tonight: prove the rule holds without ever saying 25.",
    stages = {
      {
        topic = "POLICY",
        q = "The rule is a comparison, not a number. Fill in the operator: prove age ___ T.",
        code = [[
# Public policy. Not a secret.
T = 18                  # adult threshold
# the FACT the gate needs:
prove:  age ___ T
# the SECRET it must not get:
hide:   age == 25
]],
        accept = { ">=", "=>", "≥", "atleast", "gte", "greaterorequal", "greaterthanorequal" },
        answer = ">=",
        hint = "The fact is an inequality: at least 18. The exact number is the secret.",
        ok = "Prove age >= T. T = 18 is public. 25 stays in Alex's pocket.",
      },
    },
  },

  {
    id = "mart",
    station = "MART",
    name = "Lucky Mart",
    title = "What a ZKP promises",
    lesson = "Three promises: completeness, soundness, zero-knowledge.",
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = "Uncle Wing",
    ground = 348,
    spawn = 180,
    width = 1600,
    npcs = {
      { kind = "clerk", x = 540, facing = 1, line = "ID. Or no beer. I don't make the rules, I sell the beer." },
      { kind = "mei", x = 280, facing = 1, line = "Tell him it's a zero-knowledge proof. He'll love that." },
    },
    viz = "mart",
    story = "A zero-knowledge proof makes three promises. Completeness: an honest adult gets in. "
      .. "Soundness: a kid cannot fake it. Zero-knowledge: the clerk learns the FACT, not the SECRET.",
    stages = {
      {
        topic = "ZKP",
        q = "Uncle Wing learns the fact. What number must he NEVER learn?",
        code = [[
# Three promises
#   completeness  : honest adult -> ADMIT
#   soundness     : age < T      -> DENY
#   zero-knowledge: FACT, not SECRET
learns       = "age >= 18"   # the fact
never_learns = ___           # the secret
]],
        accept = { "25" },
        answer = "25",
        hint = "Alex's real age is the secret. He learns age >= 18, never the number.",
        ok = "He learns age >= 18. He does not learn 25. That is zero knowledge.",
      },
      {
        topic = "ZKP",
        q = "A 17-year-old tries to forge a proof and fails. Which promise is that?",
        code = [[
# kid = 17, tries to fake age >= 18
# the proof does not verify

promise = "___"
]],
        accept = { "soundness", "sound" },
        answer = "soundness",
        hint = "Completeness = honest adult passes. Soundness = a liar cannot pass.",
        ok = "Soundness: no proof exists for a false statement.",
      },
      {
        topic = "ZKP",
        q = "Alex is honest and holds (age, r) and sk. Every equation passes. Which promise is that?",
        code = [[
# Alex = 25, holds (age, r) and sk
# runs prove_adult -> every check holds -> ADMIT

promise = "___"
]],
        accept = { "completeness", "complete" },
        answer = "completeness",
        hint = "The promise to the honest prover: the door always opens for the truth.",
        ok = "Completeness: a true statement with a real witness always verifies.",
      },
    },
  },

  {
    id = "office",
    station = "OFFICE",
    name = "ID office",
    title = "Commitment = sealed envelope",
    lesson = "C = g^age * h^r hides the age and cannot be reopened as another.",
    bg = "bg_office",
    portrait = "portrait_officer",
    speaker = "Ms. Chow",
    ground = 348,
    spawn = 200,
    width = 1600,
    npcs = {
      { kind = "officer", x = 700, facing = -1, line = "I seal your age. The shop only sees the envelope." },
    },
    viz = "office",
    story = "The ID office seals the age in a Pedersen commitment C = g^age * h^r mod p. "
      .. "The envelope C is public. The opening (age, r) stays with Alex.",
    stages = {
      {
        topic = "COMMIT",
        q = "The office adds fresh randomness so C looks random. What is its name in the code?",
        code = [[
# python/zkp/pedersen.py   C = g^age * h^r
def issue(age):
    r = random_scalar()
    C = pow(g, age) * pow(h, ___)
    holder_keeps = (age, r)
    world_sees   = C
]],
        accept = { "r" },
        answer = "r",
        hint = "The blinding factor is called r. Without r, C = g^age would be guessable.",
        ok = "C = g^age * h^r. World sees C. Alex keeps (age, r).",
      },
      {
        topic = "COMMIT",
        q = "Toy group p = 23, g = 2, h = 3. Seal age = 5 with r = 4: C = 9 * 12 mod 23 = ?",
        code = [[
# toy numbers: p = 23, g = 2, h = 3
age, r = 5, 4
pow(g, age) % p  == 9      # 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12     # 3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___
]],
        accept = { "16" },
        answer = "16",
        hint = "9 * 12 = 108, and 108 = 4 * 23 + 16.",
        ok = "C = 16. Uncle Wing sees 16, not 5. Every age has some r that gives 16.",
      },
      {
        topic = "COMMIT",
        q = "Nobody can read 5 out of 16: for any age there is an r that fits. Which property is that?",
        code = [[
# Two properties of a commitment:
#   ___     : C reveals nothing about age
#   binding : C cannot be opened as another age

property_one = "___"
]],
        accept = { "hiding", "hide" },
        answer = "hiding",
        hint = "Hiding = the envelope is opaque. Binding = the envelope cannot be swapped.",
        ok = "Hiding: C is uniform whatever the age. Zero-knowledge starts here.",
      },
      {
        topic = "COMMIT",
        q = "Alex later claims 16 was age 6. He would need log_g(h), which nobody knows. Which property stops him?",
        code = [[
# Alex claims C = 16 opens as age = 6:
#   needs r' with 2^6 * 3^r' = 16 (mod 23)
#   two openings  =>  log_g(h) is known
# g and h are hash-to-group: nobody knows it.
property_two = "___"
]],
        accept = { "binding", "bind" },
        answer = "binding",
        hint = "Hiding you already typed. The other property: the seal cannot be re-opened differently.",
        ok = "Binding: 25 cannot become 19 later. One envelope, one age.",
      },
    },
  },

  {
    id = "bits",
    station = "BITS",
    name = "Bit alley",
    title = "Prove a RANGE, not a number",
    lesson = "age >= 18 is proven as 8 committed 0/1 bits of age - 18.",
    bg = "bg_bits",
    portrait = "portrait_hero",
    speaker = "Alex (you)",
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {},
    viz = "bits",
    story = "age >= 18 becomes: age = 18 + delta and delta fits in 8 bits (0..255). "
      .. "Each bit gets its own commitment. A kid would need a negative delta, which has no bits.",
    stages = {
      {
        topic = "RANGE",
        q = "Alex is 25 and T is 18. What is delta?",
        code = [[
# age = T + delta,  delta in [0, 255]
age   = 25          # stays on YOUR phone
T     = 18          # public policy
delta = age - T
delta == ___
]],
        accept = { "7" },
        answer = "7",
        hint = "delta = age - T = 25 - 18.",
        ok = "delta = 7. Uncle Wing sees 8 bit-envelopes, never the 7.",
      },
      {
        topic = "RANGE",
        q = "Write delta = 7 in binary (three bits are enough).",
        code = [[
# delta = sum(b_i * 2^i)
# each bit is committed on its own:
#   C_i = g^{b_i} * h^{r_i}

bits(7) = 0b___
]],
        accept = { "111", "00000111", "0b111", "0b00000111" },
        answer = "111",
        hint = "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
        ok = "7 = 0b111. Eight OR-proofs show every lamp is really 0 or 1.",
      },
      {
        topic = "RANGE",
        q = "A 17-year-old tries. What is their delta? (this is why they fail)",
        code = [[
# soundness: why 17 cannot pass a door of 18
age   = 17
T     = 18
delta = age - T
delta == ___          # not an 8-bit unsigned number
]],
        accept = { "-1", "minus1", "negative1" },
        answer = "-1",
        hint = "17 - 18 is negative. Negative numbers have no 0/1 bit form.",
        ok = "delta = -1 has no 8-bit form. No bits, no proof. Soundness.",
      },
      {
        topic = "RANGE",
        q = "8 bits cover delta 0..255. What is the oldest age this proof can handle?",
        code = [[
# python/zkp/age.py
N_BITS  = 8                     # delta in [0, 255]
MAX_AGE = ADULT_AGE + (1 << N_BITS) - 1
MAX_AGE == ___
]],
        accept = { "273" },
        answer = "273",
        hint = "18 + 255.",
        ok = "18 + 255 = 273. The range is public too: [18, 273]. Only the position inside it is secret.",
      },
    },
  },

  {
    id = "sigma",
    station = "SIGMA",
    name = "Sigma club",
    title = "The three-move protocol",
    lesson = "t, c, s: the gate checks h^s = t * Y^c without x. Fiat-Shamir: c = SHA256(transcript).",
    bg = "bg_sigma",
    portrait = "portrait_hero",
    speaker = "Sigma protocol",
    ground = 348,
    spawn = 180,
    width = 1700,
    npcs = {
      { kind = "clerk", x = 980, facing = -1, line = "First you speak, then I speak, then you speak again." },
    },
    viz = "sigma",
    story = "A Sigma protocol is three moves: the prover announces t, the verifier challenges with c, "
      .. "the prover responds with s. Toy group here: p = 23, h = 2, q = 11.",
    stages = {
      {
        topic = "PROVE",
        q = "Schnorr: t, then c, then ... what is the third message called?",
        code = [[
# Sigma  (Schnorr)   PoK{ x : Y = h^x }
# 1. Prover   ->  t = h^k        announcement
# 2. Verifier ->  c              challenge
# 3. Prover   ->  ___ = k + c*x  response
]],
        accept = { "s" },
        answer = "s",
        hint = "Announcement t, challenge c, response s. The secret x never ships.",
        ok = "s = k + c*x. The secret x is masked by the random k.",
      },
      {
        topic = "PROVE",
        q = "Toy Schnorr: x = 5, k = 3, c = 2, q = 11. Compute s = (k + c*x) mod q.",
        code = [[
# toy: p = 23, h = 2, q = 11  (2 has order 11 mod 23)
x = 5            # secret      Y = 2^5 mod 23 = 9
k = 3            # random      t = 2^3 mod 23 = 8
c = 2            # challenge
s = (k + c * x) % q  == ___
]],
        accept = { "2" },
        answer = "2",
        hint = "3 + 2 * 5 = 13, and 13 mod 11 = 2.",
        ok = "s = 2. Alex sends (t, s) = (8, 2). Not x.",
      },
      {
        topic = "PROVE",
        q = "Gate check: h^s == t * Y^c mod 23. Left is 2^2 = 4. Compute the right side 8 * 81 mod 23.",
        code = [[
# gate:  h^s  ==  t * Y^c   (mod 23)
left  = 2^2 % 23             # 4
right = 8 * 9^2 % 23         # 8 * 81 = 648
right == ___
# left == right  ->  the gate is convinced
]],
        accept = { "4" },
        answer = "4",
        hint = "81 mod 23 = 12, so 8 * 12 = 96, and 96 = 4 * 23 + 4.",
        ok = "4 == 4. The gate verified without ever touching x = 5.",
      },
      {
        topic = "PROVE",
        q = "Ken has no x. He guesses s = 5. What is his left side 2^5 mod 23? (right side is still 4)",
        code = [[
# Ken does not know x. He guesses s = 5.
left  = 2^5 % 23  == ___
right = 4
# left != right  ->  DENY
]],
        accept = { "9" },
        answer = "9",
        hint = "2^5 = 32, and 32 - 23 = 9.",
        ok = "9 != 4. DENY. A blind guess passes 1 time in q; real q is 256-bit.",
      },
      {
        topic = "PROVE",
        q = "Fiat-Shamir: which hash function makes the challenge c in python/zkp?",
        code = [[
# no back-and-forth: hash the transcript
# python/zkp/group.py  fiat_shamir
# transcript = the statement + every t

c = ___(transcript) mod q
]],
        accept = { "sha256", "sha-256", "sha2", "sha" },
        answer = "sha256",
        hint = "group.py uses hashlib.sha256 over the whole transcript.",
        ok = "c = SHA256(transcript). Nobody can pick c after seeing t. Non-interactive, still sound.",
      },
    },
  },

  {
    id = "hash",
    station = "NONCE",
    name = "Tonight's ticket",
    title = "YOUR envelope, THIS conversation",
    lesson = "sk + the office's signature on (C, pk) + a fresh nonce bind the proof to Alex, tonight.",
    bg = "bg_hash",
    portrait = "portrait_clerk",
    speaker = "Uncle Wing",
    ground = 348,
    spawn = 200,
    width = 1650,
    npcs = {
      { kind = "clerk", x = 640, facing = 1, line = "New ticket every customer. Yesterday's JSON is trash." },
      { kind = "officer", x = 1100, facing = -1, line = "I signed (C, pk). Nobody else can mint this envelope." },
    },
    viz = "hash",
    story = "Three things bind the proof to Alex: a holder key pair, the office's signature on (C, pk), "
      .. "and a fresh nonce from the gate mixed into the hash.",
    stages = {
      {
        topic = "BIND",
        q = "pk = g^? -- what is the holder's private key called?",
        code = [[
# python/zkp/identity.py  keygen
sk = random_scalar()      # NEVER leaves the phone
pk = pow(g, ___)          # public
]],
        accept = { "sk" },
        answer = "sk",
        hint = "sk = secret key, pk = public key. pk = g^sk.",
        ok = "pk = g^sk. A stolen envelope without sk cannot answer.",
      },
      {
        topic = "BIND",
        q = "The ID office signs two things together so the envelope belongs to one key. C and what?",
        code = [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])
# the gate trusts office_pk, so a good sig means:
# "sealed by the office, for the owner of this key"
]],
        accept = { "pk", "publickey", "holderpk" },
        answer = "pk",
        hint = "The public half of the holder's key pair.",
        ok = "sig over (C, pk). A self-made envelope has no office signature: DENY at the door.",
      },
      {
        topic = "BIND",
        q = "The gate gives every customer a fresh random ticket. What is it called?",
        code = [[
# fresh random ticket from the gate.
# mixed into the hash so last night's
# JSON cannot be replayed.

proof.___ = gate_challenge
]],
        accept = { "nonce" },
        answer = "nonce",
        hint = "A number used once: n-once.",
        ok = "c = SHA256(nonce, C, pk, ...). A proof answers exactly one ticket.",
      },
      {
        topic = "BIND",
        q = "Ken copies last night's proof JSON and shows it tonight. What does the gate print?",
        code = [[
# last night:  nonce = "a1f3"   proof.nonce = "a1f3"
# tonight:     nonce = "9c07"
verify(proof, nonce="9c07")
# proof.nonce != nonce  ->  "___"
]],
        accept = { "deny", "denied", "reject", "rejected", "fail" },
        answer = "DENY",
        hint = "The red stamp. The proof answers a different conversation.",
        ok = "DENY: challenge mismatch. Replay dies at the door.",
      },
    },
  },

  {
    id = "beer",
    station = "BEER",
    name = "The fridge",
    title = "How verification works",
    lesson = "Verify checks equations only. ADMIT reveals age >= 18 and nothing more.",
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = "The gate",
    ground = 348,
    spawn = 200,
    width = 1600,
    npcs = {
      { kind = "clerk", x = 500, facing = 1, line = "Threshold, nonce, signature, owner, consistency, bits..." },
      { kind = "mei", x = 720, facing = -1, line = "If this prints ADMIT I am buying spicy fish." },
      { kind = "ken", x = 980, facing = -1, line = "He still does not know you are 25. Beautiful." },
    },
    viz = "beer",
    story = "Verification never opens C. It only checks equations: threshold, nonce, issuer signature, "
      .. "owner key, bit consistency, every bit is 0 or 1. Then the stamp.",
    stages = {
      {
        topic = "VERIFY",
        q = "Cheap checks first. Before any math, which field of the proof is compared to the door's own 18?",
        code = [[
# python/zkp/age.py  verify_adult  (in this order)
1. proof.___ == 18                  # the door's own policy
2. proof.nonce == nonce             # this conversation
3. verify_sig(office_pk, (C, pk))   # sealed by the office
4. schnorr(pk, proof.owner, c)      # holder knows sk
]],
        accept = { "threshold", "t", "policy" },
        answer = "threshold",
        hint = "A proof written for T = 16 dies at line 1 of a door of 18, before any exponentiation.",
        ok = "Order: threshold, nonce, signature, owner, then consistency and bits. The JSON's T never overrides the door's.",
      },
      {
        topic = "VERIFY",
        q = "Mei flips one hex digit of C in the JSON. The office never signed that C. What does the gate print?",
        code = [[
# Mei edits C in the JSON:  "0x3a9..." -> "0x3b9..."
# check 3: verify_sig(office_pk, (C, pk))
# the office signed the OLD C, not this one
verify(proof, nonce)  ->  "___"
]],
        accept = { "deny", "denied", "reject", "rejected", "fail" },
        answer = "DENY",
        hint = "Same stamp as the replay. One wrong digit, signature dead.",
        ok = "DENY: issuer signature invalid. Every number in the proof is pinned by an equation.",
      },
      {
        topic = "VERIFY",
        q = "Alex's real proof, tonight's nonce. Every equation holds and he still does not know 25. Print?",
        code = [[
    # bits sum to age - T, each bit 0 or 1
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):
        assert bit_verify(C_i, bp, c)
    return "___"
]],
        accept = { "admit", "accept", "ok", "pass" },
        answer = "ADMIT",
        hint = "The green stamp. Opposite of DENY.",
        ok = "ADMIT. He learned age >= 18. He did not learn 25.",
      },
    },
  },
}

return maps
