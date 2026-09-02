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
-- Text fields are L(en, ko, yue) tables; I18n.pick chooses the language.
-- Code blocks keep the same python in every language; only the comments,
-- which say what every variable means, are translated.
--
--   q       what is being asked, in one line
--   code    pseudo-python with one ___ blank (7 lines max)
--   accept  spellings that count (case/space/punctuation-insensitive),
--           English and localized
--   answer  canonical spelling shown by HINT and after CLEAR
--   hint    one sentence of help (shown before the answer)
--   ok      what the player just learned
--   lesson  (per map) the one line kept for the recap

local function L(en, ko, yue)
  return { en = en, ko = ko, yue = yue }
end

local maps = {
  {
    id = "street",
    station = "STREET",
    name = L("Percival Street", "퍼시벌 스트리트", "波斯富街"),
    title = L("The fact, not the number", "숫자가 아니라 사실", "係事實，唔係數字"),
    lesson = L(
      "The gate needs one FACT (age >= 18), never the number.",
      "게이트에 필요한 건 사실 하나(age >= 18)뿐, 숫자는 절대 아니다.",
      "閘口只需要一個事實（age >= 18），永遠唔需要個數字。"
    ),
    bg = "bg_street",
    portrait = "portrait_friends",
    speaker = L("Mei + Ken", "메이 + 켄", "阿美 + 阿健"),
    ground = 348,
    spawn = 160,
    width = 1680,
    npcs = {
      {
        kind = "mei",
        x = 520,
        facing = -1,
        line = L(
          "Alex!! Beer run. Lucky Mart. Move it.",
          "알렉스!! 맥주 사러 가자. 럭키 마트. 빨리!",
          "阿力！！去買啤酒，幸運士多，快啲！"
        ),
      },
      {
        kind = "ken",
        x = 780,
        facing = -1,
        line = L(
          "Don't flash your ID. Uncle Wing gossips on the block.",
          "신분증 보여주지 마. 윙 아저씨는 동네 소문쟁이야.",
          "唔好晒你張身份證，榮叔成條街講是非㗎。"
        ),
      },
    },
    viz = "street",
    story = L(
      "Lucky Mart has ONE public rule: you must be an adult. Alex is 25. "
        .. "The goal tonight: prove the rule holds without ever saying 25.",
      "럭키 마트의 공개 규칙은 하나: 성인이어야 한다. 알렉스는 25살. "
        .. "오늘 밤 목표: 25라는 숫자를 한 번도 말하지 않고 규칙을 만족함을 증명하기.",
      "幸運士多得一條公開規矩：一定要係成年人。阿力25歲。"
        .. "今晚嘅目標：由頭到尾唔講「25」，都證明到符合規矩。"
    ),
    stages = {
      {
        topic = "POLICY",
        q = L(
          "The rule is a comparison, not a number. Fill in the operator: prove age ___ T.",
          "규칙은 숫자가 아니라 비교입니다. 연산자를 채우세요: prove age ___ T.",
          "規矩係一個比較，唔係一個數字。填返個運算符：prove age ___ T。"
        ),
        code = L(
          [[
# Public policy. Not a secret.
T   = 18                # T: adult threshold, public
age = 25                # age: Alex's number, secret
prove:  age ___ T       # the FACT the gate needs
hide:   age             # the SECRET it must not get
]],
          [[
# 공개 정책. 비밀이 아님.
T   = 18                # T: 성인 기준, 공개
age = 25                # age: 알렉스의 숫자, 비밀
prove:  age ___ T       # 게이트에 필요한 사실
hide:   age             # 절대 주면 안 되는 비밀
]],
          [[
# 公開政策，唔係秘密。
T   = 18                # T: 成年門檻，公開
age = 25                # age: 阿力嘅數字，秘密
prove:  age ___ T       # 閘口需要嘅事實
hide:   age             # 唔可以俾佢嘅秘密
]]
        ),
        accept = {
          ">=",
          "=>",
          "≥",
          "atleast",
          "gte",
          "greaterorequal",
          "greaterthanorequal",
          "이상",
          "大於等於",
        },
        answer = ">=",
        hint = L(
          "The fact is an inequality: at least 18. The exact number is the secret.",
          "사실은 부등식입니다: 18 이상. 정확한 숫자가 비밀입니다.",
          "事實係一個不等式：至少18。準確數字先係秘密。"
        ),
        ok = L(
          "Prove age >= T. T = 18 is public. 25 stays in Alex's pocket.",
          "age >= T를 증명. T = 18은 공개. 25는 알렉스 주머니에.",
          "證明 age >= T。T = 18 係公開。25 留喺阿力袋入面。"
        ),
      },
    },
  },

  {
    id = "mart",
    station = "MART",
    name = L("Lucky Mart", "럭키 마트", "幸運士多"),
    title = L("What a ZKP promises", "ZKP가 약속하는 것", "ZKP 承諾啲乜"),
    lesson = L(
      "Three promises: completeness, soundness, zero-knowledge.",
      "세 가지 약속: 완전성, 건전성, 영지식.",
      "三個承諾：完備性、可靠性、零知識。"
    ),
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔"),
    ground = 348,
    spawn = 180,
    width = 1600,
    npcs = {
      {
        kind = "clerk",
        x = 540,
        facing = 1,
        line = L(
          "ID. Or no beer. I don't make the rules, I sell the beer.",
          "신분증. 아니면 맥주 없어. 규칙은 내가 만든 게 아냐, 난 맥주만 팔아.",
          "身份證。冇就冇啤酒。規矩唔係我定嘅，我淨係賣啤酒。"
        ),
      },
      {
        kind = "mei",
        x = 280,
        facing = 1,
        line = L(
          "Tell him it's a zero-knowledge proof. He'll love that.",
          "영지식 증명이라고 말해봐. 엄청 좋아할걸.",
          "同佢講呢個係零知識證明，佢實鍾意。"
        ),
      },
    },
    viz = "mart",
    story = L(
      "A zero-knowledge proof makes three promises. Completeness: an honest adult gets in. "
        .. "Soundness: a kid cannot fake it. Zero-knowledge: the clerk learns the FACT, not the SECRET.",
      "영지식 증명은 세 가지를 약속합니다. 완전성: 정직한 성인은 들어간다. "
        .. "건전성: 아이는 속일 수 없다. 영지식: 점원은 사실만 알고 비밀은 모른다.",
      "零知識證明有三個承諾。完備性：誠實嘅成年人入到。"
        .. "可靠性：細路仔冇得呃。零知識：店員只知道事實，唔知道秘密。"
    ),
    stages = {
      {
        topic = "ZKP",
        q = L(
          "Uncle Wing learns the fact. What number must he NEVER learn?",
          "윙 아저씨는 사실을 알게 됩니다. 절대 알면 안 되는 숫자는?",
          "榮叔知道咗事實。佢永遠唔可以知道邊個數字？"
        ),
        code = L(
          [[
# Three promises of a ZKP
#   completeness  : honest adult -> ADMIT
#   soundness     : age < T      -> DENY
#   zero-knowledge: FACT, not SECRET
learns       = "age >= 18"   # the fact   (T = 18)
never_learns = ___           # the secret (Alex's age)
]],
          [[
# ZKP의 세 가지 약속
#   completeness  : 정직한 성인 -> ADMIT
#   soundness     : age < T     -> DENY
#   zero-knowledge: 사실만, 비밀은 아님
learns       = "age >= 18"   # 사실   (T = 18)
never_learns = ___           # 비밀 (알렉스의 나이)
]],
          [[
# ZKP 嘅三個承諾
#   completeness  : 誠實成年人 -> ADMIT
#   soundness     : age < T    -> DENY
#   zero-knowledge: 事實，唔係秘密
learns       = "age >= 18"   # 事實   (T = 18)
never_learns = ___           # 秘密 (阿力嘅年齡)
]]
        ),
        accept = { "25" },
        answer = "25",
        hint = L(
          "Alex's real age is the secret. He learns age >= 18, never the number.",
          "알렉스의 실제 나이가 비밀입니다. 그는 age >= 18만 알고 숫자는 모릅니다.",
          "阿力嘅真實年齡係秘密。佢只知道 age >= 18，唔知道數字。"
        ),
        ok = L(
          "He learns age >= 18. He does not learn 25. That is zero knowledge.",
          "그는 age >= 18을 알고, 25는 모릅니다. 그게 영지식입니다.",
          "佢知道 age >= 18，唔知道 25。呢個就係零知識。"
        ),
      },
      {
        topic = "ZKP",
        q = L(
          "A 17-year-old tries to forge a proof and fails. Which promise is that?",
          "17살이 증명을 위조하려다 실패합니다. 어떤 약속인가요?",
          "一個17歲嘅試圖偽造證明，失敗咗。呢個係邊個承諾？"
        ),
        code = L(
          [[
# kid = 17, tries to fake age >= 18
# the proof does not verify

promise = "___"
]],
          [[
# 아이 = 17, age >= 18을 속이려 함
# 증명이 검증되지 않음

promise = "___"
]],
          [[
# 細路 = 17，想呃 age >= 18
# 個證明驗證唔到

promise = "___"
]]
        ),
        accept = { "soundness", "sound", "건전성", "可靠性", "健全性", "穩固性" },
        answer = "soundness",
        hint = L(
          "Completeness = honest adult passes. Soundness = a liar cannot pass.",
          "완전성 = 정직한 성인은 통과. 건전성 = 거짓말쟁이는 통과 불가.",
          "完備性 = 誠實成年人過到。可靠性 = 講大話嘅過唔到。"
        ),
        ok = L(
          "Soundness: no proof exists for a false statement.",
          "건전성: 거짓 명제에는 증명이 존재하지 않는다.",
          "可靠性：假嘅命題冇證明存在。"
        ),
      },
      {
        topic = "ZKP",
        q = L(
          "Alex is honest and holds (age, r) and sk. Every equation passes. Which promise is that?",
          "알렉스는 정직하고 (age, r)와 sk를 가지고 있습니다. 모든 식이 통과합니다. 어떤 약속인가요?",
          "阿力係誠實嘅，持有 (age, r) 同 sk。每條式都通過。呢個係邊個承諾？"
        ),
        code = L(
          [[
# Alex = 25, holds (age, r) and sk
# runs prove_adult -> every check holds -> ADMIT

promise = "___"
]],
          [[
# 알렉스 = 25, (age, r)와 sk 보유
# prove_adult 실행 -> 모든 검사 통과 -> ADMIT

promise = "___"
]],
          [[
# 阿力 = 25，持有 (age, r) 同 sk
# 行 prove_adult -> 每個檢查通過 -> ADMIT

promise = "___"
]]
        ),
        accept = { "completeness", "complete", "완전성", "完備性", "完整性" },
        answer = "completeness",
        hint = L(
          "The promise to the honest prover: the door always opens for the truth.",
          "정직한 증명자에 대한 약속: 진실 앞에서는 문이 항상 열린다.",
          "對誠實證明者嘅承諾：真相面前道門一定開。"
        ),
        ok = L(
          "Completeness: a true statement with a real witness always verifies.",
          "완전성: 참인 명제와 진짜 증거는 항상 검증된다.",
          "完備性：真命題加真證據，一定驗證通過。"
        ),
      },
    },
  },

  {
    id = "office",
    station = "OFFICE",
    name = L("ID office", "신분증 발급소", "身份證辦事處"),
    title = L("Commitment = sealed envelope", "커밋먼트 = 봉인된 봉투", "承諾 = 封咗口嘅信封"),
    lesson = L(
      "C = g^age * h^r hides the age and cannot be reopened as another.",
      "C = g^age * h^r는 나이를 숨기고, 다른 나이로 다시 열 수 없다.",
      "C = g^age * h^r 收埋年齡，而且唔可以當另一個年齡打開。"
    ),
    bg = "bg_office",
    portrait = "portrait_officer",
    speaker = L("Ms. Chow", "초우 씨", "周小姐"),
    ground = 348,
    spawn = 200,
    width = 1600,
    npcs = {
      {
        kind = "officer",
        x = 700,
        facing = -1,
        line = L(
          "I seal your age. The shop only sees the envelope.",
          "당신의 나이를 봉인합니다. 가게는 봉투만 봅니다.",
          "我幫你封住你嘅年齡。間舖只會見到個信封。"
        ),
      },
    },
    viz = "office",
    story = L(
      "The ID office seals the age in a Pedersen commitment C = g^age * h^r mod p. "
        .. "The envelope C is public. The opening (age, r) stays with Alex.",
      "발급소는 나이를 페더슨 커밋먼트 C = g^age * h^r mod p에 봉인합니다. "
        .. "봉투 C는 공개. 열쇠 (age, r)는 알렉스가 가집니다.",
      "辦事處用 Pedersen 承諾 C = g^age * h^r mod p 封住年齡。"
        .. "信封 C 係公開嘅。開封資料 (age, r) 留喺阿力度。"
    ),
    stages = {
      {
        topic = "COMMIT",
        q = L(
          "The office adds fresh randomness so C looks random. What is its name in the code?",
          "발급소는 C가 무작위로 보이도록 새 난수를 섞습니다. 코드에서 그 이름은?",
          "辦事處加入新嘅隨機數，令 C 睇落隨機。佢喺代碼入面叫乜名？"
        ),
        code = L(
          [[
# python/zkp/pedersen.py
# g, h: generators of the group    p: prime modulus
def issue(age):                   # age: the secret number
    r = random_scalar()           # r: blinding factor, secret
    C = pow(g, age) * pow(h, ___) # C: the sealed envelope
    holder_keeps = (age, r)       # the opening
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 군의 생성원    p: 소수 모듈러스
def issue(age):                   # age: 비밀 숫자
    r = random_scalar()           # r: 블라인딩 인자, 비밀
    C = pow(g, age) * pow(h, ___) # C: 봉인된 봉투
    holder_keeps = (age, r)       # 열쇠
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 群嘅生成元    p: 質數模數
def issue(age):                   # age: 秘密數字
    r = random_scalar()           # r: 盲化因子，秘密
    C = pow(g, age) * pow(h, ___) # C: 封住嘅信封
    holder_keeps = (age, r)       # 開封資料
    world_sees   = C
]]
        ),
        accept = { "r" },
        answer = "r",
        hint = L(
          "The blinding factor is called r. Without r, C = g^age would be guessable.",
          "블라인딩 인자의 이름은 r. r이 없으면 C = g^age는 추측 가능.",
          "盲化因子叫 r。冇咗 r，C = g^age 就估到。"
        ),
        ok = L(
          "C = g^age * h^r. World sees C. Alex keeps (age, r).",
          "C = g^age * h^r. 세상은 C를 보고, 알렉스는 (age, r)를 갖는다.",
          "C = g^age * h^r。世界見到 C，阿力留住 (age, r)。"
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Toy group p = 23, g = 2, h = 3. Seal age = 5 with r = 4: C = 9 * 12 mod 23 = ?",
          "장난감 군 p = 23, g = 2, h = 3. age = 5를 r = 4로 봉인: C = 9 * 12 mod 23 = ?",
          "玩具群 p = 23, g = 2, h = 3。用 r = 4 封住 age = 5：C = 9 * 12 mod 23 = ?"
        ),
        code = L(
          [[
# toy: p = 23 modulus,  g = 2 and h = 3 generators
age, r = 5, 4               # age: secret   r: blinding
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: the envelope Uncle Wing sees
]],
          [[
# 장난감: p = 23 모듈러스,  g = 2, h = 3 생성원
age, r = 5, 4               # age: 비밀   r: 블라인딩
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: 윙 아저씨가 보는 봉투
]],
          [[
# 玩具: p = 23 模數,  g = 2 同 h = 3 生成元
age, r = 5, 4               # age: 秘密   r: 盲化
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: 榮叔見到嘅信封
]]
        ),
        accept = { "16" },
        answer = "16",
        hint = L(
          "9 * 12 = 108, and 108 = 4 * 23 + 16.",
          "9 * 12 = 108, 그리고 108 = 4 * 23 + 16.",
          "9 * 12 = 108，而 108 = 4 * 23 + 16。"
        ),
        ok = L(
          "C = 16. Uncle Wing sees 16, not 5. Every age has some r that gives 16.",
          "C = 16. 윙 아저씨는 5가 아니라 16을 봅니다. 어떤 나이든 16이 되는 r이 있습니다.",
          "C = 16。榮叔見到 16，唔係 5。任何年齡都有某個 r 可以得出 16。"
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Nobody can read 5 out of 16: for any age there is an r that fits. Which property is that?",
          "16에서 5를 읽어낼 수 없습니다: 어떤 나이에도 맞는 r이 있으니까요. 어떤 성질인가요?",
          "冇人可以由 16 讀返 5：任何年齡都有個啱嘅 r。呢個係咩性質？"
        ),
        code = L(
          [[
# Two properties of a commitment C = g^age * h^r
#   ___     : C reveals nothing about age
#   binding : C cannot be opened as another age
# C: envelope (public)   age, r: the opening (secret)
property_one = "___"
]],
          [[
# 커밋먼트 C = g^age * h^r의 두 가지 성질
#   ___     : C는 age에 대해 아무것도 드러내지 않음
#   binding : C를 다른 age로 열 수 없음
# C: 봉투 (공개)   age, r: 열쇠 (비밀)
property_one = "___"
]],
          [[
# 承諾 C = g^age * h^r 嘅兩個性質
#   ___     : C 唔會透露任何關於 age 嘅嘢
#   binding : C 唔可以當另一個 age 打開
# C: 信封 (公開)   age, r: 開封資料 (秘密)
property_one = "___"
]]
        ),
        accept = { "hiding", "hide", "은닉", "은닉성", "숨김", "隱藏", "隱藏性" },
        answer = "hiding",
        hint = L(
          "Hiding = the envelope is opaque. Binding = the envelope cannot be swapped.",
          "은닉(hiding) = 봉투가 불투명. 구속(binding) = 봉투를 바꿔칠 수 없음.",
          "隱藏 (hiding) = 信封係不透明嘅。綁定 (binding) = 信封唔可以掉包。"
        ),
        ok = L(
          "Hiding: C is uniform whatever the age. Zero-knowledge starts here.",
          "은닉: 나이가 무엇이든 C는 균일 분포. 영지식은 여기서 시작.",
          "隱藏：無論年齡係幾多，C 都係均勻分佈。零知識由呢度開始。"
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Alex later claims 16 was age 6. He would need log_g(h), which nobody knows. Which property stops him?",
          "알렉스가 나중에 16이 age 6이었다고 주장합니다. 아무도 모르는 log_g(h)가 필요하죠. 어떤 성질이 막나요?",
          "阿力事後話 16 其實係 age 6。佢需要冇人知嘅 log_g(h)。咩性質阻止佢？"
        ),
        code = L(
          [[
# Alex claims C = 16 opens as age = 6:
#   needs r' with 2^6 * 3^r' = 16 (mod 23)   r': new blinding
#   two openings  =>  log_g(h) is known    (h = g^x, x known)
# g and h are hash-to-group: nobody knows that x.
property_two = "___"
]],
          [[
# 알렉스가 C = 16이 age = 6이라고 주장:
#   2^6 * 3^r' = 16 (mod 23)인 r'이 필요   r': 새 블라인딩
#   열쇠가 둘  =>  log_g(h)를 안다는 뜻   (h = g^x, x를 앎)
# g와 h는 해시로 만든 생성원: 그 x는 아무도 모름.
property_two = "___"
]],
          [[
# 阿力話 C = 16 開出嚟係 age = 6:
#   需要 r' 令 2^6 * 3^r' = 16 (mod 23)   r': 新盲化
#   兩個開封  =>  即係知道 log_g(h)   (h = g^x, 知道 x)
# g 同 h 係 hash 出嚟嘅: 冇人知道嗰個 x。
property_two = "___"
]]
        ),
        accept = { "binding", "bind", "구속", "구속성", "바인딩", "綁定", "約束" },
        answer = "binding",
        hint = L(
          "Hiding you already typed. The other property: the seal cannot be re-opened differently.",
          "은닉은 이미 입력했죠. 다른 성질: 봉인을 다르게 다시 열 수 없다.",
          "隱藏你已經打咗。另一個性質：封印唔可以用另一種方式重開。"
        ),
        ok = L(
          "Binding: 25 cannot become 19 later. One envelope, one age.",
          "구속: 25가 나중에 19가 될 수 없다. 봉투 하나, 나이 하나.",
          "綁定：25 之後唔可以變 19。一個信封，一個年齡。"
        ),
      },
    },
  },

  {
    id = "bits",
    station = "BITS",
    name = L("Bit alley", "비트 골목", "Bit 小巷"),
    title = L(
      "Prove a RANGE, not a number",
      "숫자가 아니라 범위를 증명",
      "證明一個範圍，唔係一個數字"
    ),
    lesson = L(
      "age >= 18 is proven as 8 committed 0/1 bits of age - 18.",
      "age >= 18은 age - 18의 0/1 비트 8개를 커밋해서 증명한다.",
      "age >= 18 係用 age - 18 嘅 8 個已承諾 0/1 bit 嚟證明。"
    ),
    bg = "bg_bits",
    portrait = "portrait_hero",
    speaker = L("Alex (you)", "알렉스 (나)", "阿力 (你)"),
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {},
    viz = "bits",
    story = L(
      "age >= 18 becomes: age = 18 + delta and delta fits in 8 bits (0..255). "
        .. "Each bit gets its own commitment. A kid would need a negative delta, which has no bits.",
      "age >= 18은 이렇게 바뀝니다: age = 18 + delta, 그리고 delta는 8비트(0..255)에 들어간다. "
        .. "비트마다 커밋먼트 하나. 아이는 음수 delta가 필요한데, 음수에는 비트가 없습니다.",
      "age >= 18 變成：age = 18 + delta，而 delta 放得入 8 個 bit (0..255)。"
        .. "每個 bit 有自己嘅承諾。細路需要負數 delta，但負數冇 bit。"
    ),
    stages = {
      {
        topic = "RANGE",
        q = L(
          "Alex is 25 and T is 18. What is delta?",
          "알렉스는 25, T는 18. delta는?",
          "阿力 25 歲，T 係 18。delta 係幾多？"
        ),
        code = L(
          [[
# age = T + delta,   delta in [0, 255]
age   = 25          # age: secret, stays on YOUR phone
T     = 18          # T: public threshold
delta = age - T     # delta: how far above T (secret)
delta == ___
]],
          [[
# age = T + delta,   delta는 [0, 255] 안에
age   = 25          # age: 비밀, 네 폰에만
T     = 18          # T: 공개 기준
delta = age - T     # delta: T보다 얼마나 위인지 (비밀)
delta == ___
]],
          [[
# age = T + delta,   delta 喺 [0, 255] 入面
age   = 25          # age: 秘密，留喺你部電話
T     = 18          # T: 公開門檻
delta = age - T     # delta: 高過 T 幾多 (秘密)
delta == ___
]]
        ),
        accept = { "7" },
        answer = "7",
        hint = L("delta = age - T = 25 - 18.", "delta = age - T = 25 - 18.", "delta = age - T = 25 - 18。"),
        ok = L(
          "delta = 7. Uncle Wing sees 8 bit-envelopes, never the 7.",
          "delta = 7. 윙 아저씨는 비트 봉투 8개를 볼 뿐, 7은 못 봅니다.",
          "delta = 7。榮叔見到 8 個 bit 信封，永遠見唔到個 7。"
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "Write delta = 7 in binary (three bits are enough).",
          "delta = 7을 이진수로 쓰세요 (세 비트면 충분).",
          "將 delta = 7 寫成二進制（三個 bit 夠）。"
        ),
        code = L(
          [[
# delta = sum(b_i * 2^i)      b_i: bit i of delta, 0 or 1
# each bit is sealed on its own:
#   C_i = g^{b_i} * h^{r_i}    r_i: fresh blinding per bit
bits(7) = 0b___
]],
          [[
# delta = sum(b_i * 2^i)      b_i: delta의 i번째 비트, 0 또는 1
# 비트마다 따로 봉인:
#   C_i = g^{b_i} * h^{r_i}    r_i: 비트마다 새 블라인딩
bits(7) = 0b___
]],
          [[
# delta = sum(b_i * 2^i)      b_i: delta 嘅第 i 個 bit, 0 或 1
# 每個 bit 分開封:
#   C_i = g^{b_i} * h^{r_i}    r_i: 每個 bit 新嘅盲化
bits(7) = 0b___
]]
        ),
        accept = { "111", "00000111", "0b111", "0b00000111" },
        answer = "111",
        hint = L(
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0。"
        ),
        ok = L(
          "7 = 0b111. Eight OR-proofs show every lamp is really 0 or 1.",
          "7 = 0b111. OR 증명 8개가 모든 램프가 정말 0 또는 1임을 보입니다.",
          "7 = 0b111。八個 OR 證明顯示每盞燈真係 0 或 1。"
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "A 17-year-old tries. What is their delta? (this is why they fail)",
          "17살이 시도합니다. delta는? (이래서 실패합니다)",
          "一個 17 歲嘅試下。佢嘅 delta 係幾多？（呢個就係佢失敗嘅原因）"
        ),
        code = L(
          [[
# soundness: why 17 cannot pass a door of 18
age   = 17          # age: the kid's real number
T     = 18          # T: the door's threshold
delta = age - T     # delta must be an 8-bit unsigned number
delta == ___
]],
          [[
# 건전성: 17은 왜 18 문을 못 지나는가
age   = 17          # age: 아이의 실제 숫자
T     = 18          # T: 문의 기준
delta = age - T     # delta는 8비트 부호 없는 수여야 함
delta == ___
]],
          [[
# 可靠性: 點解 17 過唔到 18 嘅門
age   = 17          # age: 細路嘅真實數字
T     = 18          # T: 道門嘅門檻
delta = age - T     # delta 一定要係 8-bit 無符號數
delta == ___
]]
        ),
        accept = { "-1", "minus1", "negative1" },
        answer = "-1",
        hint = L(
          "17 - 18 is negative. Negative numbers have no 0/1 bit form.",
          "17 - 18은 음수. 음수는 0/1 비트 형태가 없습니다.",
          "17 - 18 係負數。負數冇 0/1 bit 嘅形式。"
        ),
        ok = L(
          "delta = -1 has no 8-bit form. No bits, no proof. Soundness.",
          "delta = -1은 8비트 형태가 없다. 비트가 없으면 증명도 없다. 건전성.",
          "delta = -1 冇 8-bit 形式。冇 bit，冇證明。可靠性。"
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "8 bits cover delta 0..255. What is the oldest age this proof can handle?",
          "8비트는 delta 0..255를 담습니다. 이 증명이 다룰 수 있는 최고 나이는?",
          "8 個 bit 覆蓋 delta 0..255。呢個證明處理到嘅最大年齡係幾多？"
        ),
        code = L(
          [[
# python/zkp/age.py
N_BITS    = 8        # n: bits of delta -> delta in [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: delta의 비트 수 -> delta는 [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: delta 嘅 bit 數 -> delta 喺 [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]]
        ),
        accept = { "273" },
        answer = "273",
        hint = L("18 + 255.", "18 + 255.", "18 + 255。"),
        ok = L(
          "18 + 255 = 273. The range is public too: [18, 273]. Only the position inside it is secret.",
          "18 + 255 = 273. 범위도 공개: [18, 273]. 그 안의 위치만 비밀.",
          "18 + 255 = 273。範圍都係公開嘅：[18, 273]。只有喺入面嘅位置係秘密。"
        ),
      },
    },
  },

  {
    id = "sigma",
    station = "SIGMA",
    name = L("Sigma club", "시그마 클럽", "Sigma 會所"),
    title = L("The three-move protocol", "3단계 프로토콜", "三步協議"),
    lesson = L(
      "t, c, s: the gate checks h^s = t * Y^c without x. Fiat-Shamir: c = SHA256(transcript).",
      "t, c, s: 게이트는 x 없이 h^s = t * Y^c를 검사한다. 피아트-샤미르: c = SHA256(transcript).",
      "t, c, s：閘口唔使 x 就檢查 h^s = t * Y^c。Fiat-Shamir：c = SHA256(transcript)。"
    ),
    bg = "bg_sigma",
    portrait = "portrait_hero",
    speaker = L("Sigma protocol", "시그마 프로토콜", "Sigma 協議"),
    ground = 348,
    spawn = 180,
    width = 1700,
    npcs = {
      {
        kind = "clerk",
        x = 980,
        facing = -1,
        line = L(
          "First you speak, then I speak, then you speak again.",
          "먼저 네가 말하고, 내가 말하고, 네가 다시 말한다.",
          "你先講，然後我講，然後你再講。"
        ),
      },
    },
    viz = "sigma",
    story = L(
      "A Sigma protocol is three moves: the prover announces t, the verifier challenges with c, "
        .. "the prover responds with s. Toy group here: p = 23, h = 2, q = 11.",
      "시그마 프로토콜은 세 번의 주고받기: 증명자가 t를 알리고, 검증자가 c로 도전하고, "
        .. "증명자가 s로 응답. 여기 장난감 군: p = 23, h = 2, q = 11.",
      "Sigma 協議係三步：證明者公佈 t，驗證者用 c 挑戰，證明者用 s 回應。"
        .. "呢度嘅玩具群：p = 23, h = 2, q = 11。"
    ),
    stages = {
      {
        topic = "PROVE",
        q = L(
          "Schnorr: t, then c, then ... what is the third message called?",
          "슈노르: t, 그다음 c, 그다음... 세 번째 메시지의 이름은?",
          "Schnorr：t，然後 c，然後……第三個訊息叫乜？"
        ),
        code = L(
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: secret    Y: public, = h^x    h: generator
# 1. Prover   ->  t = h^k        k: random, secret, one use
# 2. Verifier ->  c              c: random challenge
# 3. Prover   ->  ___ = k + c*x  response (mod q)
]],
          [[
# 시그마 (슈노르)   PoK{ x : Y = h^x }
# x: 비밀    Y: 공개, = h^x    h: 생성원
# 1. 증명자   ->  t = h^k        k: 무작위, 비밀, 일회용
# 2. 검증자   ->  c              c: 무작위 도전값
# 3. 증명자   ->  ___ = k + c*x  응답 (mod q)
]],
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: 秘密    Y: 公開, = h^x    h: 生成元
# 1. 證明者   ->  t = h^k        k: 隨機、秘密、用一次
# 2. 驗證者   ->  c              c: 隨機挑戰
# 3. 證明者   ->  ___ = k + c*x  回應 (mod q)
]]
        ),
        accept = { "s" },
        answer = "s",
        hint = L(
          "Announcement t, challenge c, response s. The secret x never ships.",
          "공표 t, 도전 c, 응답 s. 비밀 x는 절대 전송되지 않음.",
          "公佈 t，挑戰 c，回應 s。秘密 x 永遠唔會送出去。"
        ),
        ok = L(
          "s = k + c*x. The secret x is masked by the random k.",
          "s = k + c*x. 비밀 x는 무작위 k에 가려진다.",
          "s = k + c*x。秘密 x 俾隨機嘅 k 遮住。"
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Toy Schnorr: x = 5, k = 3, c = 2, q = 11. Compute s = (k + c*x) mod q.",
          "장난감 슈노르: x = 5, k = 3, c = 2, q = 11. s = (k + c*x) mod q를 계산하세요.",
          "玩具 Schnorr：x = 5, k = 3, c = 2, q = 11。計 s = (k + c*x) mod q。"
        ),
        code = L(
          [[
# toy: p = 23 modulus,  h = 2,  q = 11 (order of h)
x = 5            # x: secret         Y = 2^5 mod 23 = 9
k = 3            # k: random nonce   t = 2^3 mod 23 = 8
c = 2            # c: challenge
s = (k + c * x) % q  == ___     # s: response, mod q
]],
          [[
# 장난감: p = 23 모듈러스,  h = 2,  q = 11 (h의 위수)
x = 5            # x: 비밀            Y = 2^5 mod 23 = 9
k = 3            # k: 무작위 논스     t = 2^3 mod 23 = 8
c = 2            # c: 도전값
s = (k + c * x) % q  == ___     # s: 응답, mod q
]],
          [[
# 玩具: p = 23 模數,  h = 2,  q = 11 (h 嘅階)
x = 5            # x: 秘密           Y = 2^5 mod 23 = 9
k = 3            # k: 隨機 nonce     t = 2^3 mod 23 = 8
c = 2            # c: 挑戰
s = (k + c * x) % q  == ___     # s: 回應, mod q
]]
        ),
        accept = { "2" },
        answer = "2",
        hint = L(
          "3 + 2 * 5 = 13, and 13 mod 11 = 2.",
          "3 + 2 * 5 = 13, 그리고 13 mod 11 = 2.",
          "3 + 2 * 5 = 13，而 13 mod 11 = 2。"
        ),
        ok = L(
          "s = 2. Alex sends (t, s) = (8, 2). Not x.",
          "s = 2. 알렉스는 (t, s) = (8, 2)를 보냅니다. x는 아님.",
          "s = 2。阿力送出 (t, s) = (8, 2)。唔係 x。"
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Gate check: h^s == t * Y^c mod 23. Left is 2^2 = 4. Compute the right side 8 * 81 mod 23.",
          "게이트 검사: h^s == t * Y^c mod 23. 왼쪽은 2^2 = 4. 오른쪽 8 * 81 mod 23을 계산하세요.",
          "閘口檢查：h^s == t * Y^c mod 23。左邊係 2^2 = 4。計右邊 8 * 81 mod 23。"
        ),
        code = L(
          [[
# gate:  h^s  ==  t * Y^c   (mod 23)
# s: response   t: announcement   Y: public   c: challenge
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  the gate is convinced
]],
          [[
# 게이트:  h^s  ==  t * Y^c   (mod 23)
# s: 응답   t: 공표값   Y: 공개값   c: 도전값
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  게이트가 납득함
]],
          [[
# 閘口:  h^s  ==  t * Y^c   (mod 23)
# s: 回應   t: 公佈值   Y: 公開值   c: 挑戰
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  閘口信服
]]
        ),
        accept = { "4" },
        answer = "4",
        hint = L(
          "81 mod 23 = 12, so 8 * 12 = 96, and 96 = 4 * 23 + 4.",
          "81 mod 23 = 12, 그래서 8 * 12 = 96, 그리고 96 = 4 * 23 + 4.",
          "81 mod 23 = 12，所以 8 * 12 = 96，而 96 = 4 * 23 + 4。"
        ),
        ok = L(
          "4 == 4. The gate verified without ever touching x = 5.",
          "4 == 4. 게이트는 x = 5를 한 번도 건드리지 않고 검증했습니다.",
          "4 == 4。閘口完全冇掂過 x = 5 就驗證咗。"
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Ken has no x. He guesses s = 5. What is his left side 2^5 mod 23? (right side is still 4)",
          "켄은 x가 없습니다. s = 5로 찍습니다. 왼쪽 2^5 mod 23은? (오른쪽은 여전히 4)",
          "阿健冇 x。佢估 s = 5。佢嘅左邊 2^5 mod 23 係幾多？（右邊仍然係 4）"
        ),
        code = L(
          [[
# Ken does not know x. He guesses s = 5.
left  = 2^5 % 23  == ___     # h^s with the guessed s
right = 4                    # t * Y^c, unchanged
# left != right  ->  DENY
]],
          [[
# 켄은 x를 모른다. s = 5로 찍는다.
left  = 2^5 % 23  == ___     # 찍은 s로 계산한 h^s
right = 4                    # t * Y^c, 그대로
# left != right  ->  DENY
]],
          [[
# 阿健唔知 x。佢估 s = 5。
left  = 2^5 % 23  == ___     # 用估嘅 s 計嘅 h^s
right = 4                    # t * Y^c, 不變
# left != right  ->  DENY
]]
        ),
        accept = { "9" },
        answer = "9",
        hint = L("2^5 = 32, and 32 - 23 = 9.", "2^5 = 32, 그리고 32 - 23 = 9.", "2^5 = 32，而 32 - 23 = 9。"),
        ok = L(
          "9 != 4. DENY. A blind guess passes 1 time in q; real q is 256-bit.",
          "9 != 4. DENY. 마구 찍으면 q번에 1번 통과; 실제 q는 256비트.",
          "9 != 4。DENY。亂估 q 次先中 1 次；真正嘅 q 係 256-bit。"
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Fiat-Shamir: which hash function makes the challenge c in python/zkp?",
          "피아트-샤미르: python/zkp에서 도전값 c를 만드는 해시 함수는?",
          "Fiat-Shamir：python/zkp 入面用邊個 hash 函數整挑戰 c？"
        ),
        code = L(
          [[
# no back-and-forth: hash the transcript
# python/zkp/group.py  fiat_shamir
# transcript: the statement + every t     q: group order
c = ___(transcript) mod q    # c: challenge, now a hash
]],
          [[
# 주고받기 없음: 트랜스크립트를 해시
# python/zkp/group.py  fiat_shamir
# transcript: 명제 + 모든 t     q: 군의 위수
c = ___(transcript) mod q    # c: 도전값, 이제는 해시
]],
          [[
# 唔使來回: hash 成個 transcript
# python/zkp/group.py  fiat_shamir
# transcript: 命題 + 每一個 t     q: 群嘅階
c = ___(transcript) mod q    # c: 挑戰, 而家係一個 hash
]]
        ),
        accept = { "sha256", "sha-256", "sha2", "sha" },
        answer = "sha256",
        hint = L(
          "group.py uses hashlib.sha256 over the whole transcript.",
          "group.py는 전체 트랜스크립트에 hashlib.sha256을 씁니다.",
          "group.py 對成個 transcript 用 hashlib.sha256。"
        ),
        ok = L(
          "c = SHA256(transcript). Nobody can pick c after seeing t. Non-interactive, still sound.",
          "c = SHA256(transcript). t를 본 뒤에 c를 고를 수 없다. 비대화식이지만 여전히 건전.",
          "c = SHA256(transcript)。冇人可以睇完 t 先揀 c。非互動，仍然可靠。"
        ),
      },
    },
  },

  {
    id = "hash",
    station = "NONCE",
    name = L("Tonight's ticket", "오늘 밤의 티켓", "今晚嘅飛"),
    title = L("YOUR envelope, THIS conversation", "네 봉투, 이 대화", "你嘅信封，呢次對話"),
    lesson = L(
      "sk + the office's signature on (C, pk) + a fresh nonce bind the proof to Alex, tonight.",
      "sk + (C, pk)에 대한 발급소 서명 + 새 논스가 증명을 오늘 밤의 알렉스에게 묶는다.",
      "sk + 辦事處對 (C, pk) 嘅簽名 + 新鮮 nonce，將證明綁住今晚嘅阿力。"
    ),
    bg = "bg_hash",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔"),
    ground = 348,
    spawn = 200,
    width = 1650,
    npcs = {
      {
        kind = "clerk",
        x = 640,
        facing = 1,
        line = L(
          "New ticket every customer. Yesterday's JSON is trash.",
          "손님마다 새 티켓. 어제 JSON은 쓰레기야.",
          "每個客新一張飛。琴日嘅 JSON 係垃圾。"
        ),
      },
      {
        kind = "officer",
        x = 1100,
        facing = -1,
        line = L(
          "I signed (C, pk). Nobody else can mint this envelope.",
          "내가 (C, pk)에 서명했어. 이 봉투는 아무도 못 만들어.",
          "我簽咗 (C, pk)。冇其他人整到呢個信封。"
        ),
      },
    },
    viz = "hash",
    story = L(
      "Three things bind the proof to Alex: a holder key pair, the office's signature on (C, pk), "
        .. "and a fresh nonce from the gate mixed into the hash.",
      "세 가지가 증명을 알렉스에게 묶습니다: 소지자 키 쌍, (C, pk)에 대한 발급소 서명, "
        .. "그리고 해시에 섞인 게이트의 새 논스.",
      "三樣嘢將證明綁住阿力：持有人嘅一對鑰匙、辦事處對 (C, pk) 嘅簽名，"
        .. "同埋閘口俾嘅新鮮 nonce 混入 hash。"
    ),
    stages = {
      {
        topic = "BIND",
        q = L(
          "pk = g^? -- what is the holder's private key called?",
          "pk = g^? -- 소지자의 개인키 이름은?",
          "pk = g^? —— 持有人嘅私鑰叫乜？"
        ),
        code = L(
          [[
# python/zkp/identity.py  keygen
___ = random_scalar()     # private key, NEVER leaves the phone
pk  = pow(g, ___)         # pk: public key   g: generator
]],
          [[
# python/zkp/identity.py  keygen
___ = random_scalar()     # 개인키, 절대 폰을 떠나지 않음
pk  = pow(g, ___)         # pk: 공개키   g: 생성원
]],
          [[
# python/zkp/identity.py  keygen
___ = random_scalar()     # 私鑰, 永遠唔離開部電話
pk  = pow(g, ___)         # pk: 公鑰   g: 生成元
]]
        ),
        accept = { "sk" },
        answer = "sk",
        hint = L(
          "sk = secret key, pk = public key. pk = g^sk.",
          "sk = 비밀키, pk = 공개키. pk = g^sk.",
          "sk = 私鑰，pk = 公鑰。pk = g^sk。"
        ),
        ok = L(
          "pk = g^sk. A stolen envelope without sk cannot answer.",
          "pk = g^sk. sk 없이 훔친 봉투는 응답할 수 없다.",
          "pk = g^sk。偷咗信封但冇 sk，答唔到。"
        ),
      },
      {
        topic = "BIND",
        q = L(
          "The ID office signs two things together so the envelope belongs to one key. C and what?",
          "발급소는 봉투가 한 키에 속하도록 두 가지를 함께 서명합니다. C와 무엇?",
          "辦事處將兩樣嘢一齊簽名，令信封屬於一條鑰匙。C 同埋乜？"
        ),
        code = L(
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: the office's key
# C: the envelope    second item: whose key C belongs to
# the gate trusts office_pk, so a good sig means:
# "sealed by the office, for the owner of this key"
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: 발급소의 키
# C: 봉투    두 번째: 이 봉투가 누구 키의 것인지
# 게이트는 office_pk를 신뢰하므로 좋은 서명의 뜻은:
# "발급소가 봉인함, 이 키의 주인을 위해"
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: 辦事處嘅鑰匙
# C: 信封    第二項: 呢個信封屬於邊條鑰匙
# 閘口信任 office_pk, 所以一個好嘅簽名意思係:
# "辦事處封嘅, 俾呢條鑰匙嘅主人"
]]
        ),
        accept = { "pk", "publickey", "holderpk", "공개키", "公鑰" },
        answer = "pk",
        hint = L(
          "The public half of the holder's key pair.",
          "소지자 키 쌍의 공개된 절반.",
          "持有人鑰匙對入面公開嘅一半。"
        ),
        ok = L(
          "sig over (C, pk). A self-made envelope has no office signature: DENY at the door.",
          "(C, pk)에 대한 서명. 직접 만든 봉투에는 발급소 서명이 없다: 문 앞에서 DENY.",
          "對 (C, pk) 嘅簽名。自己整嘅信封冇辦事處簽名：喺門口 DENY。"
        ),
      },
      {
        topic = "BIND",
        q = L(
          "The gate gives every customer a fresh random ticket. What is it called?",
          "게이트는 손님마다 새 무작위 티켓을 줍니다. 그 이름은?",
          "閘口俾每個客一張新嘅隨機飛。佢叫乜？"
        ),
        code = L(
          [[
# fresh random ticket from the gate, one per check.
# mixed into the hash c so last night's
# JSON cannot be replayed.
proof.___ = gate_challenge   # gate_challenge: tonight's ticket
]],
          [[
# 게이트가 주는 새 무작위 티켓, 검사마다 하나.
# 해시 c에 섞여서 어젯밤
# JSON을 재사용할 수 없음.
proof.___ = gate_challenge   # gate_challenge: 오늘 밤 티켓
]],
          [[
# 閘口俾嘅新鮮隨機飛, 每次檢查一張.
# 混入 hash c, 所以尋晚嘅
# JSON 冇得重播.
proof.___ = gate_challenge   # gate_challenge: 今晚嘅飛
]]
        ),
        accept = { "nonce", "논스", "隨機數" },
        answer = "nonce",
        hint = L("A number used once: n-once.", "한 번만 쓰는 수: n-once.", "只用一次嘅數：n-once。"),
        ok = L(
          "c = SHA256(nonce, C, pk, ...). A proof answers exactly one ticket.",
          "c = SHA256(nonce, C, pk, ...). 증명은 정확히 티켓 하나에만 답한다.",
          "c = SHA256(nonce, C, pk, ...)。一個證明只答一張飛。"
        ),
      },
      {
        topic = "BIND",
        q = L(
          "Ken copies last night's proof JSON and shows it tonight. What does the gate print?",
          "켄이 어젯밤 증명 JSON을 복사해 오늘 밤 보여줍니다. 게이트는 뭐라고 찍나요?",
          "阿健複製尋晚嘅證明 JSON，今晚攞出嚟。閘口印乜？"
        ),
        code = L(
          [[
# last night:  ticket = "a1f3"   proof.nonce = "a1f3"
# tonight:     ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: the ticket the gate expects
# proof.nonce != nonce  ->  "___"
]],
          [[
# 어젯밤:  ticket = "a1f3"   proof.nonce = "a1f3"
# 오늘 밤: ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: 게이트가 기대하는 티켓
# proof.nonce != nonce  ->  "___"
]],
          [[
# 尋晚:  ticket = "a1f3"   proof.nonce = "a1f3"
# 今晚:  ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: 閘口期望嘅飛
# proof.nonce != nonce  ->  "___"
]]
        ),
        accept = { "deny", "denied", "reject", "rejected", "fail", "거부", "拒絕" },
        answer = "DENY",
        hint = L(
          "The red stamp. The proof answers a different conversation.",
          "빨간 도장. 증명이 다른 대화에 답하고 있음.",
          "紅色印。個證明答緊另一次對話。"
        ),
        ok = L(
          "DENY: challenge mismatch. Replay dies at the door.",
          "DENY: 도전값 불일치. 재사용은 문 앞에서 죽는다.",
          "DENY：挑戰唔對。重播喺門口死咗。"
        ),
      },
    },
  },

  {
    id = "beer",
    station = "BEER",
    name = L("The fridge", "냉장고", "雪櫃"),
    title = L("How verification works", "검증은 어떻게 이루어지나", "驗證點運作"),
    lesson = L(
      "Verify checks equations only. ADMIT reveals age >= 18 and nothing more.",
      "검증은 식만 확인한다. ADMIT은 age >= 18만 드러내고 그 이상은 없다.",
      "驗證只係檢查方程。ADMIT 只透露 age >= 18，冇其他。"
    ),
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = L("The gate", "게이트", "閘口"),
    ground = 348,
    spawn = 200,
    width = 1600,
    npcs = {
      {
        kind = "clerk",
        x = 500,
        facing = 1,
        line = L(
          "Threshold, nonce, signature, owner, consistency, bits...",
          "기준, 논스, 서명, 소유자, 일관성, 비트...",
          "門檻、nonce、簽名、持有人、一致性、bit……"
        ),
      },
      {
        kind = "mei",
        x = 720,
        facing = -1,
        line = L(
          "If this prints ADMIT I am buying spicy fish.",
          "ADMIT이 찍히면 내가 매운 어묵 살게.",
          "如果印 ADMIT，我請食辣魚蛋。"
        ),
      },
      {
        kind = "ken",
        x = 980,
        facing = -1,
        line = L(
          "He still does not know you are 25. Beautiful.",
          "아저씨는 아직도 네가 25인지 몰라. 아름답다.",
          "佢仲係唔知你 25 歲。正。"
        ),
      },
    },
    viz = "beer",
    story = L(
      "Verification never opens C. It only checks equations: threshold, nonce, issuer signature, "
        .. "owner key, bit consistency, every bit is 0 or 1. Then the stamp.",
      "검증은 C를 절대 열지 않습니다. 식만 확인합니다: 기준, 논스, 발급자 서명, "
        .. "소유자 키, 비트 일관성, 모든 비트가 0 또는 1. 그리고 도장.",
      "驗證永遠唔會打開 C。淨係檢查方程：門檻、nonce、發行者簽名、"
        .. "持有人鑰匙、bit 一致性、每個 bit 係 0 或 1。然後蓋印。"
    ),
    stages = {
      {
        topic = "VERIFY",
        q = L(
          "Cheap checks first. Before any math, which field of the proof is compared to the door's own 18?",
          "싼 검사부터. 수학 이전에, 증명의 어떤 필드가 문의 18과 비교되나요?",
          "平嘅檢查先。做任何數學之前，證明嘅邊個欄位同道門自己嘅 18 比較？"
        ),
        code = L(
          [[
# python/zkp/age.py  verify_adult  (in this order)
1. proof.___ == 18                  # the door's own policy T
2. proof.nonce == nonce             # this conversation's ticket
3. verify_sig(office_pk, (C, pk))   # C: envelope  pk: holder key
4. schnorr(pk, proof.owner, c)      # holder knows sk   c: hash
]],
          [[
# python/zkp/age.py  verify_adult  (이 순서로)
1. proof.___ == 18                  # 문 자체의 정책 T
2. proof.nonce == nonce             # 이 대화의 티켓
3. verify_sig(office_pk, (C, pk))   # C: 봉투  pk: 소지자 키
4. schnorr(pk, proof.owner, c)      # 소지자가 sk를 앎   c: 해시
]],
          [[
# python/zkp/age.py  verify_adult  (按呢個次序)
1. proof.___ == 18                  # 道門自己嘅政策 T
2. proof.nonce == nonce             # 呢次對話嘅飛
3. verify_sig(office_pk, (C, pk))   # C: 信封  pk: 持有人鑰匙
4. schnorr(pk, proof.owner, c)      # 持有人知道 sk   c: hash
]]
        ),
        accept = { "threshold", "t", "policy", "기준", "임계값", "門檻", "閾值" },
        answer = "threshold",
        hint = L(
          "A proof written for T = 16 dies at line 1 of a door of 18, before any exponentiation.",
          "T = 16용으로 쓴 증명은 18 문의 1번 줄에서, 어떤 거듭제곱 전에 죽는다.",
          "為 T = 16 寫嘅證明，喺 18 道門嘅第 1 行就死，未做任何冪運算。"
        ),
        ok = L(
          "Order: threshold, nonce, signature, owner, then consistency and bits. The JSON's T never overrides the door's.",
          "순서: 기준, 논스, 서명, 소유자, 그다음 일관성과 비트. JSON의 T는 절대 문의 T를 덮어쓰지 못한다.",
          "次序：門檻、nonce、簽名、持有人，然後一致性同 bit。JSON 嘅 T 永遠蓋唔過道門嘅。"
        ),
      },
      {
        topic = "VERIFY",
        q = L(
          "Mei flips one hex digit of C in the JSON. The office never signed that C. What does the gate print?",
          "메이가 JSON에서 C의 16진수 한 자리를 바꿉니다. 발급소는 그 C에 서명한 적이 없죠. 게이트는 뭐라고 찍나요?",
          "阿美改咗 JSON 入面 C 嘅一個十六進制數字。辦事處從來冇簽過嗰個 C。閘口印乜？"
        ),
        code = L(
          [[
# Mei edits C in the JSON:  "0x3a9..." -> "0x3b9..."
# check 3: verify_sig(office_pk, (C, pk))
# C: the envelope   office_pk: the office's public key
# the office signed the OLD C, not this one
verify(proof, nonce)  ->  "___"
]],
          [[
# 메이가 JSON의 C를 수정:  "0x3a9..." -> "0x3b9..."
# 검사 3: verify_sig(office_pk, (C, pk))
# C: 봉투   office_pk: 발급소의 공개키
# 발급소는 옛 C에 서명했지, 이 C가 아님
verify(proof, nonce)  ->  "___"
]],
          [[
# 阿美改咗 JSON 入面嘅 C:  "0x3a9..." -> "0x3b9..."
# 檢查 3: verify_sig(office_pk, (C, pk))
# C: 信封   office_pk: 辦事處嘅公鑰
# 辦事處簽嘅係舊 C, 唔係呢個
verify(proof, nonce)  ->  "___"
]]
        ),
        accept = { "deny", "denied", "reject", "rejected", "fail", "거부", "拒絕" },
        answer = "DENY",
        hint = L(
          "Same stamp as the replay. One wrong digit, signature dead.",
          "재사용 때와 같은 도장. 한 자리만 틀려도 서명은 죽는다.",
          "同重播一樣嘅印。錯一個數字，簽名就死。"
        ),
        ok = L(
          "DENY: issuer signature invalid. Every number in the proof is pinned by an equation.",
          "DENY: 발급자 서명 무효. 증명의 모든 숫자는 식으로 고정되어 있다.",
          "DENY：發行者簽名無效。證明入面每個數字都俾方程釘住。"
        ),
      },
      {
        topic = "VERIFY",
        q = L(
          "Alex's real proof, tonight's nonce. Every equation holds and he still does not know 25. Print?",
          "알렉스의 진짜 증명, 오늘 밤의 논스. 모든 식이 성립하고 그는 여전히 25를 모릅니다. 출력은?",
          "阿力嘅真證明，今晚嘅 nonce。每條方程成立，佢仍然唔知 25。印乜？"
        ),
        code = L(
          [[
    # D = C / (g^T * prod C_i^(2^i)): C with T and the bits
    # removed. Must be h^something, i.e. a commitment to 0.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 OR-proof
        assert bit_verify(C_i, bp, c)
    return "___"
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): C에서 T와 비트를
    # 제거한 것. h^무언가, 즉 0에 대한 커밋먼트여야 함.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 OR 증명
        assert bit_verify(C_i, bp, c)
    return "___"
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): C 除走 T 同啲 bit
    # 之後剩低嘅. 一定要係 h^某個數, 即係對 0 嘅承諾.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 OR 證明
        assert bit_verify(C_i, bp, c)
    return "___"
]]
        ),
        accept = { "admit", "accept", "ok", "pass", "통과", "허가", "通過", "准入" },
        answer = "ADMIT",
        hint = L(
          "The green stamp. Opposite of DENY.",
          "초록 도장. DENY의 반대.",
          "綠色印。DENY 嘅相反。"
        ),
        ok = L(
          "ADMIT. He learned age >= 18. He did not learn 25.",
          "ADMIT. 그는 age >= 18을 알았고, 25는 몰랐다.",
          "ADMIT。佢知道咗 age >= 18。佢冇知道 25。"
        ),
      },
    },
  },
}

return maps
