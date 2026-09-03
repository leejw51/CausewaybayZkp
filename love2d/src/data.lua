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
-- Text fields are L(...) tables in I18n.LANGS order; I18n.pick chooses one.
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

-- Argument order is fixed and matches I18n.LANGS. Every call passes all seven;
-- tests/test_flow.lua walks the data and fails if any language is missing.
local function L(en, ko, yue, zh, ja, cs, es)
  return { en = en, ko = ko, yue = yue, zh = zh, ja = ja, cs = cs, es = es }
end

local maps = {
  {
    id = "street",
    station = "STREET",
    name = L(
      "Percival Street",
      "퍼시벌 스트리트",
      "波斯富街",
      "波斯富街",
      "パーシヴァル・ストリート",
      "Percival Street",
      "Calle Percival"
    ),
    title = L(
      "The fact, not the number",
      "숫자가 아니라 사실",
      "係事實，唔係數字",
      "是事实，不是数字",
      "数字ではなく事実",
      "Fakt, ne číslo",
      "El hecho, no el número"
    ),
    lesson = L(
      "The gate needs one FACT (age >= 18), never the number.",
      "게이트에 필요한 건 사실 하나(age >= 18)뿐, 숫자는 절대 아니다.",
      "閘口只需要一個事實（age >= 18），永遠唔需要個數字。",
      "闸口只需要一个事实（age >= 18），永远不需要那个数字。",
      "ゲートに必要なのは事実ひとつ（age >= 18）だけ、数字ではない。",
      "Brána potřebuje jeden FAKT (age >= 18), nikdy ne číslo.",
      "La puerta necesita un HECHO (age >= 18), nunca el número."
    ),
    bg = "bg_street",
    portrait = "portrait_friends",
    speaker = L(
      "Mei + Ken",
      "메이 + 켄",
      "阿美 + 阿健",
      "阿美 + 阿健",
      "メイ + ケン",
      "Mei + Ken",
      "Mei + Ken"
    ),
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
          "阿力！！去買啤酒，幸運士多，快啲！",
          "阿力！！去买啤酒。幸运士多。快点！",
          "アレックス!! ビール調達。ラッキーマート。急げ！",
          "Alexi!! Jdeme pro pivo. Lucky Mart. Hejbni se.",
          "¡¡Alex!! Vamos por cerveza. Lucky Mart. ¡Muévete!"
        ),
      },
      {
        kind = "ken",
        x = 780,
        facing = -1,
        line = L(
          "Don't flash your ID. Uncle Wing gossips on the block.",
          "신분증 보여주지 마. 윙 아저씨는 동네 소문쟁이야.",
          "唔好晒你張身份證，榮叔成條街講是非㗎。",
          "别乱亮身份证。荣叔在这条街上最爱说闲话。",
          "身分証は見せるな。ウィンおじさんはこの辺の噂好きだぞ。",
          "Nemávej občankou. Strýc Wing roznese drby po celé ulici.",
          "No muestres tu identificación. El tío Wing es el chismoso de la cuadra."
        ),
      },
    },
    viz = "street",
    story = L(
      "Lucky Mart has ONE public rule: you must be an adult. Alex is 25. The goal tonight: prove "
        .. "the rule holds without ever saying 25.",
      "럭키 마트의 공개 규칙은 하나: 성인이어야 한다. 알렉스는 25살. 오늘 밤 목표: 25라는 숫자를 한 번도 말하지 않고 규칙을 만족함을 증명하기.",
      "幸運士多得一條公開規矩：一定要係成年人。阿力25歲。今晚嘅目標：由頭到尾唔講「25」，都證明到符合規矩。",
      "幸运士多只有一条公开规矩：必须是成年人。阿力25岁。今晚的目标：全程不说出 25，也证明规矩成立。",
      "ラッキーマートの公開ルールはひとつ：成人であること。アレックスは25歳。今夜の目標：25と一度も言わずにルールを満たすと証明すること。",
      "Lucky Mart má JEDNO veřejné pravidlo: musíš být dospělý. Alexovi je 25. Cíl na dnešní večer: "
        .. "dokázat, že pravidlo platí, a nikdy neříct 25.",
      "Lucky Mart tiene UNA regla pública: hay que ser adulto. Alex tiene 25. La meta de esta "
        .. "noche: probar que la regla se cumple sin decir nunca 25."
    ),
    stages = {
      {
        topic = "POLICY",
        q = L(
          "The rule is a comparison, not a number. Fill in the operator: prove age ___ T.",
          "규칙은 숫자가 아니라 비교입니다. 연산자를 채우세요: prove age ___ T.",
          "規矩係一個比較，唔係一個數字。填返個運算符：prove age ___ T。",
          "规矩是一个比较，不是一个数字。填上运算符：prove age ___ T。",
          "ルールは数字ではなく比較です。演算子を埋めてください：prove age ___ T.",
          "Pravidlo je porovnání, ne číslo. Doplň operátor: prove age ___ T.",
          "La regla es una comparación, no un número. Completa el operador: prove age ___ T."
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
]],
          [[
# 公开政策。不是秘密。
T   = 18                # T: 成年门槛，公开
age = 25                # age: 阿力的数字，秘密
prove:  age ___ T       # 闸口需要的事实
hide:   age             # 不能让它得到的秘密
]],
          [[
# 公開ポリシー。秘密ではない。
T   = 18                # T: 成人の基準、公開
age = 25                # age: アレックスの数字、秘密
prove:  age ___ T       # ゲートに必要な事実
hide:   age             # 絶対に渡してはいけない秘密
]],
          [[
# Veřejná politika, ne tajemství.
T   = 18                # T: práh dospělosti, veřejný
age = 25                # age: Alexovo číslo, tajné
prove:  age ___ T       # FAKT, který brána potřebuje
hide:   age             # TAJEMSTVÍ, které nesmí dostat
]],
          [[
# Política pública. No es secreto.
T   = 18                # T: umbral adulto, público
age = 25                # age: el número de Alex, secreto
prove:  age ___ T       # el HECHO que pide la puerta
hide:   age             # el SECRETO que no debe tener
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
          "大于等于",
          "以上",
          "větší nebo rovno",
          "mayor o igual",
        },
        answer = ">=",
        hint = L(
          "The fact is an inequality: at least 18. The exact number is the secret.",
          "사실은 부등식입니다: 18 이상. 정확한 숫자가 비밀입니다.",
          "事實係一個不等式：至少18。準確數字先係秘密。",
          "事实是一个不等式：至少18。确切的数字才是秘密。",
          "事実は不等式です：18以上。正確な数字が秘密です。",
          "Ten fakt je nerovnost: aspoň 18. Přesné číslo je tajemství.",
          "El hecho es una desigualdad: al menos 18. El número exacto es el secreto."
        ),
        ok = L(
          "Prove age >= T. T = 18 is public. 25 stays in Alex's pocket.",
          "age >= T를 증명. T = 18은 공개. 25는 알렉스 주머니에.",
          "證明 age >= T。T = 18 係公開。25 留喺阿力袋入面。",
          "证明 age >= T。T = 18 是公开的。25 留在阿力口袋里。",
          "age >= T を証明。T = 18 は公開。25 はアレックスのポケットの中。",
          "Dokaž age >= T. T = 18 je veřejné. 25 zůstane Alexovi v kapse.",
          "Prueba age >= T. T = 18 es público. El 25 se queda en el bolsillo de Alex."
        ),
      },
    },
  },

  {
    id = "mart",
    station = "MART",
    name = L(
      "Lucky Mart",
      "럭키 마트",
      "幸運士多",
      "幸运士多",
      "ラッキーマート",
      "Lucky Mart",
      "Lucky Mart"
    ),
    title = L(
      "What a ZKP promises",
      "ZKP가 약속하는 것",
      "ZKP 承諾啲乜",
      "ZKP 承诺什么",
      "ZKP が約束すること",
      "Co ZKP slibuje",
      "Lo que promete un ZKP"
    ),
    lesson = L(
      "Three promises: completeness, soundness, zero-knowledge.",
      "세 가지 약속: 완전성, 건전성, 영지식.",
      "三個承諾：完備性、可靠性、零知識。",
      "三个承诺：完备性、可靠性、零知识。",
      "三つの約束：完全性、健全性、ゼロ知識性。",
      "Tři sliby: úplnost, korektnost, nulová znalost.",
      "Tres promesas: completitud, solidez, conocimiento cero."
    ),
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔", "荣叔", "ウィンおじさん", "Strýc Wing", "Tío Wing"),
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
          "身份證。冇就冇啤酒。規矩唔係我定嘅，我淨係賣啤酒。",
          "身份证。没有就没啤酒。规矩不是我定的，我只卖啤酒。",
          "身分証。なければビールはなし。ルールを作ったのは俺じゃない、俺はビールを売るだけだ。",
          "Občanku. Nebo žádné pivo. Pravidla nedělám, já pivo prodávám.",
          "Identificación. O no hay cerveza. Yo no hago las reglas, yo vendo la cerveza."
        ),
      },
      {
        kind = "mei",
        x = 280,
        facing = 1,
        line = L(
          "Tell him it's a zero-knowledge proof. He'll love that.",
          "영지식 증명이라고 말해봐. 엄청 좋아할걸.",
          "同佢講呢個係零知識證明，佢實鍾意。",
          "跟他说这是零知识证明。他准喜欢。",
          "ゼロ知識証明だって言ってみな。きっと喜ぶよ。",
          "Řekni mu, že je to důkaz s nulovou znalostí. To se mu bude líbit.",
          "Dile que es una prueba de conocimiento cero. Le va a encantar."
        ),
      },
    },
    viz = "mart",
    story = L(
      "A zero-knowledge proof makes three promises. Completeness: an honest adult gets in. "
        .. "Soundness: a kid cannot fake it. Zero-knowledge: the clerk learns the FACT, not the SECRET.",
      "영지식 증명은 세 가지를 약속합니다. 완전성: 정직한 성인은 들어간다. 건전성: 아이는 속일 수 없다. 영지식: 점원은 사실만 알고 비밀은 모른다.",
      "零知識證明有三個承諾。完備性：誠實嘅成年人入到。可靠性：細路仔冇得呃。零知識：店員只知道事實，唔知道秘密。",
      "零知识证明有三个承诺。完备性：诚实的成年人进得去。可靠性：小孩伪造不了。零知识：店员知道的是事实，不是秘密。",
      "ゼロ知識証明は三つを約束します。完全性：正直な成人は通れる。健全性：子どもは偽れない。ゼロ知識性：店員は事実だけを知り、秘密は知らない。",
      "Důkaz s nulovou znalostí dává tři sliby. Úplnost: čestný dospělý projde. Korektnost: dítě to "
        .. "nepodvrhne. Nulová znalost: prodavač se dozví FAKT, ne TAJEMSTVÍ.",
      "Una prueba de conocimiento cero hace tres promesas. Completitud: un adulto honesto entra. "
        .. "Solidez: un niño no puede fingirla. Conocimiento cero: el vendedor aprende el HECHO, no el "
        .. "SECRETO."
    ),
    stages = {
      {
        topic = "ZKP",
        q = L(
          "Uncle Wing learns the fact. What number must he NEVER learn?",
          "윙 아저씨는 사실을 알게 됩니다. 절대 알면 안 되는 숫자는?",
          "榮叔知道咗事實。佢永遠唔可以知道邊個數字？",
          "荣叔知道了事实。他永远不能知道哪个数字？",
          "ウィンおじさんは事実を知ります。絶対に知ってはいけない数字は？",
          "Strýc Wing se dozví ten fakt. Které číslo se NIKDY dozvědět nesmí?",
          "El tío Wing aprende el hecho. ¿Qué número NUNCA debe saber?"
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
]],
          [[
# ZKP 的三个承诺
#   completeness  : 诚实的成年人 -> ADMIT
#   soundness     : age < T      -> DENY
#   zero-knowledge: 事实，不是秘密
learns       = "age >= 18"   # 事实   (T = 18)
never_learns = ___           # 秘密 (阿力的年龄)
]],
          [[
# ZKP の三つの約束
#   completeness  : 正直な成人 -> ADMIT
#   soundness     : age < T    -> DENY
#   zero-knowledge: 事実だけ、秘密は渡さない
learns       = "age >= 18"   # 事実   (T = 18)
never_learns = ___           # 秘密 (アレックスの年齢)
]],
          [[
# Tři sliby ZKP
#   úplnost       : čestný dospělý -> ADMIT
#   korektnost    : age < T        -> DENY
#   nulová znalost: FAKT, ne TAJEMSTVÍ
learns       = "age >= 18"   # fakt       (T = 18)
never_learns = ___           # tajemství  (Alexův věk)
]],
          [[
# Las tres promesas de un ZKP
#   completeness  : adulto honesto -> ADMIT
#   soundness     : age < T        -> DENY
#   zero-knowledge: HECHO, no SECRETO
learns       = "age >= 18"   # el hecho   (T = 18)
never_learns = ___           # el secreto (la edad de Alex)
]]
        ),
        accept = { "25" },
        answer = "25",
        hint = L(
          "Alex's real age is the secret. He learns age >= 18, never the number.",
          "알렉스의 실제 나이가 비밀입니다. 그는 age >= 18만 알고 숫자는 모릅니다.",
          "阿力嘅真實年齡係秘密。佢只知道 age >= 18，唔知道數字。",
          "阿力的真实年龄是秘密。他只知道 age >= 18，不知道数字。",
          "アレックスの実際の年齢が秘密です。彼は age >= 18 だけを知り、数字は知りません。",
          "Alexův skutečný věk je tajemství. Dozví se age >= 18, nikdy to číslo.",
          "La edad real de Alex es el secreto. Él aprende age >= 18, nunca el número."
        ),
        ok = L(
          "He learns age >= 18. He does not learn 25. That is zero knowledge.",
          "그는 age >= 18을 알고, 25는 모릅니다. 그게 영지식입니다.",
          "佢知道 age >= 18，唔知道 25。呢個就係零知識。",
          "他知道 age >= 18。他不知道 25。这就是零知识。",
          "彼は age >= 18 を知り、25 は知らない。それがゼロ知識性です。",
          "Dozví se age >= 18. Nedozví se 25. To je nulová znalost.",
          "Aprende age >= 18. No aprende 25. Eso es conocimiento cero."
        ),
      },
      {
        topic = "ZKP",
        q = L(
          "A 17-year-old tries to forge a proof and fails. Which promise is that?",
          "17살이 증명을 위조하려다 실패합니다. 어떤 약속인가요?",
          "一個17歲嘅試圖偽造證明，失敗咗。呢個係邊個承諾？",
          "一个17岁的人想伪造证明，失败了。这是哪个承诺？",
          "17歳が証明を偽造しようとして失敗します。どの約束ですか？",
          "Sedmnáctiletý zkusí zfalšovat důkaz a neuspěje. Který slib to je?",
          "Un chico de 17 intenta falsificar una prueba y falla. ¿Qué promesa es esa?"
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
]],
          [[
# 小孩 = 17，想伪造 age >= 18
# 证明验证不通过

promise = "___"
]],
          [[
# 子ども = 17、age >= 18 を偽ろうとする
# 証明は検証に通らない

promise = "___"
]],
          [[
# dítě = 17, zkouší předstírat age >= 18
# důkaz neprojde ověřením

promise = "___"
]],
          [[
# niño = 17, intenta fingir age >= 18
# la prueba no verifica

promise = "___"
]]
        ),
        accept = {
          "soundness",
          "sound",
          "건전성",
          "可靠性",
          "健全性",
          "穩固性",
          "稳固性",
          "korektnost",
          "solidez",
        },
        answer = "soundness",
        hint = L(
          "Completeness = honest adult passes. Soundness = a liar cannot pass.",
          "완전성 = 정직한 성인은 통과. 건전성 = 거짓말쟁이는 통과 불가.",
          "完備性 = 誠實成年人過到。可靠性 = 講大話嘅過唔到。",
          "完备性 = 诚实的成年人通过。可靠性 = 说谎的人通不过。",
          "完全性 = 正直な成人は通る。健全性 = 嘘つきは通れない。",
          "Úplnost = čestný dospělý projde. Korektnost = lhář neprojde.",
          "Completitud = el adulto honesto pasa. Solidez = un mentiroso no puede pasar."
        ),
        ok = L(
          "Soundness: no proof exists for a false statement.",
          "건전성: 거짓 명제에는 증명이 존재하지 않는다.",
          "可靠性：假嘅命題冇證明存在。",
          "可靠性：假的陈述没有证明存在。",
          "健全性：偽のステートメントには証明が存在しない。",
          "Korektnost: pro nepravdivé tvrzení žádný důkaz neexistuje.",
          "Solidez: no existe prueba para una declaración falsa."
        ),
      },
      {
        topic = "ZKP",
        q = L(
          "Alex is honest and holds (age, r) and sk. Every equation passes. Which promise is that?",
          "알렉스는 정직하고 (age, r)와 sk를 가지고 있습니다. 모든 식이 통과합니다. 어떤 약속인가요?",
          "阿力係誠實嘅，持有 (age, r) 同 sk。每條式都通過。呢個係邊個承諾？",
          "阿力是诚实的，持有 (age, r) 和 sk。每个等式都通过。这是哪个承诺？",
          "アレックスは正直で、(age, r) と sk を持っています。すべての式が通ります。どの約束ですか？",
          "Alex je čestný a má (age, r) a sk. Každá rovnice sedí. Který slib to je?",
          "Alex es honesto y tiene (age, r) y sk. Todas las ecuaciones pasan. ¿Qué promesa es esa?"
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
]],
          [[
# 阿力 = 25，持有 (age, r) 和 sk
# 运行 prove_adult -> 每个检查都通过 -> ADMIT

promise = "___"
]],
          [[
# アレックス = 25、(age, r) と sk を保持
# prove_adult を実行 -> 全チェック通過 -> ADMIT

promise = "___"
]],
          [[
# Alex = 25, má (age, r) a sk
# spustí prove_adult -> vše sedí -> ADMIT

promise = "___"
]],
          [[
# Alex = 25, tiene (age, r) y sk
# corre prove_adult -> todo pasa -> ADMIT

promise = "___"
]]
        ),
        accept = {
          "completeness",
          "complete",
          "완전성",
          "完備性",
          "完整性",
          "完备性",
          "完全性",
          "úplnost",
          "completitud",
        },
        answer = "completeness",
        hint = L(
          "The promise to the honest prover: the door always opens for the truth.",
          "정직한 증명자에 대한 약속: 진실 앞에서는 문이 항상 열린다.",
          "對誠實證明者嘅承諾：真相面前道門一定開。",
          "对诚实证明者的承诺：真话面前门一定开。",
          "正直な証明者への約束：真実の前では扉は必ず開く。",
          "Slib čestnému dokazovateli: pravdě se dveře otevřou vždycky.",
          "La promesa al probador honesto: la puerta siempre se abre ante la verdad."
        ),
        ok = L(
          "Completeness: a true statement with a real witness always verifies.",
          "완전성: 참인 명제와 진짜 증거는 항상 검증된다.",
          "完備性：真命題加真證據，一定驗證通過。",
          "完备性：真陈述加上真见证，一定验证通过。",
          "完全性：真のステートメントと本物のウィットネスは必ず検証に通る。",
          "Úplnost: pravdivé tvrzení s pravým svědkem se vždy ověří.",
          "Completitud: una declaración verdadera con un testigo real siempre verifica."
        ),
      },
    },
  },

  {
    id = "office",
    station = "OFFICE",
    name = L(
      "ID office",
      "신분증 발급소",
      "身份證辦事處",
      "身份证办事处",
      "身分証発行所",
      "Úřad dokladů",
      "Oficina de identidad"
    ),
    title = L(
      "Commitment = sealed envelope",
      "커밋먼트 = 봉인된 봉투",
      "承諾 = 封咗口嘅信封",
      "承诺 = 封好的信封",
      "コミットメント = 封をした封筒",
      "Závazek = zapečetěná obálka",
      "Compromiso = sobre sellado"
    ),
    lesson = L(
      "C = g^age * h^r hides the age and cannot be reopened as another.",
      "C = g^age * h^r는 나이를 숨기고, 다른 나이로 다시 열 수 없다.",
      "C = g^age * h^r 收埋年齡，而且唔可以當另一個年齡打開。",
      "C = g^age * h^r 藏起年龄，而且不能当成另一个年龄打开。",
      "C = g^age * h^r は年齢を隠し、別の年齢として開き直せない。",
      "C = g^age * h^r skryje věk a nejde otevřít jako jiný.",
      "C = g^age * h^r oculta la edad y no se puede reabrir como otra."
    ),
    bg = "bg_office",
    portrait = "portrait_officer",
    speaker = L("Ms. Chow", "초우 씨", "周小姐", "周小姐", "チョウ", "Paní Chowová", "Srta. Chow"),
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
          "我幫你封住你嘅年齡。間舖只會見到個信封。",
          "我把你的年龄封起来。店里只看到信封。",
          "あなたの年齢に封をします。店は封筒しか見ません。",
          "Zapečetím ti věk. Obchod uvidí jen obálku.",
          "Yo sello tu edad. La tienda solo ve el sobre."
        ),
      },
    },
    viz = "office",
    story = L(
      "The ID office seals the age in a Pedersen commitment C = g^age * h^r mod p. The envelope C "
        .. "is public. The opening (age, r) stays with Alex.",
      "발급소는 나이를 페더슨 커밋먼트 C = g^age * h^r mod p에 봉인합니다. 봉투 C는 공개. 열쇠 (age, r)는 알렉스가 가집니다.",
      "辦事處用 Pedersen 承諾 C = g^age * h^r mod p 封住年齡。信封 C 係公開嘅。開封資料 (age, r) 留喺阿力度。",
      "办事处用 Pedersen 承诺 C = g^age * h^r mod p 封住年龄。信封 C 是公开的。打开用的 (age, r) 留在阿力手上。",
      "発行所は年齢を Pedersen コミットメント C = g^age * h^r mod p に封じます。封筒 C は公開。開示情報 (age, r) はアレックスが持ちます。",
      "Úřad dokladů zapečetí věk do Pedersenova závazku C = g^age * h^r mod p. Obálka C je veřejná. "
        .. "Otevření (age, r) zůstane Alexovi.",
      "La oficina sella la edad en un compromiso Pedersen C = g^age * h^r mod p. El sobre C es "
        .. "público. La apertura (age, r) se queda con Alex."
    ),
    stages = {
      {
        topic = "COMMIT",
        q = L(
          "The office adds fresh randomness so C looks random. What is its name in the code?",
          "발급소는 C가 무작위로 보이도록 새 난수를 섞습니다. 코드에서 그 이름은?",
          "辦事處加入新嘅隨機數，令 C 睇落隨機。佢喺代碼入面叫乜名？",
          "办事处加入新的随机数，让 C 看起来随机。它在代码里叫什么名字？",
          "発行所は C がランダムに見えるよう新しい乱数を混ぜます。コードでの名前は？",
          "Úřad přidá čerstvou náhodu, aby C vypadalo náhodně. Jak se jmenuje v kódu?",
          "La oficina agrega aleatoriedad nueva para que C parezca aleatorio. ¿Cómo se llama en el código?"
        ),
        code = L(
          [[
# python/zkp/pedersen.py
# g, h: generators, 33-byte ints mod p (not a curve)
def issue(age):                   # age: the secret number
    r = random_scalar()           # r: blinding factor, secret
    C = pow(g, age) * pow(h, ___) # C: the sealed envelope
    holder_keeps = (age, r)       # the opening
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 생성원, 33바이트 정수 (타원곡선 아님)
def issue(age):                   # age: 비밀 숫자
    r = random_scalar()           # r: 블라인딩 인자, 비밀
    C = pow(g, age) * pow(h, ___) # C: 봉인된 봉투
    holder_keeps = (age, r)       # 열쇠
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 生成元, 33-byte 整數 (唔係橢圓曲線)
def issue(age):                   # age: 秘密數字
    r = random_scalar()           # r: 盲化因子，秘密
    C = pow(g, age) * pow(h, ___) # C: 封住嘅信封
    holder_keeps = (age, r)       # 開封資料
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 生成元，33-byte 整数 mod p（不是曲线）
def issue(age):                   # age: 秘密数字
    r = random_scalar()           # r: 盲化因子，秘密
    C = pow(g, age) * pow(h, ___) # C: 封好的信封
    holder_keeps = (age, r)       # 打开用的数据
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: 生成元、33バイト整数 mod p (楕円曲線ではない)
def issue(age):                   # age: 秘密の数字
    r = random_scalar()           # r: ブラインディング因子、秘密
    C = pow(g, age) * pow(h, ___) # C: 封をした封筒
    holder_keeps = (age, r)       # 開示情報
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: generátory, 33bajtová čísla mod p (ne křivka)
def issue(age):                   # age: tajné číslo
    r = random_scalar()           # r: zaslepovací faktor, tajný
    C = pow(g, age) * pow(h, ___) # C: zapečetěná obálka
    holder_keeps = (age, r)       # otevření
    world_sees   = C
]],
          [[
# python/zkp/pedersen.py
# g, h: generadores, enteros de 33 bytes mod p (no curva)
def issue(age):                   # age: el número secreto
    r = random_scalar()           # r: factor de cegado, secreto
    C = pow(g, age) * pow(h, ___) # C: el sobre sellado
    holder_keeps = (age, r)       # la apertura
    world_sees   = C
]]
        ),
        accept = { "r" },
        answer = "r",
        hint = L(
          "The blinding factor is called r. Without r, C = g^age would be guessable.",
          "블라인딩 인자의 이름은 r. r이 없으면 C = g^age는 추측 가능.",
          "盲化因子叫 r。冇咗 r，C = g^age 就估到。",
          "盲化因子叫 r。没有 r，C = g^age 就能猜到。",
          "ブラインディング因子の名前は r。r がなければ C = g^age は推測できてしまう。",
          "Zaslepovací faktor se jmenuje r. Bez r by šlo C = g^age uhodnout.",
          "El factor de cegado se llama r. Sin r, C = g^age sería adivinable."
        ),
        ok = L(
          "C = g^age * h^r. World sees C. Alex keeps (age, r).",
          "C = g^age * h^r. 세상은 C를 보고, 알렉스는 (age, r)를 갖는다.",
          "C = g^age * h^r。世界見到 C，阿力留住 (age, r)。",
          "C = g^age * h^r。世界看到 C。阿力留着 (age, r)。",
          "C = g^age * h^r。世界は C を見て、アレックスは (age, r) を持つ。",
          "C = g^age * h^r. Svět vidí C. Alex si nechá (age, r).",
          "C = g^age * h^r. El mundo ve C. Alex guarda (age, r)."
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Toy group p = 23, g = 2, h = 3. Seal age = 5 with r = 4: C = 9 * 12 mod 23 = ?",
          "장난감 군 p = 23, g = 2, h = 3. age = 5를 r = 4로 봉인: C = 9 * 12 mod 23 = ?",
          "玩具群 p = 23, g = 2, h = 3。用 r = 4 封住 age = 5：C = 9 * 12 mod 23 = ?",
          "玩具群 p = 23, g = 2, h = 3。用 r = 4 封住 age = 5：C = 9 * 12 mod 23 = ?",
          "おもちゃの群 p = 23, g = 2, h = 3。age = 5 を r = 4 で封じる：C = 9 * 12 mod 23 = ?",
          "Hračková grupa p = 23, g = 2, h = 3. Zapečeť age = 5 s r = 4: C = 9 * 12 mod 23 = ?",
          "Grupo de juguete p = 23, g = 2, h = 3. Sella age = 5 con r = 4: C = 9 * 12 mod 23 = ?"
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
]],
          [[
# 玩具: p = 23 模数,  g = 2 和 h = 3 生成元
age, r = 5, 4               # age: 秘密   r: 盲化
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: 荣叔看到的信封
]],
          [[
# おもちゃ: p = 23 は法,  g = 2 と h = 3 は生成元
age, r = 5, 4               # age: 秘密   r: ブラインディング
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: ウィンおじさんが見る封筒
]],
          [[
# hračka: p = 23 modul,  g = 2 a h = 3 generátory
age, r = 5, 4               # age: tajné   r: zaslepení
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: obálka, kterou vidí strýc Wing
]],
          [[
# juguete: p = 23 módulo,  g = 2 y h = 3 generadores
age, r = 5, 4               # age: secreto   r: cegado
pow(g, age) % p  == 9       # g^age: 2^5 = 32 = 9  (mod 23)
pow(h, r)   % p  == 12      # h^r:   3^4 = 81 = 12 (mod 23)
C = 9 * 12 % 23  == ___     # C: el sobre que ve el tío Wing
]]
        ),
        accept = { "16" },
        answer = "16",
        hint = L(
          "9 * 12 = 108, and 108 = 4 * 23 + 16.",
          "9 * 12 = 108, 그리고 108 = 4 * 23 + 16.",
          "9 * 12 = 108，而 108 = 4 * 23 + 16。",
          "9 * 12 = 108，而 108 = 4 * 23 + 16。",
          "9 * 12 = 108、そして 108 = 4 * 23 + 16。",
          "9 * 12 = 108 a 108 = 4 * 23 + 16.",
          "9 * 12 = 108, y 108 = 4 * 23 + 16."
        ),
        ok = L(
          "C = 16. Uncle Wing sees 16, not 5. Every age has some r that gives 16.",
          "C = 16. 윙 아저씨는 5가 아니라 16을 봅니다. 어떤 나이든 16이 되는 r이 있습니다.",
          "C = 16。榮叔見到 16，唔係 5。任何年齡都有某個 r 可以得出 16。",
          "C = 16。荣叔看到 16，不是 5。任何年龄都有某个 r 能得出 16。",
          "C = 16。ウィンおじさんが見るのは 5 ではなく 16。どの年齢にも 16 になる r があります。",
          "C = 16. Strýc Wing vidí 16, ne 5. Ke každému věku existuje r, které dá 16.",
          "C = 16. El tío Wing ve 16, no 5. Toda edad tiene algún r que da 16."
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Nobody can read 5 out of 16: for any age there is an r that fits. Which property is that?",
          "16에서 5를 읽어낼 수 없습니다: 어떤 나이에도 맞는 r이 있으니까요. 어떤 성질인가요?",
          "冇人可以由 16 讀返 5：任何年齡都有個啱嘅 r。呢個係咩性質？",
          "没人能从 16 读出 5：任何年龄都有一个合适的 r。这是什么性质？",
          "16 から 5 は読み取れません：どの年齢にも合う r があるからです。どの性質ですか？",
          "Z 16 nikdo nevyčte 5: ke každému věku sedí nějaké r. Která vlastnost to je?",
          "Nadie puede leer 5 a partir de 16: para cualquier edad hay un r que sirve. ¿Qué propiedad es esa?"
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
]],
          [[
# 承诺 C = g^age * h^r 的两个性质
#   ___     : C 不透露任何关于 age 的信息
#   binding : C 不能当成另一个 age 打开
# C: 信封 (公开)   age, r: 打开用的数据 (秘密)
property_one = "___"
]],
          [[
# コミットメント C = g^age * h^r の二つの性質
#   ___     : C は age について何も漏らさない
#   binding : C を別の age として開けない
# C: 封筒 (公開)   age, r: 開示情報 (秘密)
property_one = "___"
]],
          [[
# Dvě vlastnosti závazku C = g^age * h^r
#   ___     : C neprozradí o age vůbec nic
#   binding : C nejde otevřít jako jiné age
# C: obálka (veřejná)   age, r: otevření (tajné)
property_one = "___"
]],
          [[
# Dos propiedades de un compromiso C = g^age * h^r
#   ___     : C no revela nada sobre age
#   binding : C no se puede abrir como otra age
# C: sobre (público)   age, r: la apertura (secreto)
property_one = "___"
]]
        ),
        accept = {
          "hiding",
          "hide",
          "은닉",
          "은닉성",
          "숨김",
          "隱藏",
          "隱藏性",
          "隐藏",
          "隐藏性",
          "隠蔽",
          "隠蔽性",
          "skrývání",
          "ocultación",
        },
        answer = "hiding",
        hint = L(
          "Hiding = the envelope is opaque. Binding = the envelope cannot be swapped.",
          "은닉(hiding) = 봉투가 불투명. 구속(binding) = 봉투를 바꿔칠 수 없음.",
          "隱藏 (hiding) = 信封係不透明嘅。綁定 (binding) = 信封唔可以掉包。",
          "隐藏 (hiding) = 信封不透明。绑定 (binding) = 信封不能掉包。",
          "隠蔽 (hiding) = 封筒が不透明。束縛 (binding) = 封筒をすり替えられない。",
          "Skrývání (hiding) = obálka je neprůhledná. Vázanost (binding) = obálku nejde vyměnit.",
          "Hiding = el sobre es opaco. Binding = el sobre no se puede cambiar."
        ),
        ok = L(
          "Hiding: C is uniform whatever the age. Zero-knowledge starts here.",
          "은닉: 나이가 무엇이든 C는 균일 분포. 영지식은 여기서 시작.",
          "隱藏：無論年齡係幾多，C 都係均勻分佈。零知識由呢度開始。",
          "隐藏：不论年龄是多少，C 都是均匀的。零知识从这里开始。",
          "隠蔽：年齢が何であれ C は一様分布。ゼロ知識性はここから始まる。",
          "Skrývání: C je rovnoměrné, ať je věk jakýkoli. Tady začíná nulová znalost.",
          "Hiding: C es uniforme sea cual sea la edad. El conocimiento cero empieza aquí."
        ),
      },
      {
        topic = "COMMIT",
        q = L(
          "Alex later claims 16 was age 6. He would need log_g(h), which nobody knows. Which property " .. "stops him?",
          "알렉스가 나중에 16이 age 6이었다고 주장합니다. 아무도 모르는 log_g(h)가 필요하죠. 어떤 성질이 막나요?",
          "阿力事後話 16 其實係 age 6。佢需要冇人知嘅 log_g(h)。咩性質阻止佢？",
          "阿力事后说 16 其实是 age 6。他需要 log_g(h)，而没人知道它。什么性质挡住他？",
          "アレックスが後から 16 は age 6 だったと主張します。誰も知らない log_g(h) が必要です。どの性質が止めますか？",
          "Alex pak tvrdí, že 16 byl věk 6. Potřeboval by log_g(h), který nikdo nezná. Která vlastnost "
            .. "ho zastaví?",
          "Alex dice después que 16 era age 6. Necesitaría log_g(h), que nadie conoce. ¿Qué propiedad "
            .. "lo detiene?"
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
]],
          [[
# 阿力声称 C = 16 打开是 age = 6:
#   需要 r' 使 2^6 * 3^r' = 16 (mod 23)   r': 新的盲化
#   两个打开  =>  等于知道 log_g(h)    (h = g^x, x 已知)
# g 和 h 是 hash 到群里的: 没人知道那个 x。
property_two = "___"
]],
          [[
# アレックスは C = 16 が age = 6 で開くと主張:
#   2^6 * 3^r' = 16 (mod 23) となる r' が必要   r': 新しいブラインディング
#   開示が二つ  =>  log_g(h) を知っている   (h = g^x, x を知る)
# g と h はハッシュから作った生成元: その x は誰も知らない。
property_two = "___"
]],
          [[
# Alex tvrdí: C = 16 se otevře jako age = 6:
#   nutné r' s 2^6 * 3^r' = 16 (mod 23)   r': nové zaslepení
#   dvě otevření  =>  log_g(h) je známý    (h = g^x, x známé)
# g a h vznikly hašováním: to x nikdo nezná.
property_two = "___"
]],
          [[
# Alex dice que C = 16 abre como age = 6:
#   necesita r' con 2^6 * 3^r' = 16 (mod 23)   r': cegado nuevo
#   dos aperturas  =>  se conoce log_g(h)   (h = g^x, x conocido)
# g y h salen de un hash: nadie conoce esa x.
property_two = "___"
]]
        ),
        accept = {
          "binding",
          "bind",
          "구속",
          "구속성",
          "바인딩",
          "綁定",
          "約束",
          "绑定",
          "约束",
          "束縛",
          "拘束",
          "vázanost",
          "vinculación",
        },
        answer = "binding",
        hint = L(
          "Hiding you already typed. The other property: the seal cannot be re-opened differently.",
          "은닉은 이미 입력했죠. 다른 성질: 봉인을 다르게 다시 열 수 없다.",
          "隱藏你已經打咗。另一個性質：封印唔可以用另一種方式重開。",
          "隐藏你已经输入过了。另一个性质：封印不能用另一种方式打开。",
          "隠蔽はもう入力しましたね。もうひとつの性質：封印を別の形で開き直せない。",
          "Skrývání jsi už napsal. Ta druhá vlastnost: pečeť nejde otevřít jinak.",
          "Hiding ya lo escribiste. La otra propiedad: el sello no se puede reabrir de otra forma."
        ),
        ok = L(
          "Binding: 25 cannot become 19 later. One envelope, one age.",
          "구속: 25가 나중에 19가 될 수 없다. 봉투 하나, 나이 하나.",
          "綁定：25 之後唔可以變 19。一個信封，一個年齡。",
          "绑定：25 以后不能变成 19。一个信封，一个年龄。",
          "束縛：25 が後から 19 にはなれない。封筒ひとつ、年齢ひとつ。",
          "Vázanost: z 25 se později nestane 19. Jedna obálka, jeden věk.",
          "Binding: 25 no puede volverse 19 después. Un sobre, una edad."
        ),
      },
    },
  },

  {
    id = "bits",
    station = "BITS",
    name = L(
      "Bit alley",
      "비트 골목",
      "Bit 小巷",
      "Bit 小巷",
      "ビット横丁",
      "Bitová ulička",
      "Callejón de bits"
    ),
    title = L(
      "Prove a RANGE, not a number",
      "숫자가 아니라 범위를 증명",
      "證明一個範圍，唔係一個數字",
      "证明一个范围，不是一个数字",
      "数字ではなく範囲を証明",
      "Dokaž ROZSAH, ne číslo",
      "Prueba un RANGO, no un número"
    ),
    lesson = L(
      "age >= 18 is proven as 8 committed 0/1 bits of age - 18.",
      "age >= 18은 age - 18의 0/1 비트 8개를 커밋해서 증명한다.",
      "age >= 18 係用 age - 18 嘅 8 個已承諾 0/1 bit 嚟證明。",
      "age >= 18 是用 age - 18 的 8 个已承诺 0/1 bit 来证明的。",
      "age >= 18 は age - 18 の 0/1 ビット8個をコミットして証明する。",
      "age >= 18 se dokáže jako 8 zavázaných 0/1 bitů čísla age - 18.",
      "age >= 18 se prueba con 8 bits 0/1 comprometidos de age - 18."
    ),
    bg = "bg_bits",
    portrait = "portrait_hero",
    speaker = L(
      "Alex (you)",
      "알렉스 (나)",
      "阿力 (你)",
      "阿力 (你)",
      "アレックス (あなた)",
      "Alex (ty)",
      "Alex (tú)"
    ),
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {},
    viz = "bits",
    story = L(
      "age >= 18 becomes: age = 18 + delta and delta fits in 8 bits (0..255). Each bit gets its own "
        .. "commitment. A kid would need a negative delta, which has no bits.",
      "age >= 18은 이렇게 바뀝니다: age = 18 + delta, 그리고 delta는 8비트(0..255)에 들어간다. 비트마다 커밋먼트 하나. 아이는 음수 "
        .. "delta가 필요한데, 음수에는 비트가 없습니다.",
      "age >= 18 變成：age = 18 + delta，而 delta 放得入 8 個 bit (0..255)。每個 bit 有自己嘅承諾。細路需要負數 delta，但負數冇 bit。",
      "age >= 18 变成：age = 18 + delta，而 delta 装得进 8 个 bit (0..255)。每个 bit 有自己的承诺。小孩需要负的 delta，而负数没有 bit。",
      "age >= 18 はこうなります：age = 18 + delta、そして delta は8ビット (0..255) に収まる。ビットごとに自分のコミットメント。子どもには負の "
        .. "delta が必要ですが、負の数にビットはありません。",
      "Z age >= 18 se stane: age = 18 + delta a delta se vejde do 8 bitů (0..255). Každý bit má "
        .. "vlastní závazek. Dítě by potřebovalo záporné delta, a to bity nemá.",
      "age >= 18 se vuelve: age = 18 + delta y delta cabe en 8 bits (0..255). Cada bit tiene su "
        .. "propio compromiso. Un niño necesitaría un delta negativo, y eso no tiene bits."
    ),
    stages = {
      {
        topic = "RANGE",
        q = L(
          "Alex is 25 and T is 18. What is delta?",
          "알렉스는 25, T는 18. delta는?",
          "阿力 25 歲，T 係 18。delta 係幾多？",
          "阿力 25 岁，T 是 18。delta 是多少？",
          "アレックスは25歳、T は18。delta は？",
          "Alexovi je 25 a T je 18. Kolik je delta?",
          "Alex tiene 25 y T es 18. ¿Cuánto vale delta?"
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
]],
          [[
# age = T + delta,   delta 在 [0, 255] 内
age   = 25          # age: 秘密，留在你的手机上
T     = 18          # T: 公开门槛
delta = age - T     # delta: 高出 T 多少 (秘密)
delta == ___
]],
          [[
# age = T + delta,   delta は [0, 255] の中
age   = 25          # age: 秘密、君のスマホの中だけ
T     = 18          # T: 公開の基準
delta = age - T     # delta: T よりどれだけ上か (秘密)
delta == ___
]],
          [[
# age = T + delta,   delta v [0, 255]
age   = 25          # age: tajné, zůstane v TVÉM mobilu
T     = 18          # T: veřejný práh
delta = age - T     # delta: o kolik nad T (tajné)
delta == ___
]],
          [[
# age = T + delta,   delta en [0, 255]
age   = 25          # age: secreto, vive en TU teléfono
T     = 18          # T: umbral público
delta = age - T     # delta: cuánto arriba de T (secreto)
delta == ___
]]
        ),
        accept = { "7" },
        answer = "7",
        hint = L(
          "delta = age - T = 25 - 18.",
          "delta = age - T = 25 - 18.",
          "delta = age - T = 25 - 18。",
          "delta = age - T = 25 - 18。",
          "delta = age - T = 25 - 18.",
          "delta = age - T = 25 - 18.",
          "delta = age - T = 25 - 18."
        ),
        ok = L(
          "delta = 7. Uncle Wing sees 8 bit-envelopes, never the 7.",
          "delta = 7. 윙 아저씨는 비트 봉투 8개를 볼 뿐, 7은 못 봅니다.",
          "delta = 7。榮叔見到 8 個 bit 信封，永遠見唔到個 7。",
          "delta = 7。荣叔看到 8 个 bit 信封，永远看不到那个 7。",
          "delta = 7。ウィンおじさんが見るのはビットの封筒8個、7 は見えません。",
          "delta = 7. Strýc Wing vidí 8 bitových obálek, nikdy tu sedmičku.",
          "delta = 7. El tío Wing ve 8 sobres de bits, nunca el 7."
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "Write delta = 7 in binary (three bits are enough).",
          "delta = 7을 이진수로 쓰세요 (세 비트면 충분).",
          "將 delta = 7 寫成二進制（三個 bit 夠）。",
          "把 delta = 7 写成二进制（三个 bit 就够）。",
          "delta = 7 を二進数で書いてください (3ビットで足ります)。",
          "Zapiš delta = 7 dvojkově (tři bity stačí).",
          "Escribe delta = 7 en binario (con tres bits basta)."
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
]],
          [[
# delta = sum(b_i * 2^i)      b_i: delta 的第 i 个 bit, 0 或 1
# 每个 bit 单独封好:
#   C_i = g^{b_i} * h^{r_i}    r_i: 每个 bit 新的盲化
bits(7) = 0b___
]],
          [[
# delta = sum(b_i * 2^i)      b_i: delta の第 i ビット、0 か 1
# ビットごとに別々に封をする:
#   C_i = g^{b_i} * h^{r_i}    r_i: ビットごとに新しいブラインディング
bits(7) = 0b___
]],
          [[
# delta = sum(b_i * 2^i)      b_i: i-tý bit delty, 0 nebo 1
# každý bit se pečetí zvlášť:
#   C_i = g^{b_i} * h^{r_i}    r_i: nové zaslepení pro bit
bits(7) = 0b___
]],
          [[
# delta = sum(b_i * 2^i)      b_i: bit i de delta, 0 o 1
# cada bit se sella por separado:
#   C_i = g^{b_i} * h^{r_i}    r_i: cegado nuevo por bit
bits(7) = 0b___
]]
        ),
        accept = { "111", "00000111", "0b111", "0b00000111" },
        answer = "111",
        hint = L(
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0。",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0。",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0.",
          "7 = 4 + 2 + 1 = 2^2 + 2^1 + 2^0."
        ),
        ok = L(
          "7 = 0b111. Eight OR-proofs show every lamp is really 0 or 1.",
          "7 = 0b111. OR 증명 8개가 모든 램프가 정말 0 또는 1임을 보입니다.",
          "7 = 0b111。八個 OR 證明顯示每盞燈真係 0 或 1。",
          "7 = 0b111。八个 OR 证明表明每盏灯真的是 0 或 1。",
          "7 = 0b111。OR証明8個が、どのランプも本当に 0 か 1 だと示します。",
          "7 = 0b111. Osm OR-důkazů ukáže, že každá žárovka je opravdu 0 nebo 1.",
          "7 = 0b111. Ocho pruebas OR muestran que cada lámpara es 0 o 1."
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "A 17-year-old tries. What is their delta? (this is why they fail)",
          "17살이 시도합니다. delta는? (이래서 실패합니다)",
          "一個 17 歲嘅試下。佢嘅 delta 係幾多？（呢個就係佢失敗嘅原因）",
          "一个 17 岁的人来试。他的 delta 是多少？（这就是他失败的原因）",
          "17歳が試します。その delta は？（これが失敗する理由）",
          "Zkusí to sedmnáctiletý. Kolik je jeho delta? (proto neuspěje)",
          "Un chico de 17 lo intenta. ¿Cuál es su delta? (por esto falla)"
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
]],
          [[
# 可靠性: 为什么 17 过不了 18 的门
age   = 17          # age: 小孩的真实数字
T     = 18          # T: 门的门槛
delta = age - T     # delta 必须是 8-bit 无符号数
delta == ___
]],
          [[
# 健全性: 17 が 18 の扉を通れない理由
age   = 17          # age: 子どもの本当の数字
T     = 18          # T: 扉の基準
delta = age - T     # delta は8ビットの符号なし数でなければならない
delta == ___
]],
          [[
# korektnost: proč 17 neprojde dveřmi s 18
age   = 17          # age: skutečné číslo dítěte
T     = 18          # T: práh dveří
delta = age - T     # delta musí být 8bitové bez znaménka
delta == ___
]],
          [[
# solidez: por qué 17 no pasa una puerta de 18
age   = 17          # age: el número real del niño
T     = 18          # T: el umbral de la puerta
delta = age - T     # delta debe ser un entero de 8 bits sin signo
delta == ___
]]
        ),
        accept = { "-1", "minus1", "negative1" },
        answer = "-1",
        hint = L(
          "17 - 18 is negative. Negative numbers have no 0/1 bit form.",
          "17 - 18은 음수. 음수는 0/1 비트 형태가 없습니다.",
          "17 - 18 係負數。負數冇 0/1 bit 嘅形式。",
          "17 - 18 是负数。负数没有 0/1 bit 形式。",
          "17 - 18 は負の数。負の数に 0/1 ビットの形はありません。",
          "17 - 18 je záporné. Záporná čísla nemají tvar z 0/1 bitů.",
          "17 - 18 es negativo. Los negativos no tienen forma de bits 0/1."
        ),
        ok = L(
          "delta = -1 has no 8-bit form. No bits, no proof. Soundness.",
          "delta = -1은 8비트 형태가 없다. 비트가 없으면 증명도 없다. 건전성.",
          "delta = -1 冇 8-bit 形式。冇 bit，冇證明。可靠性。",
          "delta = -1 没有 8-bit 形式。没有 bit，就没有证明。可靠性。",
          "delta = -1 に8ビットの形はない。ビットがなければ証明もない。健全性。",
          "delta = -1 nemá osmibitový tvar. Bez bitů není důkaz. Korektnost.",
          "delta = -1 no tiene forma de 8 bits. Sin bits, sin prueba. Solidez."
        ),
      },
      {
        topic = "RANGE",
        q = L(
          "8 bits cover delta 0..255. What is the oldest age this proof can handle?",
          "8비트는 delta 0..255를 담습니다. 이 증명이 다룰 수 있는 최고 나이는?",
          "8 個 bit 覆蓋 delta 0..255。呢個證明處理到嘅最大年齡係幾多？",
          "8 个 bit 覆盖 delta 0..255。这个证明能处理的最大年龄是多少？",
          "8ビットは delta 0..255 をカバーします。この証明が扱える最高年齢は？",
          "8 bitů pokryje delta 0..255. Jaký nejvyšší věk tenhle důkaz zvládne?",
          "8 bits cubren delta 0..255. ¿Cuál es la edad máxima que maneja esta prueba?"
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
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: delta 的 bit 数 -> delta 在 [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: delta のビット数 -> delta は [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: bity delty -> delta v [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]],
          [[
# python/zkp/age.py
N_BITS    = 8        # n: bits de delta -> delta en [0, 2^n - 1]
ADULT_AGE = 18       # T
MAX_AGE   = ADULT_AGE + (1 << N_BITS) - 1     # T + 2^n - 1
MAX_AGE == ___
]]
        ),
        accept = { "273" },
        answer = "273",
        hint = L("18 + 255.", "18 + 255.", "18 + 255。", "18 + 255。", "18 + 255.", "18 + 255.", "18 + 255."),
        ok = L(
          "18 + 255 = 273. The range is public too: [18, 273]. Only the position inside it is secret.",
          "18 + 255 = 273. 범위도 공개: [18, 273]. 그 안의 위치만 비밀.",
          "18 + 255 = 273。範圍都係公開嘅：[18, 273]。只有喺入面嘅位置係秘密。",
          "18 + 255 = 273。范围也是公开的：[18, 273]。只有在里面的位置是秘密。",
          "18 + 255 = 273。範囲も公開：[18, 273]。その中のどこにいるかだけが秘密。",
          "18 + 255 = 273. I rozsah je veřejný: [18, 273]. Tajná je jen pozice v něm.",
          "18 + 255 = 273. El rango también es público: [18, 273]. Solo la posición dentro de él es secreta."
        ),
      },
    },
  },

  {
    id = "sigma",
    station = "SIGMA",
    name = L(
      "Sigma club",
      "시그마 클럽",
      "Sigma 會所",
      "Sigma 会所",
      "シグマクラブ",
      "Klub Sigma",
      "Club Sigma"
    ),
    title = L(
      "The three-move protocol",
      "3단계 프로토콜",
      "三步協議",
      "三步协议",
      "三手のプロトコル",
      "Protokol o třech tazích",
      "El protocolo de tres pasos"
    ),
    lesson = L(
      "t, c, s: the gate checks h^s = t * Y^c without x. Fiat-Shamir: c = SHA256(transcript).",
      "t, c, s: 게이트는 x 없이 h^s = t * Y^c를 검사한다. 피아트-샤미르: c = SHA256(transcript).",
      "t, c, s：閘口唔使 x 就檢查 h^s = t * Y^c。Fiat-Shamir：c = SHA256(transcript)。",
      "t, c, s：闸口不用 x 就能检查 h^s = t * Y^c。Fiat-Shamir：c = SHA256(transcript)。",
      "t, c, s：ゲートは x なしで h^s = t * Y^c を確かめる。Fiat-Shamir：c = SHA256(transcript).",
      "t, c, s: brána ověří h^s = t * Y^c bez x. Fiat-Shamir: c = SHA256(transcript).",
      "t, c, s: la puerta revisa h^s = t * Y^c sin x. Fiat-Shamir: c = SHA256(transcript)."
    ),
    bg = "bg_sigma",
    portrait = "portrait_hero",
    speaker = L(
      "Sigma protocol",
      "시그마 프로토콜",
      "Sigma 協議",
      "Sigma 协议",
      "シグマプロトコル",
      "Sigma protokol",
      "Protocolo Sigma"
    ),
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
          "你先講，然後我講，然後你再講。",
          "你先说，然后我说，然后你再说。",
          "まず君が話し、次に俺が話し、また君が話す。",
          "Nejdřív mluvíš ty, pak já, pak zase ty.",
          "Primero hablas tú, luego hablo yo, luego hablas tú otra vez."
        ),
      },
    },
    viz = "sigma",
    story = L(
      "A Sigma protocol is three moves: the prover announces t, the verifier challenges with c, the "
        .. "prover responds with s. Toy group here: p = 23, h = 2, q = 11.",
      "시그마 프로토콜은 세 번의 주고받기: 증명자가 t를 알리고, 검증자가 c로 도전하고, 증명자가 s로 응답. 여기 장난감 군: p = 23, h = 2, q = 11.",
      "Sigma 協議係三步：證明者公佈 t，驗證者用 c 挑戰，證明者用 s 回應。呢度嘅玩具群：p = 23, h = 2, q = 11。",
      "Sigma 协议是三步：证明者公布 t，验证者用 c 挑战，证明者用 s 响应。这里的玩具群：p = 23, h = 2, q = 11。",
      "シグマプロトコルは三手：証明者が t を告げ、検証者が c でチャレンジし、証明者が s で応じる。ここでのおもちゃの群：p = 23, h = 2, q = 11.",
      "Sigma protokol má tři tahy: dokazovatel ohlásí t, ověřovatel vyzve pomocí c, dokazovatel "
        .. "odpoví s. Hračková grupa: p = 23, h = 2, q = 11.",
      "Un protocolo Sigma son tres pasos: el probador anuncia t, el verificador desafía con c, el "
        .. "probador responde con s. Grupo de juguete: p = 23, h = 2, q = 11."
    ),
    stages = {
      {
        topic = "PROVE",
        q = L(
          "Schnorr: t, then c, then ... what is the third message called?",
          "슈노르: t, 그다음 c, 그다음... 세 번째 메시지의 이름은?",
          "Schnorr：t，然後 c，然後……第三個訊息叫乜？",
          "Schnorr：t，然后 c，然后……第三条消息叫什么？",
          "Schnorr：t、次に c、次に… 三つ目のメッセージの名前は？",
          "Schnorr: t, pak c, pak ... jak se jmenuje třetí zpráva?",
          "Schnorr: t, luego c, luego... ¿cómo se llama el tercer mensaje?"
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
]],
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: 秘密    Y: 公开, = h^x    h: 生成元
# 1. 证明者   ->  t = h^k        k: 随机、秘密、只用一次
# 2. 验证者   ->  c              c: 随机挑战
# 3. 证明者   ->  ___ = k + c*x  响应 (mod q)
]],
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: 秘密    Y: 公開, = h^x    h: 生成元
# 1. 証明者   ->  t = h^k        k: 乱数、秘密、一度きり
# 2. 検証者   ->  c              c: ランダムなチャレンジ
# 3. 証明者   ->  ___ = k + c*x  レスポンス (mod q)
]],
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: tajné    Y: veřejné, = h^x    h: generátor
# 1. Dokazovatel ->  t = h^k        k: náhodné, tajné, na 1x
# 2. Ověřovatel  ->  c              c: náhodná výzva
# 3. Dokazovatel ->  ___ = k + c*x  odpověď (mod q)
]],
          [[
# Sigma (Schnorr)   PoK{ x : Y = h^x }
# x: secreto    Y: público, = h^x    h: generador
# 1. Probador    ->  t = h^k        k: azar, secreto, un uso
# 2. Verificador ->  c              c: desafío al azar
# 3. Probador    ->  ___ = k + c*x  respuesta (mod q)
]]
        ),
        accept = { "s" },
        answer = "s",
        hint = L(
          "Announcement t, challenge c, response s. The secret x never ships.",
          "공표 t, 도전 c, 응답 s. 비밀 x는 절대 전송되지 않음.",
          "公佈 t，挑戰 c，回應 s。秘密 x 永遠唔會送出去。",
          "公布 t，挑战 c，响应 s。秘密 x 从不发出去。",
          "公表 t、チャレンジ c、レスポンス s。秘密の x は決して送られない。",
          "Ohlášení t, výzva c, odpověď s. Tajné x se nikdy neposílá.",
          "Anuncio t, desafío c, respuesta s. El secreto x nunca se envía."
        ),
        ok = L(
          "s = k + c*x. The secret x is masked by the random k.",
          "s = k + c*x. 비밀 x는 무작위 k에 가려진다.",
          "s = k + c*x。秘密 x 俾隨機嘅 k 遮住。",
          "s = k + c*x。秘密 x 被随机的 k 遮住。",
          "s = k + c*x。秘密の x は乱数 k に覆われる。",
          "s = k + c*x. Tajné x maskuje náhodné k.",
          "s = k + c*x. El secreto x queda enmascarado por el k aleatorio."
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Toy Schnorr: x = 5, k = 3, c = 2, q = 11. Compute s = (k + c*x) mod q.",
          "장난감 슈노르: x = 5, k = 3, c = 2, q = 11. s = (k + c*x) mod q를 계산하세요.",
          "玩具 Schnorr：x = 5, k = 3, c = 2, q = 11。計 s = (k + c*x) mod q。",
          "玩具 Schnorr：x = 5, k = 3, c = 2, q = 11。算 s = (k + c*x) mod q。",
          "おもちゃの Schnorr：x = 5, k = 3, c = 2, q = 11。s = (k + c*x) mod q を計算してください。",
          "Hračkový Schnorr: x = 5, k = 3, c = 2, q = 11. Spočítej s = (k + c*x) mod q.",
          "Schnorr de juguete: x = 5, k = 3, c = 2, q = 11. Calcula s = (k + c*x) mod q."
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
]],
          [[
# 玩具: p = 23 模数,  h = 2,  q = 11 (h 的阶)
x = 5            # x: 秘密           Y = 2^5 mod 23 = 9
k = 3            # k: 随机 nonce     t = 2^3 mod 23 = 8
c = 2            # c: 挑战
s = (k + c * x) % q  == ___     # s: 响应, mod q
]],
          [[
# おもちゃ: p = 23 は法,  h = 2,  q = 11 (h の位数)
x = 5            # x: 秘密           Y = 2^5 mod 23 = 9
k = 3            # k: ランダムなナンス   t = 2^3 mod 23 = 8
c = 2            # c: チャレンジ
s = (k + c * x) % q  == ___     # s: レスポンス, mod q
]],
          [[
# hračka: p = 23 modul,  h = 2,  q = 11 (řád h)
x = 5            # x: tajné          Y = 2^5 mod 23 = 9
k = 3            # k: náhodný nonce  t = 2^3 mod 23 = 8
c = 2            # c: výzva
s = (k + c * x) % q  == ___     # s: odpověď, mod q
]],
          [[
# juguete: p = 23 módulo,  h = 2,  q = 11 (orden de h)
x = 5            # x: secreto        Y = 2^5 mod 23 = 9
k = 3            # k: nonce al azar  t = 2^3 mod 23 = 8
c = 2            # c: desafío
s = (k + c * x) % q  == ___     # s: respuesta, mod q
]]
        ),
        accept = { "2" },
        answer = "2",
        hint = L(
          "3 + 2 * 5 = 13, and 13 mod 11 = 2.",
          "3 + 2 * 5 = 13, 그리고 13 mod 11 = 2.",
          "3 + 2 * 5 = 13，而 13 mod 11 = 2。",
          "3 + 2 * 5 = 13，而 13 mod 11 = 2。",
          "3 + 2 * 5 = 13、そして 13 mod 11 = 2。",
          "3 + 2 * 5 = 13 a 13 mod 11 = 2.",
          "3 + 2 * 5 = 13, y 13 mod 11 = 2."
        ),
        ok = L(
          "s = 2. Alex sends (t, s) = (8, 2). Not x.",
          "s = 2. 알렉스는 (t, s) = (8, 2)를 보냅니다. x는 아님.",
          "s = 2。阿力送出 (t, s) = (8, 2)。唔係 x。",
          "s = 2。阿力发出 (t, s) = (8, 2)。不是 x。",
          "s = 2。アレックスは (t, s) = (8, 2) を送ります。x ではありません。",
          "s = 2. Alex pošle (t, s) = (8, 2). Ne x.",
          "s = 2. Alex envía (t, s) = (8, 2). No x."
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Gate check: h^s == t * Y^c mod 23. Left is 2^2 = 4. Compute the right side 8 * 81 mod 23.",
          "게이트 검사: h^s == t * Y^c mod 23. 왼쪽은 2^2 = 4. 오른쪽 8 * 81 mod 23을 계산하세요.",
          "閘口檢查：h^s == t * Y^c mod 23。左邊係 2^2 = 4。計右邊 8 * 81 mod 23。",
          "闸口检查：h^s == t * Y^c mod 23。左边是 2^2 = 4。算右边 8 * 81 mod 23。",
          "ゲートの検査：h^s == t * Y^c mod 23。左辺は 2^2 = 4。右辺 8 * 81 mod 23 を計算してください。",
          "Kontrola brány: h^s == t * Y^c mod 23. Vlevo je 2^2 = 4. Spočítej pravou stranu 8 * 81 mod 23.",
          "Revisión de la puerta: h^s == t * Y^c mod 23. La izquierda es 2^2 = 4. Calcula el lado "
            .. "derecho 8 * 81 mod 23."
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
]],
          [[
# 闸口:  h^s  ==  t * Y^c   (mod 23)
# s: 响应   t: 公布值   Y: 公开值   c: 挑战
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  闸口信服
]],
          [[
# ゲート:  h^s  ==  t * Y^c   (mod 23)
# s: レスポンス   t: 公表値   Y: 公開値   c: チャレンジ
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  ゲートは納得する
]],
          [[
# brána:  h^s  ==  t * Y^c   (mod 23)
# s: odpověď   t: ohlášení   Y: veřejné   c: výzva
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  brána je přesvědčená
]],
          [[
# puerta:  h^s  ==  t * Y^c   (mod 23)
# s: respuesta   t: anuncio   Y: público   c: desafío
left  = 2^2 % 23             # h^s   = 4
right = 8 * 9^2 % 23         # t*Y^c = 8 * 81 = 648
right == ___
# left == right  ->  la puerta queda convencida
]]
        ),
        accept = { "4" },
        answer = "4",
        hint = L(
          "81 mod 23 = 12, so 8 * 12 = 96, and 96 = 4 * 23 + 4.",
          "81 mod 23 = 12, 그래서 8 * 12 = 96, 그리고 96 = 4 * 23 + 4.",
          "81 mod 23 = 12，所以 8 * 12 = 96，而 96 = 4 * 23 + 4。",
          "81 mod 23 = 12，所以 8 * 12 = 96，而 96 = 4 * 23 + 4。",
          "81 mod 23 = 12、だから 8 * 12 = 96、そして 96 = 4 * 23 + 4。",
          "81 mod 23 = 12, takže 8 * 12 = 96 a 96 = 4 * 23 + 4.",
          "81 mod 23 = 12, así que 8 * 12 = 96, y 96 = 4 * 23 + 4."
        ),
        ok = L(
          "4 == 4. The gate verified without ever touching x = 5.",
          "4 == 4. 게이트는 x = 5를 한 번도 건드리지 않고 검증했습니다.",
          "4 == 4。閘口完全冇掂過 x = 5 就驗證咗。",
          "4 == 4。闸口完全没碰过 x = 5 就验证通过了。",
          "4 == 4。ゲートは x = 5 に一度も触れずに検証しました。",
          "4 == 4. Brána ověřila, aniž se x = 5 vůbec dotkla.",
          "4 == 4. La puerta verificó sin tocar nunca x = 5."
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Ken has no x. He guesses s = 5. What is his left side 2^5 mod 23? (right side is still 4)",
          "켄은 x가 없습니다. s = 5로 찍습니다. 왼쪽 2^5 mod 23은? (오른쪽은 여전히 4)",
          "阿健冇 x。佢估 s = 5。佢嘅左邊 2^5 mod 23 係幾多？（右邊仍然係 4）",
          "阿健没有 x。他猜 s = 5。他的左边 2^5 mod 23 是多少？（右边还是 4）",
          "ケンには x がありません。s = 5 と当てます。左辺 2^5 mod 23 は？（右辺はまだ 4）",
          "Ken nemá x. Tipne s = 5. Kolik je jeho levá strana 2^5 mod 23? (pravá je pořád 4)",
          "Ken no tiene x. Adivina s = 5. ¿Cuál es su lado izquierdo 2^5 mod 23? (la derecha sigue en 4)"
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
]],
          [[
# 阿健不知道 x。他猜 s = 5。
left  = 2^5 % 23  == ___     # 用猜的 s 算出的 h^s
right = 4                    # t * Y^c, 不变
# left != right  ->  DENY
]],
          [[
# ケンは x を知らない。s = 5 と当てずっぽう。
left  = 2^5 % 23  == ___     # 当てずっぽうの s で計算した h^s
right = 4                    # t * Y^c, そのまま
# left != right  ->  DENY
]],
          [[
# Ken nezná x. Tipne s = 5.
left  = 2^5 % 23  == ___     # h^s s tipnutým s
right = 4                    # t * Y^c, beze změny
# left != right  ->  DENY
]],
          [[
# Ken no sabe x. Adivina s = 5.
left  = 2^5 % 23  == ___     # h^s con la s adivinada
right = 4                    # t * Y^c, sin cambios
# left != right  ->  DENY
]]
        ),
        accept = { "9" },
        answer = "9",
        hint = L(
          "2^5 = 32, and 32 - 23 = 9.",
          "2^5 = 32, 그리고 32 - 23 = 9.",
          "2^5 = 32，而 32 - 23 = 9。",
          "2^5 = 32，而 32 - 23 = 9。",
          "2^5 = 32、そして 32 - 23 = 9。",
          "2^5 = 32 a 32 - 23 = 9.",
          "2^5 = 32, y 32 - 23 = 9."
        ),
        ok = L(
          "9 != 4. DENY. A blind guess passes 1 time in q; real q is 256-bit.",
          "9 != 4. DENY. 마구 찍으면 q번에 1번 통과; 실제 q는 256비트.",
          "9 != 4。DENY。亂估 q 次先中 1 次；真正嘅 q 係 256-bit。",
          "9 != 4。DENY。瞎猜 q 次才中 1 次；真正的 q 是 256-bit。",
          "9 != 4。DENY。当てずっぽうは q 回に1回しか通らない；本物の q は256ビット。",
          "9 != 4. DENY. Slepý tip projde jednou z q; skutečné q má 256 bitů.",
          "9 != 4. DENY. Adivinar a ciegas acierta 1 vez de cada q; la q real es de 256 bits."
        ),
      },
      {
        topic = "PROVE",
        q = L(
          "Fiat-Shamir: which hash function makes the challenge c in python/zkp?",
          "피아트-샤미르: python/zkp에서 도전값 c를 만드는 해시 함수는?",
          "Fiat-Shamir：python/zkp 入面用邊個 hash 函數整挑戰 c？",
          "Fiat-Shamir：python/zkp 里用哪个 hash 函数做出挑战 c？",
          "Fiat-Shamir：python/zkp でチャレンジ c を作るハッシュ関数は？",
          "Fiat-Shamir: která hašovací funkce dělá výzvu c v python/zkp?",
          "Fiat-Shamir: ¿qué función hash crea el desafío c en python/zkp?"
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
]],
          [[
# 不用来回交互: 对 transcript 做 hash
# python/zkp/group.py  fiat_shamir
# transcript: 陈述 + 每一个 t     q: 群的阶
c = ___(transcript) mod q    # c: 挑战, 现在是一个 hash
]],
          [[
# やり取りなし: transcript をハッシュする
# python/zkp/group.py  fiat_shamir
# transcript: ステートメント + すべての t     q: 群の位数
c = ___(transcript) mod q    # c: チャレンジ、今はハッシュ
]],
          [[
# žádné tam a zpět: zahašuj transcript
# python/zkp/group.py  fiat_shamir
# transcript: tvrzení + všechna t     q: řád grupy
c = ___(transcript) mod q    # c: výzva, teď haš
]],
          [[
# sin ida y vuelta: hashea el transcript
# python/zkp/group.py  fiat_shamir
# transcript: la declaración + cada t     q: orden del grupo
c = ___(transcript) mod q    # c: desafío, ahora un hash
]]
        ),
        accept = { "sha256", "sha-256", "sha2", "sha" },
        answer = "sha256",
        hint = L(
          "group.py uses hashlib.sha256 over the whole transcript.",
          "group.py는 전체 트랜스크립트에 hashlib.sha256을 씁니다.",
          "group.py 對成個 transcript 用 hashlib.sha256。",
          "group.py 对整个 transcript 用 hashlib.sha256。",
          "group.py は transcript 全体に hashlib.sha256 を使います。",
          "group.py pouští hashlib.sha256 na celý transcript.",
          "group.py usa hashlib.sha256 sobre todo el transcript."
        ),
        ok = L(
          "c = SHA256(transcript). Nobody can pick c after seeing t. Non-interactive, still sound.",
          "c = SHA256(transcript). t를 본 뒤에 c를 고를 수 없다. 비대화식이지만 여전히 건전.",
          "c = SHA256(transcript)。冇人可以睇完 t 先揀 c。非互動，仍然可靠。",
          "c = SHA256(transcript)。没人能看完 t 再挑 c。非交互，依然可靠。",
          "c = SHA256(transcript)。t を見てから c を選ぶことはできない。非対話式でも健全。",
          "c = SHA256(transcript). Nikdo nemůže zvolit c až po t. Neinteraktivní, a přesto korektní.",
          "c = SHA256(transcript). Nadie puede elegir c después de ver t. No interactivo, e igual de sólido."
        ),
      },
    },
  },

  {
    id = "hash",
    station = "NONCE",
    name = L(
      "Tonight's ticket",
      "오늘 밤의 티켓",
      "今晚嘅飛",
      "今晚的票",
      "今夜のチケット",
      "Dnešní lístek",
      "El boleto de esta noche"
    ),
    title = L(
      "YOUR envelope, THIS conversation",
      "네 봉투, 이 대화",
      "你嘅信封，呢次對話",
      "你的信封，这次对话",
      "君の封筒、この会話",
      "TVOJE obálka, TAHLE konverzace",
      "TU sobre, ESTA conversación"
    ),
    lesson = L(
      "sk + the office's signature on (C, pk) + a fresh nonce bind the proof to Alex, tonight.",
      "sk + (C, pk)에 대한 발급소 서명 + 새 논스가 증명을 오늘 밤의 알렉스에게 묶는다.",
      "sk + 辦事處對 (C, pk) 嘅簽名 + 新鮮 nonce，將證明綁住今晚嘅阿力。",
      "sk + 办事处对 (C, pk) 的签名 + 一个新的 nonce，把证明绑在阿力身上，绑在今晚。",
      "sk + 発行所の (C, pk) への署名 + 新しいナンスが、証明を今夜のアレックスに結びつける。",
      "sk + podpis úřadu na (C, pk) + čerstvý nonce váží důkaz na Alexe a na dnešní večer.",
      "sk + la firma de la oficina sobre (C, pk) + un nonce nuevo atan la prueba a Alex, esta noche."
    ),
    bg = "bg_hash",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔", "荣叔", "ウィンおじさん", "Strýc Wing", "Tío Wing"),
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
          "每個客新一張飛。琴日嘅 JSON 係垃圾。",
          "每位客人一张新票。昨天的 JSON 是垃圾。",
          "客ごとに新しいチケット。昨日の JSON はゴミだ。",
          "Každý zákazník dostane nový lístek. Včerejší JSON je odpad.",
          "Boleto nuevo por cada cliente. El JSON de ayer es basura."
        ),
      },
      {
        kind = "officer",
        x = 1100,
        facing = -1,
        line = L(
          "I signed (C, pk). Nobody else can mint this envelope.",
          "내가 (C, pk)에 서명했어. 이 봉투는 아무도 못 만들어.",
          "我簽咗 (C, pk)。冇其他人整到呢個信封。",
          "(C, pk) 是我签的。别人造不出这个信封。",
          "私が (C, pk) に署名しました。この封筒は他の誰にも作れません。",
          "Podepsala jsem (C, pk). Tuhle obálku nikdo jiný nevyrobí.",
          "Yo firmé (C, pk). Nadie más puede crear este sobre."
        ),
      },
    },
    viz = "hash",
    story = L(
      "Three things bind the proof to Alex: a holder key pair, the office's signature on (C, pk), "
        .. "and a fresh nonce from the gate mixed into the hash.",
      "세 가지가 증명을 알렉스에게 묶습니다: 소지자 키 쌍, (C, pk)에 대한 발급소 서명, 그리고 해시에 섞인 게이트의 새 논스.",
      "三樣嘢將證明綁住阿力：持有人嘅一對鑰匙、辦事處對 (C, pk) 嘅簽名，同埋閘口俾嘅新鮮 nonce 混入 hash。",
      "三样东西把证明绑在阿力身上：持有人的一对密钥、办事处对 (C, pk) 的签名，还有闸口给的新 nonce 混进 hash。",
      "三つのものが証明をアレックスに結びつけます：持ち主の鍵ペア、発行所の (C, pk) への署名、そしてハッシュに混ぜるゲートの新しいナンス。",
      "Důkaz váží na Alexe tři věci: klíčový pár držitele, podpis úřadu na (C, pk) a čerstvý nonce "
        .. "od brány zamíchaný do haše.",
      "Tres cosas atan la prueba a Alex: un par de llaves del titular, la firma de la oficina sobre "
        .. "(C, pk), y un nonce nuevo de la puerta mezclado en el hash."
    ),
    stages = {
      {
        topic = "BIND",
        q = L(
          "pk = g^? -- what is the holder's private key called?",
          "pk = g^? -- 소지자의 개인키 이름은?",
          "pk = g^? —— 持有人嘅私鑰叫乜？",
          "pk = g^? —— 持有人的私钥叫什么？",
          "pk = g^? -- 持ち主の秘密鍵の名前は？",
          "pk = g^? -- jak se jmenuje soukromý klíč držitele?",
          "pk = g^? -- ¿cómo se llama la llave privada del titular?"
        ),
        code = L(
          [[
# python/zkp/identity.py  keygen
# same g as the office: Schnorr key, not ECDSA
___ = random_scalar()     # private key, stays on the phone
pk  = pow(g, ___)         # pk: public key   g: generator
]],
          [[
# python/zkp/identity.py  keygen
# 발급소와 같은 g: ECDSA 아닌 슈노어 키
___ = random_scalar()     # 개인키, 폰에만 있음
pk  = pow(g, ___)         # pk: 공개키   g: 생성원
]],
          [[
# python/zkp/identity.py  keygen
# 同辦事處一樣嘅 g：Schnorr 鑰匙，唔係 ECDSA
___ = random_scalar()     # 私鑰, 留喺部電話
pk  = pow(g, ___)         # pk: 公鑰   g: 生成元
]],
          [[
# python/zkp/identity.py  keygen
# 和办事处一样的 g：Schnorr 密钥，不是 ECDSA
___ = random_scalar()     # 私钥, 留在手机上
pk  = pow(g, ___)         # pk: 公钥   g: 生成元
]],
          [[
# python/zkp/identity.py  keygen
# 発行所と同じ g: Schnorr の鍵、ECDSA ではない
___ = random_scalar()     # 秘密鍵、スマホの中だけ
pk  = pow(g, ___)         # pk: 公開鍵   g: 生成元
]],
          [[
# python/zkp/identity.py  keygen
# stejné g jako úřad: Schnorrův klíč, ne ECDSA
___ = random_scalar()     # soukromý klíč, zůstane v mobilu
pk  = pow(g, ___)         # pk: veřejný klíč   g: generátor
]],
          [[
# python/zkp/identity.py  keygen
# misma g que la oficina: llave Schnorr, no ECDSA
___ = random_scalar()     # llave privada, vive en el teléfono
pk  = pow(g, ___)         # pk: llave pública   g: generador
]]
        ),
        accept = { "sk" },
        answer = "sk",
        hint = L(
          "sk = secret key, pk = public key. pk = g^sk.",
          "sk = 비밀키, pk = 공개키. pk = g^sk.",
          "sk = 私鑰，pk = 公鑰。pk = g^sk。",
          "sk = 私钥，pk = 公钥。pk = g^sk。",
          "sk = 秘密鍵、pk = 公開鍵。pk = g^sk.",
          "sk = tajný klíč, pk = veřejný klíč. pk = g^sk.",
          "sk = llave secreta, pk = llave pública. pk = g^sk."
        ),
        ok = L(
          "pk = g^sk. A stolen envelope without sk cannot answer.",
          "pk = g^sk. sk 없이 훔친 봉투는 응답할 수 없다.",
          "pk = g^sk。偷咗信封但冇 sk，答唔到。",
          "pk = g^sk。偷了信封但没有 sk，答不上来。",
          "pk = g^sk。sk なしで盗んだ封筒は応答できない。",
          "pk = g^sk. Ukradená obálka bez sk neodpoví.",
          "pk = g^sk. Un sobre robado sin sk no puede responder."
        ),
      },
      {
        topic = "BIND",
        q = L(
          "The ID office signs two things together so the envelope belongs to one key. C and what?",
          "발급소는 봉투가 한 키에 속하도록 두 가지를 함께 서명합니다. C와 무엇?",
          "辦事處將兩樣嘢一齊簽名，令信封屬於一條鑰匙。C 同埋乜？",
          "办事处把两样东西一起签名，让信封属于一把密钥。C 和什么？",
          "発行所は封筒がひとつの鍵に属すよう、二つを一緒に署名します。C と何？",
          "Úřad dokladů podepíše dvě věci naráz, aby obálka patřila jednomu klíči. C a co ještě?",
          "La oficina firma dos cosas juntas para que el sobre pertenezca a una llave. C y ¿qué más?"
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
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: 办事处的密钥
# C: 信封    第二项: 这个信封属于谁的密钥
# 闸口信任 office_pk, 所以签名有效就意味着:
# "由办事处封好, 给这把密钥的主人"
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: 発行所の鍵
# C: 封筒    二つ目: この封筒が誰の鍵のものか
# ゲートは office_pk を信頼する。良い署名の意味は:
# 「発行所が封をした、この鍵の持ち主のために」
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: klíč úřadu
# C: obálka    druhá položka: ke kterému klíči C patří
# brána věří office_pk, takže dobrý sig znamená:
# "zapečetěno úřadem, pro majitele tohoto klíče"
]],
          [[
# python/zkp/age.py  issue_credential
sig = sign(office_sk, [C, ___])   # office_sk: llave de la oficina
# C: el sobre    lo segundo: de qué llave es C
# la puerta confía en office_pk, una firma buena dice:
# "sellado por la oficina, para el dueño de esta llave"
]]
        ),
        accept = {
          "pk",
          "publickey",
          "holderpk",
          "공개키",
          "公鑰",
          "公钥",
          "公開鍵",
          "veřejný klíč",
          "llave pública",
          "clave pública",
        },
        answer = "pk",
        hint = L(
          "The public half of the holder's key pair.",
          "소지자 키 쌍의 공개된 절반.",
          "持有人鑰匙對入面公開嘅一半。",
          "持有人密钥对中公开的那一半。",
          "持ち主の鍵ペアの公開された半分。",
          "Veřejná polovina klíčového páru držitele.",
          "La mitad pública del par de llaves del titular."
        ),
        ok = L(
          "sig over (C, pk). A self-made envelope has no office signature: DENY at the door.",
          "(C, pk)에 대한 서명. 직접 만든 봉투에는 발급소 서명이 없다: 문 앞에서 DENY.",
          "對 (C, pk) 嘅簽名。自己整嘅信封冇辦事處簽名：喺門口 DENY。",
          "对 (C, pk) 的签名。自己造的信封没有办事处签名：在门口 DENY。",
          "(C, pk) への署名。自作の封筒に発行所の署名はない：扉の前で DENY。",
          "sig přes (C, pk). Podomácku vyrobená obálka nemá podpis úřadu: DENY u dveří.",
          "sig sobre (C, pk). Un sobre casero no tiene firma de la oficina: DENY en la puerta."
        ),
      },
      {
        topic = "BIND",
        q = L(
          "The gate gives every customer a fresh random ticket. What is it called?",
          "게이트는 손님마다 새 무작위 티켓을 줍니다. 그 이름은?",
          "閘口俾每個客一張新嘅隨機飛。佢叫乜？",
          "闸口给每位客人一张新的随机票。它叫什么？",
          "ゲートは客ごとに新しいランダムなチケットを渡します。その名前は？",
          "Brána dá každému zákazníkovi čerstvý náhodný lístek. Jak se jmenuje?",
          "La puerta le da a cada cliente un boleto aleatorio nuevo. ¿Cómo se llama?"
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
]],
          [[
# 闸口给的新随机票, 每次检查一张.
# 混进 hash c, 所以昨晚的
# JSON 不能重放.
proof.___ = gate_challenge   # gate_challenge: 今晚的票
]],
          [[
# ゲートがくれる新しいランダムなチケット、検査ごとに一枚。
# ハッシュ c に混ぜるので、昨夜の
# JSON は再生できない。
proof.___ = gate_challenge   # gate_challenge: 今夜のチケット
]],
          [[
# čerstvý náhodný lístek od brány, jeden na kontrolu.
# zamíchá se do haše c, aby včerejší
# JSON nešel přehrát.
proof.___ = gate_challenge   # gate_challenge: dnešní lístek
]],
          [[
# boleto aleatorio nuevo de la puerta, uno por revisión.
# se mezcla en el hash c para que el JSON
# de anoche no se pueda reusar.
proof.___ = gate_challenge   # gate_challenge: boleto de hoy
]]
        ),
        accept = { "nonce", "논스", "隨機數", "随机数", "ナンス" },
        answer = "nonce",
        hint = L(
          "A number used once: n-once.",
          "한 번만 쓰는 수: n-once.",
          "只用一次嘅數：n-once。",
          "只用一次的数：n-once。",
          "一度だけ使う数：n-once。",
          "Číslo na jedno použití: n-once.",
          "Un número usado una vez: n-once."
        ),
        ok = L(
          "c = SHA256(nonce, C, pk, ...). A proof answers exactly one ticket.",
          "c = SHA256(nonce, C, pk, ...). 증명은 정확히 티켓 하나에만 답한다.",
          "c = SHA256(nonce, C, pk, ...)。一個證明只答一張飛。",
          "c = SHA256(nonce, C, pk, ...)。一个证明只回答一张票。",
          "c = SHA256(nonce, C, pk, ...)。証明はちょうど一枚のチケットにだけ答える。",
          "c = SHA256(nonce, C, pk, ...). Důkaz odpovídá právě na jeden lístek.",
          "c = SHA256(nonce, C, pk, ...). Una prueba responde a un solo boleto."
        ),
      },
      {
        topic = "BIND",
        q = L(
          "Ken copies last night's proof JSON and shows it tonight. What does the gate print?",
          "켄이 어젯밤 증명 JSON을 복사해 오늘 밤 보여줍니다. 게이트는 뭐라고 찍나요?",
          "阿健複製尋晚嘅證明 JSON，今晚攞出嚟。閘口印乜？",
          "阿健复制昨晚的证明 JSON，今晚拿出来。闸口打印什么？",
          "ケンが昨夜の証明 JSON をコピーして今夜見せます。ゲートは何と表示しますか？",
          "Ken zkopíruje včerejší JSON s důkazem a ukáže ho dnes. Co brána vypíše?",
          "Ken copia el JSON de la prueba de anoche y lo muestra hoy. ¿Qué imprime la puerta?"
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
]],
          [[
# 昨晚:  ticket = "a1f3"   proof.nonce = "a1f3"
# 今晚:  ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: 闸口期望的票
# proof.nonce != nonce  ->  "___"
]],
          [[
# 昨夜:  ticket = "a1f3"   proof.nonce = "a1f3"
# 今夜:  ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: ゲートが期待するチケット
# proof.nonce != nonce  ->  "___"
]],
          [[
# včera večer: ticket = "a1f3"   proof.nonce = "a1f3"
# dnes večer:  ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: lístek, který brána čeká
# proof.nonce != nonce  ->  "___"
]],
          [[
# anoche:  ticket = "a1f3"   proof.nonce = "a1f3"
# hoy:     ticket = "9c07"
verify(proof, nonce="9c07")  # nonce: el boleto que pide la puerta
# proof.nonce != nonce  ->  "___"
]]
        ),
        accept = {
          "deny",
          "denied",
          "reject",
          "rejected",
          "fail",
          "거부",
          "拒絕",
          "拒绝",
          "拒否",
          "zamítnout",
          "zamítnuto",
          "rechazar",
          "denegar",
        },
        answer = "DENY",
        hint = L(
          "The red stamp. The proof answers a different conversation.",
          "빨간 도장. 증명이 다른 대화에 답하고 있음.",
          "紅色印。個證明答緊另一次對話。",
          "红色的印。这个证明回答的是另一次对话。",
          "赤いスタンプ。証明が別の会話に答えている。",
          "Červené razítko. Ten důkaz odpovídá na jinou konverzaci.",
          "El sello rojo. La prueba responde a otra conversación."
        ),
        ok = L(
          "DENY: challenge mismatch. Replay dies at the door.",
          "DENY: 도전값 불일치. 재사용은 문 앞에서 죽는다.",
          "DENY：挑戰唔對。重播喺門口死咗。",
          "DENY：挑战不匹配。重放在门口就死了。",
          "DENY：チャレンジ不一致。リプレイは扉の前で死ぬ。",
          "DENY: nesouhlasí výzva. Přehrání skončí u dveří.",
          "DENY: el desafío no coincide. El replay muere en la puerta."
        ),
      },
    },
  },

  {
    id = "beer",
    station = "BEER",
    name = L("The fridge", "냉장고", "雪櫃", "冰柜", "冷蔵庫", "Lednice", "El refrigerador"),
    title = L(
      "How verification works",
      "검증은 어떻게 이루어지나",
      "驗證點運作",
      "验证怎么运作",
      "検証はどう動くか",
      "Jak funguje ověření",
      "Cómo funciona la verificación"
    ),
    lesson = L(
      "Verify checks equations only. ADMIT reveals age >= 18 and nothing more.",
      "검증은 식만 확인한다. ADMIT은 age >= 18만 드러내고 그 이상은 없다.",
      "驗證只係檢查方程。ADMIT 只透露 age >= 18，冇其他。",
      "验证只检查等式。ADMIT 只透露 age >= 18，别无其他。",
      "検証は式だけを確かめる。ADMIT が明かすのは age >= 18 だけ、それ以上はない。",
      "Verify kontroluje jen rovnice. ADMIT prozradí age >= 18 a nic víc.",
      "Verify solo revisa ecuaciones. ADMIT revela age >= 18 y nada más."
    ),
    bg = "bg_store",
    portrait = "portrait_clerk",
    speaker = L("The gate", "게이트", "閘口", "闸口", "ゲート", "Brána", "La puerta"),
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
          "門檻、nonce、簽名、持有人、一致性、bit……",
          "门槛、nonce、签名、持有人、一致性、bit……",
          "基準、ナンス、署名、持ち主、一貫性、ビット…",
          "Práh, nonce, podpis, vlastník, konzistence, bity...",
          "Umbral, nonce, firma, dueño, consistencia, bits..."
        ),
      },
      {
        kind = "mei",
        x = 720,
        facing = -1,
        line = L(
          "If this prints ADMIT I am buying spicy fish.",
          "ADMIT이 찍히면 내가 매운 어묵 살게.",
          "如果印 ADMIT，我請食辣魚蛋。",
          "如果打印 ADMIT，我请吃辣鱼蛋。",
          "ADMIT って出たら、辛い魚団子おごるよ。",
          "Jestli to vypíše ADMIT, kupuju pálivou rybu.",
          "Si esto imprime ADMIT, yo invito el pescado picante."
        ),
      },
      {
        kind = "ken",
        x = 980,
        facing = -1,
        line = L(
          "He still does not know you are 25. Beautiful.",
          "아저씨는 아직도 네가 25인지 몰라. 아름답다.",
          "佢仲係唔知你 25 歲。正。",
          "他还是不知道你 25 岁。漂亮。",
          "おじさんはまだ君が25歳だと知らない。美しい。",
          "Pořád neví, že ti je 25. Nádhera.",
          "Sigue sin saber que tienes 25. Hermoso."
        ),
      },
    },
    viz = "beer",
    story = L(
      "Verification never opens C. It only checks equations: threshold, nonce, issuer signature, "
        .. "owner key, bit consistency, every bit is 0 or 1. Then the stamp.",
      "검증은 C를 절대 열지 않습니다. 식만 확인합니다: 기준, 논스, 발급자 서명, 소유자 키, 비트 일관성, 모든 비트가 0 또는 1. 그리고 도장.",
      "驗證永遠唔會打開 C。淨係檢查方程：門檻、nonce、發行者簽名、持有人鑰匙、bit 一致性、每個 bit 係 0 或 1。然後蓋印。",
      "验证从不打开 C。它只检查等式：门槛、nonce、签发者签名、持有人密钥、bit 一致性、每个 bit 是 0 或 1。然后盖印。",
      "検証は C を決して開きません。式だけを確かめます：基準、ナンス、発行者の署名、持ち主の鍵、ビットの一貫性、すべてのビットが 0 か 1。それからスタンプ。",
      "Ověření nikdy neotevře C. Kontroluje jen rovnice: práh, nonce, podpis vydavatele, klíč "
        .. "vlastníka, konzistenci bitů a že každý bit je 0 nebo 1. Pak razítko.",
      "La verificación nunca abre C. Solo revisa ecuaciones: umbral, nonce, firma del emisor, llave "
        .. "del dueño, consistencia de bits, y que cada bit sea 0 o 1. Luego, el sello."
    ),
    stages = {
      {
        topic = "VERIFY",
        q = L(
          "Cheap checks first. Before any math, which field of the proof is compared to the door's own 18?",
          "싼 검사부터. 수학 이전에, 증명의 어떤 필드가 문의 18과 비교되나요?",
          "平嘅檢查先。做任何數學之前，證明嘅邊個欄位同道門自己嘅 18 比較？",
          "便宜的检查先做。做任何数学之前，证明的哪个字段要跟门自己的 18 比较？",
          "安い検査から先に。計算の前に、証明のどのフィールドが扉自身の 18 と比べられますか？",
          "Nejdřív levné kontroly. Které pole důkazu se ještě před počítáním porovná s vlastní 18 u dveří?",
          "Primero las revisiones baratas. Antes de cualquier cálculo, ¿qué campo de la prueba se "
            .. "compara con el 18 de la puerta?"
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
]],
          [[
# python/zkp/age.py  verify_adult  (按这个次序)
1. proof.___ == 18                  # 门自己的政策 T
2. proof.nonce == nonce             # 这次对话的票
3. verify_sig(office_pk, (C, pk))   # C: 信封  pk: 持有人密钥
4. schnorr(pk, proof.owner, c)      # 持有人知道 sk   c: hash
]],
          [[
# python/zkp/age.py  verify_adult  (この順番で)
1. proof.___ == 18                  # 扉自身のポリシー T
2. proof.nonce == nonce             # この会話のチケット
3. verify_sig(office_pk, (C, pk))   # C: 封筒  pk: 持ち主の鍵
4. schnorr(pk, proof.owner, c)      # 持ち主が sk を知る   c: ハッシュ
]],
          [[
# python/zkp/age.py  verify_adult  (v tomto pořadí)
1. proof.___ == 18                  # vlastní politika dveří T
2. proof.nonce == nonce             # lístek téhle konverzace
3. verify_sig(office_pk, (C, pk))   # C: obálka  pk: klíč držitele
4. schnorr(pk, proof.owner, c)      # držitel zná sk   c: haš
]],
          [[
# python/zkp/age.py  verify_adult  (en este orden)
1. proof.___ == 18                  # la política T de la puerta
2. proof.nonce == nonce             # el boleto de esta charla
3. verify_sig(office_pk, (C, pk))   # C: sobre  pk: llave titular
4. schnorr(pk, proof.owner, c)      # titular sabe sk   c: hash
]]
        ),
        accept = {
          "threshold",
          "t",
          "policy",
          "기준",
          "임계값",
          "門檻",
          "閾值",
          "门槛",
          "阈值",
          "基準",
          "閾値",
          "práh",
          "umbral",
        },
        answer = "threshold",
        hint = L(
          "A proof written for T = 16 dies at line 1 of a door of 18, before any exponentiation.",
          "T = 16용으로 쓴 증명은 18 문의 1번 줄에서, 어떤 거듭제곱 전에 죽는다.",
          "為 T = 16 寫嘅證明，喺 18 道門嘅第 1 行就死，未做任何冪運算。",
          "为 T = 16 写的证明，在 18 的门第 1 行就死了，还没做任何幂运算。",
          "T = 16 用に書かれた証明は、18 の扉の1行目で、べき乗計算の前に死ぬ。",
          "Důkaz psaný pro T = 16 padne na řádku 1 u dveří s 18, ještě před umocňováním.",
          "Una prueba escrita para T = 16 muere en la línea 1 de una puerta de 18, antes de cualquier "
            .. "exponenciación."
        ),
        ok = L(
          "Order: threshold, nonce, signature, owner, then consistency and bits. The JSON's T never "
            .. "overrides the door's.",
          "순서: 기준, 논스, 서명, 소유자, 그다음 일관성과 비트. JSON의 T는 절대 문의 T를 덮어쓰지 못한다.",
          "次序：門檻、nonce、簽名、持有人，然後一致性同 bit。JSON 嘅 T 永遠蓋唔過道門嘅。",
          "次序：门槛、nonce、签名、持有人，然后一致性和 bit。JSON 里的 T 永远盖不过门自己的。",
          "順番：基準、ナンス、署名、持ち主、それから一貫性とビット。JSON の T が扉の T を上書きすることは決してない。",
          "Pořadí: práh, nonce, podpis, vlastník, pak konzistence a bity. T z JSONu nikdy nepřebije to "
            .. "u dveří.",
          "Orden: umbral, nonce, firma, dueño, luego consistencia y bits. La T del JSON nunca reemplaza "
            .. "a la de la puerta."
        ),
      },
      {
        topic = "VERIFY",
        q = L(
          "Mei flips one hex digit of C in the JSON. The office never signed that C. What does the gate " .. "print?",
          "메이가 JSON에서 C의 16진수 한 자리를 바꿉니다. 발급소는 그 C에 서명한 적이 없죠. 게이트는 뭐라고 찍나요?",
          "阿美改咗 JSON 入面 C 嘅一個十六進制數字。辦事處從來冇簽過嗰個 C。閘口印乜？",
          "阿美把 JSON 里 C 的一个十六进制数字改了。办事处从没签过那个 C。闸口打印什么？",
          "メイが JSON の C の16進数を1桁書き換えます。発行所はその C に署名していません。ゲートは何と表示しますか？",
          "Mei změní v JSONu jednu šestnáctkovou číslici C. Takové C úřad nepodepsal. Co brána vypíše?",
          "Mei cambia un dígito hex de C en el JSON. La oficina nunca firmó esa C. ¿Qué imprime la puerta?"
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
]],
          [[
# 阿美改了 JSON 里的 C:  "0x3a9..." -> "0x3b9..."
# 检查 3: verify_sig(office_pk, (C, pk))
# C: 信封   office_pk: 办事处的公钥
# 办事处签的是旧的 C, 不是这个
verify(proof, nonce)  ->  "___"
]],
          [[
# メイが JSON の C を書き換える:  "0x3a9..." -> "0x3b9..."
# 検査 3: verify_sig(office_pk, (C, pk))
# C: 封筒   office_pk: 発行所の公開鍵
# 発行所が署名したのは古い C、これではない
verify(proof, nonce)  ->  "___"
]],
          [[
# Mei upraví C v JSONu:  "0x3a9..." -> "0x3b9..."
# kontrola 3: verify_sig(office_pk, (C, pk))
# C: obálka   office_pk: veřejný klíč úřadu
# úřad podepsal STARÉ C, ne tohle
verify(proof, nonce)  ->  "___"
]],
          [[
# Mei edita C en el JSON:  "0x3a9..." -> "0x3b9..."
# revisión 3: verify_sig(office_pk, (C, pk))
# C: el sobre   office_pk: la llave pública de la oficina
# la oficina firmó la C VIEJA, no esta
verify(proof, nonce)  ->  "___"
]]
        ),
        accept = {
          "deny",
          "denied",
          "reject",
          "rejected",
          "fail",
          "거부",
          "拒絕",
          "拒绝",
          "拒否",
          "zamítnout",
          "zamítnuto",
          "rechazar",
          "denegar",
        },
        answer = "DENY",
        hint = L(
          "Same stamp as the replay. One wrong digit, signature dead.",
          "재사용 때와 같은 도장. 한 자리만 틀려도 서명은 죽는다.",
          "同重播一樣嘅印。錯一個數字，簽名就死。",
          "和重放一样的印。错一个数字，签名就死。",
          "リプレイのときと同じスタンプ。1桁違えば署名は死ぬ。",
          "Stejné razítko jako u přehrání. Jedna špatná číslice a podpis je mrtvý.",
          "El mismo sello que el replay. Un dígito mal y la firma muere."
        ),
        ok = L(
          "DENY: issuer signature invalid. Every number in the proof is pinned by an equation.",
          "DENY: 발급자 서명 무효. 증명의 모든 숫자는 식으로 고정되어 있다.",
          "DENY：發行者簽名無效。證明入面每個數字都俾方程釘住。",
          "DENY：签发者签名无效。证明里每个数字都被一个等式钉住。",
          "DENY：発行者の署名が無効。証明の中のすべての数字は式で固定されている。",
          "DENY: neplatný podpis vydavatele. Každé číslo v důkazu drží nějaká rovnice.",
          "DENY: firma del emisor inválida. Cada número de la prueba está clavado por una ecuación."
        ),
      },
      {
        topic = "VERIFY",
        q = L(
          "Alex's real proof, tonight's nonce. Every equation holds and he still does not know 25. Print?",
          "알렉스의 진짜 증명, 오늘 밤의 논스. 모든 식이 성립하고 그는 여전히 25를 모릅니다. 출력은?",
          "阿力嘅真證明，今晚嘅 nonce。每條方程成立，佢仍然唔知 25。印乜？",
          "阿力的真证明，今晚的 nonce。每个等式都成立，他还是不知道 25。打印？",
          "アレックスの本物の証明、今夜のナンス。すべての式が成り立ち、それでも彼は 25 を知りません。表示は？",
          "Alexův pravý důkaz, dnešní nonce. Každá rovnice platí a on pořád neví 25. Výpis?",
          "La prueba real de Alex, el nonce de hoy. Todas las ecuaciones se cumplen y él sigue sin "
            .. "saber 25. ¿Qué imprime?"
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
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): 把 T 和各个 bit
    # 从 C 里除掉后剩下的. 必须是 h^某个数, 即对 0 的承诺.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 OR 证明
        assert bit_verify(C_i, bp, c)
    return "___"
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): C から T とビットを
    # 取り除いたもの。h^何か、つまり 0 へのコミットメント。
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 の OR 証明
        assert bit_verify(C_i, bp, c)
    return "___"
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): C bez T a bez bitů.
    # Musí to být h^něco, čili závazek na 0.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: 0/1 OR-důkaz
        assert bit_verify(C_i, bp, c)
    return "___"
]],
          [[
    # D = C / (g^T * prod C_i^(2^i)): C sin T ni los bits.
    # Debe ser h^algo, es decir un compromiso con 0.
    assert schnorr(D, proof.consistency, c)
    for C_i, bp in zip(bit_C, bit_proofs):  # bp: prueba OR 0/1
        assert bit_verify(C_i, bp, c)
    return "___"
]]
        ),
        accept = {
          "admit",
          "accept",
          "ok",
          "pass",
          "통과",
          "허가",
          "通過",
          "准入",
          "通过",
          "許可",
          "projít",
          "přijmout",
          "aceptar",
          "admitir",
          "pasar",
        },
        answer = "ADMIT",
        hint = L(
          "The green stamp. Opposite of DENY.",
          "초록 도장. DENY의 반대.",
          "綠色印。DENY 嘅相反。",
          "绿色的印。DENY 的反面。",
          "緑のスタンプ。DENY の反対。",
          "Zelené razítko. Opak DENY.",
          "El sello verde. Lo contrario de DENY."
        ),
        ok = L(
          "ADMIT. He learned age >= 18. He did not learn 25.",
          "ADMIT. 그는 age >= 18을 알았고, 25는 몰랐다.",
          "ADMIT。佢知道咗 age >= 18。佢冇知道 25。",
          "ADMIT。他知道了 age >= 18。他并不知道 25。",
          "ADMIT。彼は age >= 18 を知った。25 は知らなかった。",
          "ADMIT. Dozvěděl se age >= 18. Nedozvěděl se 25.",
          "ADMIT. Aprendió age >= 18. No aprendió 25."
        ),
      },
    },
  },
}

return maps
