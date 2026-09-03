-- Quest 2: one map per zk-SNARK step. Answers match rust/src (sudoku.rs,
-- api.rs). Mei solved Uncle Wing's 4x4 wall puzzle. Prize: a free beer.
-- Showing the answer would let the whole queue copy it, so she proves
-- "I have a solution" and shows nothing else.
--
-- Written for someone who has never seen a proof system. Every name that
-- appears in a code block is explained in a comment on the same screen:
-- what it is, who can see it, where it comes from. Same fields as
-- src/data.lua (see the note there).

local function L(en, ko, yue)
  return { en = en, ko = ko, yue = yue }
end

local maps = {
  -- ------------------------------------------------------------ 1 PUZZLE
  {
    id = "puzzle",
    station = "PUZZLE",
    name = L("Lucky Mart, puzzle wall", "럭키 마트, 퍼즐 벽", "幸運士多，謎題牆"),
    title = L("A secret, a statement, a proof", "비밀, 문장, 증명", "一個秘密，一句話，一個證明"),
    lesson = L(
      "The SECRET (witness) is Mei's 16 cells. The STATEMENT is public: 'this board has a solution'.",
      "비밀(witness)은 메이의 16칸. 문장(statement)은 공개: '이 판에는 답이 있다'.",
      "秘密（witness）係阿美嘅 16 格。句子（statement）係公開嘅：「呢個板有答案」。"
    ),
    bg = "bg_store",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美"),
    ground = 348,
    spawn = 160,
    width = 1680,
    npcs = {
      {
        kind = "clerk",
        x = 900,
        facing = 1,
        line = L(
          "Solve my wall puzzle, free beer. Show me the answer.",
          "벽 퍼즐 풀면 맥주 공짜. 답을 보여줘.",
          "解到我幅牆嘅謎題，啤酒免費。畀我睇答案。"
        ),
      },
      {
        kind = "mei",
        x = 1040,
        facing = -1,
        line = L(
          "If I show it, everyone in the queue copies it. I'll PROVE it instead.",
          "보여주면 줄 선 사람들이 다 베끼잖아. 대신 증명할게.",
          "我一畀你睇，成條隊嘅人都會抄。我證明畀你睇。"
        ),
      },
    },
    viz = "puzzle",
    story = L(
      "Uncle Wing's wall puzzle: a 4x4 board. Every row, every column and every 2x2 box must hold "
        .. "1, 2, 3, 4 once each. Some cells are printed (everyone sees them); Mei filled the rest. "
        .. "New quest, new kind of proof: a zk-SNARK. Same promise as quest 1 - convince without revealing.",
      "윙 아저씨의 벽 퍼즐: 4x4 판. 모든 행, 열, 2x2 상자에 1, 2, 3, 4가 한 번씩 들어가야 한다. "
        .. "몇 칸은 인쇄돼 있고(누구나 봄), 나머지는 메이가 채웠다. 새 퀘스트, 새 종류의 증명: "
        .. "zk-SNARK. 약속은 퀘스트 1과 같다 - 보여주지 않고 납득시키기.",
      "榮叔幅牆嘅謎題：一個 4x4 板。每行、每列、每個 2x2 格都要有 1、2、3、4 各一次。"
        .. "有啲格係印咗嘅（人人見到），其餘係阿美填嘅。新任務，新嘅證明種類：zk-SNARK。"
        .. "承諾同任務 1 一樣 - 唔露底都令人信服。"
    ),
    stages = {
      {
        topic = "SECRET",
        q = L(
          "How many cells does Mei keep secret?",
          "메이가 비밀로 지키는 칸은 몇 개?",
          "阿美要保密嘅格有幾多個？"
        ),
        code = L(
          [[
# board:  4 x 4 = 16 cells. Every cell holds 1, 2, 3 or 4
# clues:  numbers printed on the wall. Everyone sees them. 0 = empty
# secret: the numbers Mei wrote. Nobody else sees them
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # public
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # Mei only
len(secret) == ___
]],
          [[
# board:  4 x 4 = 16칸. 칸마다 1, 2, 3, 4 중 하나
# clues:  벽에 인쇄된 숫자. 누구나 본다. 0 = 빈칸
# secret: 메이가 쓴 숫자. 아무도 못 본다
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # 공개
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # 메이만
len(secret) == ___
]],
          [[
# board:  4 x 4 = 16 格。每格係 1、2、3 或 4
# clues:  印喺牆上嘅數字。人人見到。0 = 空格
# secret: 阿美寫嘅數字。冇人見到
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # 公開
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # 只有阿美
len(secret) == ___
]]
        ),
        accept = { "16", "sixteen", "열여섯", "16개", "十六" },
        answer = "16",
        hint = L("4 rows of 4 cells.", "4칸짜리 행이 4개.", "4 行，每行 4 格。"),
        ok = L(
          "16 secret numbers. Uncle Wing will learn that they exist - never what they are.",
          "비밀 숫자 16개. 윙 아저씨는 그것이 존재한다는 것만 알게 되고, 값은 절대 모른다.",
          "16 個秘密數字。榮叔只會知道佢哋存在 - 永遠唔知係乜。"
        ),
      },
      {
        topic = "SECRET",
        q = L(
          "In SNARK words, the secret input is called the ___.",
          "SNARK 용어로, 비밀 입력을 ___라고 부른다.",
          "用 SNARK 嘅講法，秘密輸入叫做 ___。"
        ),
        code = L(
          [[
# statement: the sentence being proven. Public. Everyone reads it
# witness:   the secret that MAKES the sentence true. Private
# prover:    Mei. She holds the witness
# verifier:  Uncle Wing. He sees only the statement and a proof
statement = "the printed board can be completed"
___       = secret     # the 16 numbers, never sent
]],
          [[
# statement: 증명하려는 문장. 공개. 누구나 읽는다
# witness:   그 문장을 참으로 만드는 비밀. 비공개
# prover:    메이. witness를 가진 사람
# verifier:  윙 아저씨. 문장과 증명만 본다
statement = "인쇄된 판은 완성될 수 있다"
___       = secret     # 숫자 16개, 절대 보내지 않음
]],
          [[
# statement: 要證明嘅句子。公開。人人讀到
# witness:   令句子成立嘅秘密。私密
# prover:    阿美。佢有 witness
# verifier:  榮叔。佢只見到句子同一個證明
statement = "印咗嘅板可以填滿"
___       = secret     # 16 個數字，永遠唔會送出去
]]
        ),
        accept = { "witness", "위트니스", "증인", "見證" },
        answer = "witness",
        hint = L(
          "The word for a secret that proves something. Like a person who saw it happen.",
          "무언가를 증명하는 비밀을 부르는 말. 사건을 목격한 사람과 같은 단어.",
          "指「證明到嘢嘅秘密」嘅字。同「目擊者」係同一個字。"
        ),
        ok = L(
          "witness. Prover holds it, verifier never gets it. Quest 1's witness was (age, r).",
          "witness. 증명자가 갖고, 검증자는 절대 받지 않는다. 퀘스트 1의 witness는 (age, r)이었다.",
          "witness。證明者有佢，驗證者永遠攞唔到。任務 1 嘅 witness 係 (age, r)。"
        ),
      },
      {
        topic = "SECRET",
        q = L(
          "The rule: a row holds each of 1, 2, 3, 4 exactly how many times?",
          "규칙: 한 행에는 1, 2, 3, 4가 각각 정확히 몇 번씩 들어가나?",
          "規則：一行入面，1、2、3、4 每個要出現幾多次？"
        ),
        code = L(
          [[
# row: four cells side by side. Same rule for columns and 2x2 boxes
# the rule: 1, 2, 3, 4 each exactly ___ time(s), in any order
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> the row is fine
]],
          [[
# row: 가로로 나란한 네 칸. 열과 2x2 상자도 같은 규칙
# 규칙: 1, 2, 3, 4가 각각 정확히 ___ 번, 순서는 상관없음
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> 이 행은 OK
]],
          [[
# row: 橫排四格。直列同 2x2 格都係同一規則
# 規則：1、2、3、4 每個啱啱 ___ 次，次序不拘
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> 呢行冇問題
]]
        ),
        accept = { "1", "once", "one", "one time", "한 번", "한번", "1번", "一次", "一" },
        answer = "once",
        hint = L("No repeats, nothing missing.", "중복 없이, 빠짐없이.", "冇重複，冇漏。"),
        ok = L(
          "Once each. Next street turns this rule into arithmetic a SNARK can check.",
          "각 한 번씩. 다음 거리에서 이 규칙을 SNARK가 검사할 수 있는 산수로 바꾼다.",
          "各一次。下一條街會將呢條規則變成 SNARK 檢查到嘅算術。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 2 CIRCUIT
  {
    id = "circuit",
    station = "CIRCUIT",
    name = L("Wire alley", "전선 골목", "電線小巷"),
    title = L("Rules become + and x", "규칙이 +와 x가 된다", "規則變成 + 同 x"),
    lesson = L(
      "Every rule becomes + and x only: (v-1)(v-2)(v-3)(v-4) = 0, sum = 10, product = 24.",
      "모든 규칙이 +와 x만으로: (v-1)(v-2)(v-3)(v-4) = 0, 합 = 10, 곱 = 24.",
      "所有規則只用 + 同 x：(v-1)(v-2)(v-3)(v-4) = 0，總和 = 10，乘積 = 24。"
    ),
    bg = "bg_bits",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美"),
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {
      {
        kind = "ken",
        x = 1180,
        facing = -1,
        line = L(
          "A machine can't read 'once each'. It only adds and multiplies.",
          "기계는 '각 한 번씩'을 못 읽어. 더하기 곱하기만 해.",
          "機器唔識讀「各一次」。佢只識加同乘。"
        ),
      },
    },
    viz = "circuit",
    story = L(
      "A SNARK cannot read rules in words. It understands exactly two things: add and multiply. "
        .. "So every rule is rewritten as an equation using only + and x. That rewritten form is "
        .. "called an arithmetic circuit. Quest 1 already did this once: 'b is a bit' became b(b-1) = 0.",
      "SNARK는 말로 된 규칙을 못 읽는다. 아는 것은 딱 둘: 더하기와 곱하기. 그래서 모든 규칙을 "
        .. "+와 x만 쓰는 등식으로 다시 쓴다. 그렇게 다시 쓴 것을 산술 회로(arithmetic circuit)라 한다. "
        .. "퀘스트 1에서 이미 한 번 했다: 'b는 비트다'가 b(b-1) = 0이 됐다.",
      "SNARK 讀唔到文字規則。佢只識兩樣嘢：加同乘。所以每條規則都要改寫成只用 + 同 x 嘅等式。"
        .. "改寫出嚟嘅嘢叫做算術電路（arithmetic circuit）。任務 1 已經做過一次："
        .. "「b 係一個 bit」變成咗 b(b-1) = 0。"
    ),
    stages = {
      {
        topic = "GATES",
        q = L(
          "v is one cell. (v-1)(v-2)(v-3)(v-4) equals ___ exactly when v is 1, 2, 3 or 4.",
          "v는 한 칸의 값. (v-1)(v-2)(v-3)(v-4)는 v가 1, 2, 3, 4일 때만 정확히 ___이다.",
          "v 係一格嘅值。(v-1)(v-2)(v-3)(v-4) 啱啱等於 ___，當且僅當 v 係 1、2、3 或 4。"
        ),
        code = L(
          [[
# v: the value in one cell (secret)
# a product is 0 exactly when one of its factors is 0
# so the line below is 0  <=>  v is 1, 2, 3 or 4
# (quest 1 did the same for bits with  b * (b - 1) = 0)
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]],
          [[
# v: 한 칸의 값 (비밀)
# 곱은 인수 중 하나가 0일 때만 정확히 0이 된다
# 그래서 아래 줄이 0  <=>  v가 1, 2, 3, 4 중 하나
# (퀘스트 1은 비트에 대해 같은 일을 했다:  b * (b - 1) = 0)
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]],
          [[
# v: 一格嘅值（秘密）
# 一個乘積等於 0，當且僅當其中一個因子係 0
# 所以下面呢行係 0  <=>  v 係 1、2、3 或 4
# （任務 1 對 bit 做過同一件事：  b * (b - 1) = 0）
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]]
        ),
        accept = { "0", "zero", "영", "0이다", "零" },
        answer = "0",
        hint = L(
          "v = 3 makes the third bracket (3 - 3) zero.",
          "v = 3이면 세 번째 괄호 (3 - 3)이 0.",
          "v = 3 令第三個括號 (3 - 3) 變成零。"
        ),
        ok = L(
          "0. One line, no words, and a cell can only be 1..4. This is a 'gadget'.",
          "0. 말 없이 한 줄로 칸은 1..4만 가능해진다. 이런 걸 '가젯(gadget)'이라 한다.",
          "0。一行，冇文字，一格就只可以係 1..4。呢樣嘢叫「gadget」。"
        ),
      },
      {
        topic = "GATES",
        q = L(
          "A row holds 1, 2, 3, 4 once each. What do the four cells add up to?",
          "한 행에 1, 2, 3, 4가 한 번씩. 네 칸을 더하면?",
          "一行有 1、2、3、4 各一次。四格加埋係幾多？"
        ),
        code = L(
          [[
# a, b, c, d: the four cells of one row (secret), in any order
# 1 + 2 + 3 + 4 = ___   whatever the order
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]],
          [[
# a, b, c, d: 한 행의 네 칸 (비밀), 순서는 아무거나
# 1 + 2 + 3 + 4 = ___   순서와 무관
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]],
          [[
# a, b, c, d: 一行嘅四格（秘密），次序不拘
# 1 + 2 + 3 + 4 = ___   無論次序點樣
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]]
        ),
        accept = { "10", "ten", "열", "십", "十" },
        answer = "10",
        hint = L("1 + 2 + 3 + 4.", "1 + 2 + 3 + 4.", "1 + 2 + 3 + 4。"),
        ok = L(
          "10. But 4 + 4 + 1 + 1 is also 10, so the sum alone is not enough...",
          "10. 하지만 4 + 4 + 1 + 1도 10이라서 합만으로는 부족하다...",
          "10。但 4 + 4 + 1 + 1 都係 10，所以淨係總和唔夠..."
        ),
      },
      {
        topic = "GATES",
        q = L(
          "...and what do the same four cells multiply to?",
          "...같은 네 칸을 곱하면?",
          "...同樣嘅四格乘埋係幾多？"
        ),
        code = L(
          [[
# same four cells. 1 * 2 * 3 * 4 = ___
# sum 10 AND product ___ happens ONLY for 1, 2, 3, 4
# (the other sum-10 sets give 16, 27, 32 or 36)
a * b * c * d == ___
]],
          [[
# 같은 네 칸. 1 * 2 * 3 * 4 = ___
# 합 10 그리고 곱 ___ 은 오직 1, 2, 3, 4일 때만
# (합이 10인 다른 조합은 곱이 16, 27, 32, 36)
a * b * c * d == ___
]],
          [[
# 同樣嘅四格。1 * 2 * 3 * 4 = ___
# 總和 10 加上乘積 ___ 只有 1、2、3、4 先做到
# （其他總和係 10 嘅組合，乘積係 16、27、32 或 36）
a * b * c * d == ___
]]
        ),
        accept = { "24", "twenty four", "twenty-four", "이십사", "스물넷", "二十四" },
        answer = "24",
        hint = L("1 x 2 x 3 x 4.", "1 x 2 x 3 x 4.", "1 x 2 x 3 x 4。"),
        ok = L(
          "24. Sum 10 plus product 24 = 'each once', said with only + and x.",
          "24. 합 10 더하기 곱 24 = '각 한 번씩'을 +와 x만으로 말한 것.",
          "24。總和 10 加乘積 24 = 用 + 同 x 講出「各一次」。"
        ),
      },
      {
        topic = "GATES",
        q = L(
          "How many multiplications does one cell check take? (additions are free)",
          "칸 하나 검사에 곱셈이 몇 번? (덧셈은 공짜)",
          "檢查一格要乘幾多次？（加法係免費嘅）"
        ),
        code = L(
          [[
# a SNARK counts multiplications; additions cost nothing
# rust/src/sudoku.rs, one cell:
t1 = (v - 1) * (v - 2)     # 1st multiplication
t2 = t1 * (v - 3)          # 2nd
t3 = t2 * (v - 4)          # 3rd -> must equal 0
mults_per_cell = ___
]],
          [[
# SNARK는 곱셈만 센다; 덧셈은 비용이 없다
# rust/src/sudoku.rs, 칸 하나:
t1 = (v - 1) * (v - 2)     # 첫 번째 곱셈
t2 = t1 * (v - 3)          # 두 번째
t3 = t2 * (v - 4)          # 세 번째 -> 0이어야 함
mults_per_cell = ___
]],
          [[
# SNARK 只數乘法；加法唔使錢
# rust/src/sudoku.rs，一格：
t1 = (v - 1) * (v - 2)     # 第 1 次乘
t2 = t1 * (v - 3)          # 第 2 次
t3 = t2 * (v - 4)          # 第 3 次 -> 一定要係 0
mults_per_cell = ___
]]
        ),
        accept = { "3", "three", "셋", "세 번", "3번", "三" },
        answer = "3",
        hint = L("Count the * signs.", "* 기호를 세어보세요.", "數下有幾多個 *。"),
        ok = L(
          "3. Four brackets, three multiplications. t1, t2 are temporaries the circuit keeps.",
          "3. 괄호 넷, 곱셈 셋. t1, t2는 회로가 갖고 있는 임시값.",
          "3。四個括號，三次乘法。t1、t2 係電路保留嘅臨時值。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 3 R1CS
  {
    id = "r1cs",
    station = "R1CS",
    name = L("Ledger office", "장부 사무실", "帳簿辦公室"),
    title = L("One line per multiplication", "곱셈 하나에 한 줄", "每次乘法一行"),
    lesson = L(
      "Each x is one line (A.w) x (B.w) = (C.w). The puzzle is 112 lines over one vector w.",
      "곱셈 하나가 한 줄 (A.w) x (B.w) = (C.w). 퍼즐은 벡터 w 하나 위의 112줄.",
      "每個 x 係一行 (A.w) x (B.w) = (C.w)。個謎題係一個向量 w 上面嘅 112 行。"
    ),
    bg = "bg_office",
    portrait = "portrait_hero",
    speaker = L("Alex (you)", "알렉스 (나)", "阿力 (你)"),
    ground = 348,
    spawn = 160,
    width = 1700,
    npcs = {
      {
        kind = "officer",
        x = 1180,
        facing = -1,
        line = L(
          "Every value on one list. Every multiplication on one line. That's the whole form.",
          "모든 값은 한 목록에. 모든 곱셈은 한 줄에. 그게 양식 전부야.",
          "所有值放喺一張表。每次乘法一行。成張表格就係咁。"
        ),
      },
    },
    viz = "r1cs",
    story = L(
      "Every multiplication of the circuit becomes ONE line of the form (a) x (b) = (c). "
        .. "A list of such lines is an R1CS (rank-1 constraint system; 'constraint' = one line). "
        .. "All values live in a single list w, the witness vector: the constant 1, then the public "
        .. "clues, then Mei's secret cells, then temporaries like t1 and t2.",
      "회로의 곱셈 하나하나가 (a) x (b) = (c) 꼴의 한 줄이 된다. 그런 줄의 목록이 R1CS "
        .. "(rank-1 constraint system; 'constraint' = 줄 하나)다. 모든 값은 한 목록 w, 즉 witness "
        .. "벡터에 산다: 상수 1, 그다음 공개 clues, 그다음 메이의 비밀 칸, 그다음 t1, t2 같은 임시값.",
      "電路每一次乘法都變成一行 (a) x (b) = (c)。呢啲行嘅清單叫 R1CS（rank-1 constraint system；"
        .. "「constraint」= 一行）。所有值都住喺一張表 w，即係 witness 向量：常數 1，然後係公開嘅 clues，"
        .. "然後係阿美嘅秘密格，然後係 t1、t2 呢類臨時值。"
    ),
    stages = {
      {
        topic = "R1CS",
        q = L(
          "w[0] is always the number ___ (so a line can mention plain numbers).",
          "w[0]은 항상 숫자 ___ (그래야 줄에서 보통 숫자를 쓸 수 있다).",
          "w[0] 永遠係數字 ___（咁一行先可以提到普通數字）。"
        ),
        code = L(
          [[
# w: the witness vector - ONE list holding every value the circuit touches
# w[0]      = ___  a fixed constant, so "= 10" can be written as 10 * w[0]
# w[1..16]  the 16 clues (public)
# w[17..32] the 16 secret cells
# w[33..]   temporaries (t1, t2, p1, p2 ...)   -> 89 entries in total
w = [___, 1, 0, 0, 4, ...]
]],
          [[
# w: witness 벡터 - 회로가 건드리는 모든 값을 담은 목록 하나
# w[0]      = ___  고정 상수. 그래야 "= 10"을 10 * w[0]로 쓸 수 있다
# w[1..16]  clues 16개 (공개)
# w[17..32] 비밀 칸 16개
# w[33..]   임시값 (t1, t2, p1, p2 ...)   -> 전부 89개
w = [___, 1, 0, 0, 4, ...]
]],
          [[
# w: witness 向量 - 一張表，裝住電路碰到嘅每一個值
# w[0]      = ___  固定常數，咁「= 10」先可以寫成 10 * w[0]
# w[1..16]  16 個 clues（公開）
# w[17..32] 16 個秘密格
# w[33..]   臨時值（t1、t2、p1、p2 ...）   -> 總共 89 項
w = [___, 1, 0, 0, 4, ...]
]]
        ),
        accept = { "1", "one", "일", "하나", "一" },
        answer = "1",
        hint = L(
          "Multiply anything by it and nothing changes.",
          "무엇을 곱해도 그대로인 수.",
          "乘乜嘢都唔變嘅數。"
        ),
        ok = L(
          "1. With w[0] = 1 the line 'sum = 10' is (a+b+c+d) x 1 = 10 x w[0].",
          "1. w[0] = 1이면 '합 = 10' 줄은 (a+b+c+d) x 1 = 10 x w[0].",
          "1。有咗 w[0] = 1，「總和 = 10」呢行就係 (a+b+c+d) x 1 = 10 x w[0]。"
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "One line is (A.w) x (B.w) = (C.w). For t1 = (v-1)(v-2): A picks v-1, B picks v-2, C picks ___.",
          "한 줄은 (A.w) x (B.w) = (C.w). t1 = (v-1)(v-2)에서 A는 v-1, B는 v-2, C는 ___를 고른다.",
          "一行係 (A.w) x (B.w) = (C.w)。對 t1 = (v-1)(v-2)：A 揀 v-1，B 揀 v-2，C 揀 ___。"
        ),
        code = L(
          [[
# A, B, C: three "pick lists" over w, one triple per line
# A.w picks the left factor, B.w the right factor, C.w the result
# the line for t1 = (v - 1) * (v - 2):
A_w = v - 1          # v is w[17], the 1 is w[0]
B_w = v - 2
C_w = ___            # where the answer of this line is stored
]],
          [[
# A, B, C: w 위의 "고르기 목록" 셋, 줄마다 한 묶음
# A.w는 왼쪽 인수, B.w는 오른쪽 인수, C.w는 결과를 고른다
# t1 = (v - 1) * (v - 2) 줄:
A_w = v - 1          # v는 w[17], 1은 w[0]
B_w = v - 2
C_w = ___            # 이 줄의 답이 저장되는 곳
]],
          [[
# A, B, C: w 上面嘅三張「揀選表」，每行一組
# A.w 揀左邊因子，B.w 揀右邊因子，C.w 揀結果
# t1 = (v - 1) * (v - 2) 呢行：
A_w = v - 1          # v 係 w[17]，個 1 係 w[0]
B_w = v - 2
C_w = ___            # 呢行嘅答案放喺邊
]]
        ),
        accept = { "t1", "t_1", "t 1" },
        answer = "t1",
        hint = L(
          "The temporary that holds (v-1)(v-2).",
          "(v-1)(v-2)를 담는 임시값.",
          "裝住 (v-1)(v-2) 嘅臨時值。"
        ),
        ok = L(
          "t1. A, B, C are the whole circuit; Mei fills w, Uncle Wing keeps A, B, C.",
          "t1. A, B, C가 회로의 전부. 메이는 w를 채우고, 윙 아저씨는 A, B, C를 갖는다.",
          "t1。A、B、C 就係成個電路；阿美填 w，榮叔保留 A、B、C。"
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "How many lines does the whole 4x4 puzzle take?",
          "4x4 퍼즐 전체는 몇 줄?",
          "成個 4x4 謎題要幾多行？"
        ),
        code = L(
          [[
# rust/src/sudoku.rs - counting the lines (each x is one line)
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 12 rows/cols/boxes: sum = 10 (1), product = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]],
          [[
# rust/src/sudoku.rs - 줄 세기 (곱셈 하나 = 한 줄)
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 행/열/상자 12개: 합 = 10 (1), 곱 = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]],
          [[
# rust/src/sudoku.rs - 數行數（每個 x 一行）
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 12 行/列/格：總和 = 10 (1)，乘積 = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]]
        ),
        accept = { "112", "백십이", "一百一十二" },
        answer = "112",
        hint = L("16 + 48 + 48.", "16 + 48 + 48.", "16 + 48 + 48。"),
        ok = L(
          "112 lines. A 9x9 sudoku would be thousands; the proof size will not care.",
          "112줄. 9x9 스도쿠라면 수천 줄; 증명 크기는 신경 쓰지 않는다.",
          "112 行。9x9 數獨會有幾千行；證明大小唔會在乎。"
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "Uncle Wing types the public inputs in himself. How many are there?",
          "윙 아저씨는 공개 입력을 직접 넣는다. 몇 개인가?",
          "榮叔自己輸入公開輸入。有幾多個？"
        ),
        code = L(
          [[
# public inputs: the part of w the verifier fills in HIMSELF
# here: the 16 clues. He never types the secret cells
public_inputs = len(clues)
public_inputs == ___
]],
          [[
# public inputs: 검증자가 직접 채우는 w의 일부
# 여기서는 clues 16개. 비밀 칸은 절대 입력하지 않는다
public_inputs = len(clues)
public_inputs == ___
]],
          [[
# public inputs: 驗證者自己填嘅 w 嘅一部分
# 呢度係 16 個 clues。佢永遠唔會輸入秘密格
public_inputs = len(clues)
public_inputs == ___
]]
        ),
        accept = { "16", "sixteen", "열여섯", "16개", "十六" },
        answer = "16",
        hint = L("One per cell of the board.", "판의 칸마다 하나.", "板上每格一個。"),
        ok = L(
          "16. A proof is tied to these 16 numbers; change a clue and it stops verifying.",
          "16. 증명은 이 16개 숫자에 묶여 있다; clue 하나만 바꿔도 검증이 실패한다.",
          "16。證明同呢 16 個數字綁埋一齊；改一個 clue 就驗證唔到。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 4 QAP
  {
    id = "qap",
    station = "QAP",
    name = L("Curve street", "곡선 거리", "曲線街"),
    title = L("112 checks become one", "112개 검사가 하나로", "112 個檢查變成一個"),
    lesson = L(
      "112 lines become one polynomial identity A.B - C = H.Z, checked at ONE secret point tau.",
      "112줄이 다항식 등식 하나 A.B - C = H.Z가 되고, 비밀 점 tau 하나에서만 검사한다.",
      "112 行變成一條多項式恆等式 A.B - C = H.Z，只喺一個秘密點 tau 檢查。"
    ),
    bg = "bg_sigma",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美"),
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {
      {
        kind = "ken",
        x = 1180,
        facing = -1,
        line = L(
          "Checking 112 lines one by one is slow. Check them all at once instead.",
          "112줄을 하나씩 검사하면 느려. 한꺼번에 검사해.",
          "112 行逐行檢查好慢。不如一次過檢查晒。"
        ),
      },
    },
    viz = "qap",
    story = L(
      "112 lines are 112 things to check. A SNARK squeezes them into ONE equation about "
        .. "polynomials (curves). Number the lines 1..112 and build curves A(x), B(x), C(x) so that "
        .. "at x = k they give line k's values. Then ALL lines hold exactly when A(x).B(x) - C(x) "
        .. "is zero at x = 1, 2, ..., 112. This form is the QAP (quadratic arithmetic program).",
      "112줄은 검사할 것 112개. SNARK는 이것을 다항식(곡선)에 대한 등식 하나로 압축한다. "
        .. "줄에 1..112 번호를 붙이고, x = k에서 k번째 줄의 값을 내는 곡선 A(x), B(x), C(x)를 만든다. "
        .. "그러면 모든 줄이 성립한다 <=> A(x).B(x) - C(x)가 x = 1, 2, ..., 112에서 0. "
        .. "이 형태가 QAP(quadratic arithmetic program)다.",
      "112 行就係 112 樣要檢查嘅嘢。SNARK 將佢哋壓縮成一條關於多項式（曲線）嘅等式。"
        .. "將行編號 1..112，砌出曲線 A(x)、B(x)、C(x)，令 x = k 時畀出第 k 行嘅值。"
        .. "咁樣所有行成立 <=> A(x).B(x) - C(x) 喺 x = 1, 2, ..., 112 都係零。"
        .. "呢個形式叫 QAP（quadratic arithmetic program）。"
    ),
    stages = {
      {
        topic = "QAP",
        q = L(
          "Z(x) = (x-1)(x-2)...(x-112). What is Z(5)?",
          "Z(x) = (x-1)(x-2)...(x-112). Z(5)는?",
          "Z(x) = (x-1)(x-2)...(x-112)。Z(5) 係幾多？"
        ),
        code = L(
          [[
# Z(x): the "vanishing polynomial" - built to be 0 at EVERY line number
# x: just a variable; k runs over the line numbers 1..112
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # one factor is (5 - 5)
]],
          [[
# Z(x): "소멸 다항식(vanishing polynomial)" - 모든 줄 번호에서 0이 되도록 만든 것
# x: 그냥 변수; k는 줄 번호 1..112를 돈다
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # 인수 중 하나가 (5 - 5)
]],
          [[
# Z(x): 「消失多項式（vanishing polynomial）」- 砌到喺每個行號都係 0
# x: 只係一個變數；k 行過所有行號 1..112
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # 其中一個因子係 (5 - 5)
]]
        ),
        accept = { "0", "zero", "영", "零" },
        answer = "0",
        hint = L(
          "Same trick as (v-1)(v-2)(v-3)(v-4): one zero factor kills the product.",
          "(v-1)(v-2)(v-3)(v-4)와 같은 트릭: 0인 인수 하나가 곱 전체를 0으로.",
          "同 (v-1)(v-2)(v-3)(v-4) 一樣嘅招數：一個零因子令成個乘積變零。"
        ),
        ok = L(
          "0. Z is zero at 1..112 and nowhere else. It marks 'the line numbers'.",
          "0. Z는 1..112에서만 0. '줄 번호들'을 표시하는 다항식.",
          "0。Z 只喺 1..112 係零。佢標記住「啲行號」。"
        ),
      },
      {
        topic = "QAP",
        q = L(
          "If every line holds, dividing A.B - C by Z leaves remainder ___.",
          "모든 줄이 성립하면, A.B - C를 Z로 나눈 나머지는 ___.",
          "如果每行都成立，A.B - C 除以 Z 嘅餘數係 ___。"
        ),
        code = L(
          [[
# A(x), B(x), C(x): one curve per pick-list, agreeing with line k at x = k
# H(x): the quotient. Mei computes it; it EXISTS only if every line holds
# (a broken line leaves a nonzero remainder, and no H can hide it)
A(x) * B(x) - C(x) == H(x) * Z(x)     # remainder ___
]],
          [[
# A(x), B(x), C(x): 고르기 목록마다 곡선 하나, x = k에서 k번째 줄과 일치
# H(x): 몫. 메이가 계산한다; 모든 줄이 성립할 때만 존재한다
# (깨진 줄이 있으면 0이 아닌 나머지가 남고, 어떤 H도 그걸 숨길 수 없다)
A(x) * B(x) - C(x) == H(x) * Z(x)     # 나머지 ___
]],
          [[
# A(x), B(x), C(x): 每張揀選表一條曲線，喺 x = k 同第 k 行一致
# H(x): 商。阿美計出嚟；只有每行都成立先存在
# （有一行壞咗就會剩低非零餘數，冇 H 遮得住）
A(x) * B(x) - C(x) == H(x) * Z(x)     # 餘數 ___
]]
        ),
        accept = { "0", "zero", "none", "nothing", "영", "없음", "零", "冇" },
        answer = "0",
        hint = L(
          "'Divides exactly' means what remainder?",
          "'딱 나누어떨어진다'는 나머지가 얼마라는 뜻?",
          "「啱啱除得盡」即係餘數係幾多？"
        ),
        ok = L(
          "0. Mei's proof will really be: 'here is H, the division worked'.",
          "0. 메이의 증명은 결국 '여기 H가 있다, 나눗셈이 됐다'는 말이다.",
          "0。阿美嘅證明其實就係：「H 喺度，除到盡」。"
        ),
      },
      {
        topic = "QAP",
        q = L(
          "Check at ONE random point instead of 112. Two different curves can agree on at most as many points as their ___.",
          "112개 대신 무작위 점 하나에서 검사. 서로 다른 두 곡선이 겹칠 수 있는 점의 수는 최대 그 ___만큼.",
          "唔使檢查 112 個點，淨係檢查一個隨機點。兩條唔同嘅曲線最多只可以喺 ___ 咁多個點重合。"
        ),
        code = L(
          [[
# tau: a secret random number, chosen once at setup (next street)
# checking A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) at ONE point is enough:
# two different curves can agree on at most `___` many points
# (here about 112 points, out of ~2^254 possible taus: a cheat almost never hits)
degree_of_A = 111
]],
          [[
# tau: 비밀 무작위 수, setup에서 한 번 고른다 (다음 거리)
# A(tau)*B(tau) - C(tau) == H(tau)*Z(tau)를 점 하나에서만 검사해도 충분:
# 서로 다른 두 곡선이 겹칠 수 있는 점은 최대 `___`개
# (여기서는 약 112개, 가능한 tau는 ~2^254개: 속임수는 거의 절대 못 맞춘다)
degree_of_A = 111
]],
          [[
# tau: 一個秘密隨機數，喺 setup 揀一次（下一條街）
# 淨係喺一個點檢查 A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) 已經夠：
# 兩條唔同嘅曲線最多只可以喺 `___` 咁多個點重合
# （呢度大約 112 個點，而可能嘅 tau 有 ~2^254 個：作弊幾乎永遠撞唔中）
degree_of_A = 111
]]
        ),
        accept = { "degree", "d", "차수", "次數", "度數" },
        answer = "degree",
        hint = L(
          "The highest power of x in the curve. A straight line has 1, a parabola 2.",
          "곡선에서 x의 최고 차수. 직선은 1, 포물선은 2.",
          "曲線入面 x 嘅最高次方。直線係 1，拋物線係 2。"
        ),
        ok = L(
          "degree. This is the Schwartz-Zippel idea: one random point is as good as all of them.",
          "degree(차수). 슈와르츠-지펠 아이디어: 무작위 점 하나가 모든 점만큼 좋다.",
          "degree（次數）。呢個係 Schwartz-Zippel 嘅諗法：一個隨機點同全部點一樣好。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 5 SETUP
  {
    id = "setup",
    station = "SETUP",
    name = L("Ceremony hall", "의식 홀", "儀式大堂"),
    title = L("Toxic waste and two keys", "독성 폐기물과 열쇠 둘", "有毒廢料同兩條鎖匙"),
    lesson = L(
      "Setup hides tau, alpha, beta, gamma, delta in curve points, hands out pk and vk, and must delete the toxic waste.",
      "Setup은 tau, alpha, beta, gamma, delta를 곡선 점 안에 숨기고 pk와 vk를 나눠 준 뒤, 독성 폐기물을 반드시 지운다.",
      "Setup 將 tau、alpha、beta、gamma、delta 藏入曲線點，派出 pk 同 vk，然後一定要銷毀有毒廢料。"
    ),
    bg = "bg_office",
    portrait = "portrait_officer",
    speaker = L("Ceremony host", "의식 진행자", "儀式主持"),
    ground = 348,
    spawn = 160,
    width = 1700,
    npcs = {
      {
        kind = "officer",
        x = 1300,
        facing = -1,
        line = L(
          "I draw the random numbers, seal them into points, and burn the paper.",
          "무작위 수를 뽑고, 점 안에 봉인하고, 종이는 태운다.",
          "我抽隨機數，封入點入面，然後燒咗張紙。"
        ),
      },
    },
    viz = "setup",
    story = L(
      "Before any proof, a one-time setup. Random secrets are drawn: tau (the check point) and "
        .. "alpha, beta, gamma, delta (glue that stops cheating). They are hidden inside curve points - "
        .. "like g^tau in quest 1, you can compute WITH the number but cannot read it - and then DELETED. "
        .. "What remains are two keys: pk (big, for Mei) and vk (small, for Uncle Wing).",
      "증명 전에 딱 한 번 setup. 무작위 비밀을 뽑는다: tau(검사 지점)와 alpha, beta, gamma, delta"
        .. "(속임수를 막는 접착제). 이들은 곡선 점 안에 숨겨진다 - 퀘스트 1의 g^tau처럼 그 수로 계산은 "
        .. "할 수 있지만 읽을 수는 없다 - 그리고 삭제된다. 남는 것은 열쇠 둘: pk(크다, 메이용)와 "
        .. "vk(작다, 윙 아저씨용).",
      "證明之前，先做一次 setup。抽出隨機秘密：tau（檢查點）同 alpha、beta、gamma、delta"
        .. "（防止作弊嘅膠水）。佢哋藏喺曲線點入面 - 好似任務 1 嘅 g^tau，可以用個數字計嘢但讀唔到佢 - "
        .. "然後就銷毀。剩低兩條鎖匙：pk（大，畀阿美）同 vk（細，畀榮叔）。"
    ),
    stages = {
      {
        topic = "SETUP",
        q = L(
          "After the setup, tau and friends must be ___ (whoever keeps them can forge proofs).",
          "setup이 끝나면 tau와 친구들은 반드시 ___ (갖고 있는 사람은 증명을 위조할 수 있다).",
          "setup 完咗之後，tau 同佢啲朋友一定要 ___（邊個留住就可以偽造證明）。"
        ),
        code = L(
          [[
# setup: run ONCE per circuit, before any proof. rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: random secrets = the "toxic waste"
# [tau]G, [tau^2]G, ...: the same numbers hidden inside curve points
#                        (G is a fixed point; [n]G = "G added to itself n times")
# after the points are made, the plain numbers are ___
]],
          [[
# setup: 회로마다 한 번, 증명 전에 실행. rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: 무작위 비밀 = "독성 폐기물(toxic waste)"
# [tau]G, [tau^2]G, ...: 같은 수를 곡선 점 안에 숨긴 것
#                        (G는 고정된 점; [n]G = "G를 n번 더한 것")
# 점을 만든 뒤, 원래 숫자들은 ___
]],
          [[
# setup: 每個電路做一次，喺任何證明之前。rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: 隨機秘密 = 「有毒廢料（toxic waste）」
# [tau]G, [tau^2]G, ...: 同樣嘅數字藏喺曲線點入面
#                        （G 係固定嘅點；[n]G = 「G 自己加自己 n 次」）
# 點整好之後，原本嘅數字就 ___
]]
        ),
        accept = {
          "deleted",
          "delete",
          "destroyed",
          "burned",
          "burnt",
          "erased",
          "thrown away",
          "forgotten",
          "삭제",
          "삭제된다",
          "지운다",
          "지워야",
          "파기",
          "폐기",
          "태운다",
          "銷毀",
          "刪除",
          "燒咗",
        },
        answer = "deleted",
        hint = L(
          "The host burns the paper.",
          "진행자가 종이를 태운다.",
          "主持燒咗張紙。"
        ),
        ok = L(
          "deleted. Note: rust/src/api.rs uses a FIXED seed for study. Real systems run a ceremony with many people.",
          "삭제. 참고: rust/src/api.rs는 공부용으로 고정 시드를 쓴다. 실제 시스템은 여러 사람이 참여하는 의식을 연다.",
          "銷毀。留意：rust/src/api.rs 用固定種子嚟學習。真正嘅系統會搞多人參與嘅儀式。"
        ),
      },
      {
        topic = "SETUP",
        q = L(
          "Two keys come out. Mei, the prover, gets the ___ key.",
          "열쇠 둘이 나온다. 증명자 메이가 받는 것은 ___ 키.",
          "出到兩條鎖匙。證明者阿美攞 ___ 鎖匙。"
        ),
        code = L(
          [[
# pk: proving key.   22736 bytes here. Holds [tau^i]G for the whole circuit
# vk: verifying key.   776 bytes here. Just a few points
# both are public; the size difference is the point
prover_key   = ___    # Mei
verifier_key = vk     # Uncle Wing
]],
          [[
# pk: proving key(증명 키).   여기서는 22736바이트. 회로 전체의 [tau^i]G를 담는다
# vk: verifying key(검증 키).   여기서는 776바이트. 점 몇 개뿐
# 둘 다 공개; 크기 차이가 핵심
prover_key   = ___    # 메이
verifier_key = vk     # 윙 아저씨
]],
          [[
# pk: proving key（證明鎖匙）。呢度 22736 bytes。裝住成個電路嘅 [tau^i]G
# vk: verifying key（驗證鎖匙）。呢度 776 bytes。得幾個點
# 兩條都係公開嘅；重點係大小嘅分別
prover_key   = ___    # 阿美
verifier_key = vk     # 榮叔
]]
        ),
        accept = { "pk", "proving", "proving key", "prover key", "증명", "증명 키", "증명키", "證明", "證明鎖匙" },
        answer = "pk",
        hint = L("p for prover.", "p는 prover(증명자).", "p 代表 prover。"),
        ok = L(
          "pk. Big key for the one who does the work, small key for the one who checks.",
          "pk. 일하는 쪽은 큰 열쇠, 확인하는 쪽은 작은 열쇠.",
          "pk。做嘢嗰個攞大鎖匙，檢查嗰個攞細鎖匙。"
        ),
      },
      {
        topic = "SETUP",
        q = L(
          "The keys are baked for THIS circuit. A 9x9 board would need a new ___.",
          "이 열쇠는 이 회로 전용. 9x9 판이면 새 ___이 필요하다.",
          "呢啲鎖匙係為呢個電路整嘅。9x9 板就要新嘅 ___。"
        ),
        code = L(
          [[
# Groth16 keys are circuit-specific: the 112 lines are baked into pk and vk
# change the circuit (a 9x9 board, a new rule) -> run a new ___
# (other SNARKs, like PLONK, reuse one setup for many circuits)
]],
          [[
# Groth16 열쇠는 회로 전용: 112줄이 pk와 vk 안에 구워져 있다
# 회로가 바뀌면 (9x9 판, 새 규칙) -> 새 ___ 실행
# (PLONK 같은 다른 SNARK는 setup 하나를 여러 회로에 재사용한다)
]],
          [[
# Groth16 鎖匙係電路專用嘅：112 行焗咗入 pk 同 vk
# 改電路（9x9 板、新規則）-> 做一次新嘅 ___
# （PLONK 呢類其他 SNARK 可以一個 setup 用喺好多電路）
]]
        ),
        accept = { "setup", "trusted setup", "ceremony", "셋업", "세팅", "설정", "의식", "設置", "儀式" },
        answer = "setup",
        hint = L("This street's name.", "이 거리의 이름.", "呢條街嘅名。"),
        ok = L(
          "setup. That is the price of Groth16's tiny proofs.",
          "setup. Groth16의 아주 작은 증명이 치르는 대가.",
          "setup。呢個就係 Groth16 超細證明嘅代價。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 6 PAIRING
  {
    id = "pairing",
    station = "PAIRING",
    name = L("Mirror lane", "거울 골목", "鏡巷"),
    title = L("Multiply behind the curtain", "커튼 뒤에서 곱하기", "喺布簾後面乘"),
    lesson = L(
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): the ONE hidden multiplication the check needs.",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): 검사에 필요한 단 한 번의 숨은 곱셈.",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b)：檢查需要嘅唯一一次隱藏乘法。"
    ),
    bg = "bg_hash",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔"),
    ground = 348,
    spawn = 160,
    width = 1760,
    npcs = {
      {
        kind = "clerk",
        x = 1180,
        facing = -1,
        line = L(
          "I can add sealed numbers. To multiply two, I need this mirror.",
          "봉인된 수는 더할 수 있어. 둘을 곱하려면 이 거울이 필요해.",
          "封咗嘅數我加到。要乘兩個，就要呢面鏡。"
        ),
      },
    },
    viz = "pairing",
    story = L(
      "Uncle Wing holds vk and the proof. Every number inside is hidden in a curve point. Hidden "
        .. "numbers can be ADDED (quest 1: g^a . g^b = g^(a+b)), but the check A(tau).B(tau) needs one "
        .. "MULTIPLICATION of hidden numbers. A pairing e(P, Q) is exactly that: one G1 point and one "
        .. "G2 point go in, and out comes e(G1, G2) raised to the PRODUCT of the hidden numbers.",
      "윙 아저씨는 vk와 증명을 갖고 있다. 안의 모든 수는 곡선 점 안에 숨어 있다. 숨은 수는 더할 수 있다"
        .. "(퀘스트 1: g^a . g^b = g^(a+b)). 그런데 검사 A(tau).B(tau)에는 숨은 수끼리의 곱셈 한 번이 필요하다. "
        .. "페어링 e(P, Q)가 바로 그것: G1 점 하나와 G2 점 하나가 들어가면, 숨은 두 수의 곱을 지수로 하는 "
        .. "e(G1, G2)가 나온다.",
      "榮叔手上有 vk 同證明。入面每個數字都藏喺曲線點入面。藏起嘅數可以加（任務 1：g^a . g^b = g^(a+b)），"
        .. "但檢查 A(tau).B(tau) 需要隱藏數之間乘一次。配對 e(P, Q) 就係咁：入一個 G1 點同一個 G2 點，"
        .. "出嚟嘅係 e(G1, G2) 嘅「兩個隱藏數嘅乘積」次方。"
    ),
    stages = {
      {
        topic = "PAIRING",
        q = L(
          "e([3]G1, [5]G2) = e(G1, G2)^___",
          "e([3]G1, [5]G2) = e(G1, G2)^___",
          "e([3]G1, [5]G2) = e(G1, G2)^___"
        ),
        code = L(
          [[
# G1, G2: two groups of points on the curve BN254. [a]G1 = "the point hiding a"
# e(P, Q): the pairing. Takes one G1 point and one G2 point, lands in a
#          third group GT. The rule that makes it useful:
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- multiplies the hidden numbers
e([3]G1, [5]G2) == e(G1, G2) ** ___
]],
          [[
# G1, G2: 곡선 BN254 위 점들의 두 그룹. [a]G1 = "a를 숨긴 점"
# e(P, Q): 페어링. G1 점 하나와 G2 점 하나를 받아 세 번째 그룹 GT에
#          내려놓는다. 이걸 쓸모 있게 만드는 규칙:
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- 숨은 수를 곱한다
e([3]G1, [5]G2) == e(G1, G2) ** ___
]],
          [[
# G1, G2: 曲線 BN254 上面兩組點。[a]G1 = 「藏住 a 嘅點」
# e(P, Q): 配對。攞一個 G1 點同一個 G2 點，落喺第三組 GT。
#          令佢有用嘅規則：
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- 將隱藏數乘埋
e([3]G1, [5]G2) == e(G1, G2) ** ___
]]
        ),
        accept = { "15", "fifteen", "십오", "열다섯", "十五" },
        answer = "15",
        hint = L("3 x 5.", "3 x 5.", "3 x 5。"),
        ok = L(
          "15. Neither 3 nor 5 was ever visible; their product appeared anyway.",
          "15. 3도 5도 한 번도 보이지 않았지만, 곱은 나타났다.",
          "15。3 同 5 由頭到尾都冇露面，佢哋嘅乘積照樣出現。"
        ),
      },
      {
        topic = "PAIRING",
        q = L(
          "Groth16 verify is one line: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). How many pairings?",
          "Groth16 검증은 한 줄: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). 페어링 몇 번?",
          "Groth16 驗證就一行：e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta)。幾多次配對？"
        ),
        code = L(
          [[
# A, B, C: the three points of the proof (A, C in G1; B in G2)
# alpha, beta, gamma, delta: points from vk (the setup's glue)
# L: one point Uncle Wing builds HIMSELF from the 16 clues and vk
#    (so a proof for a different board fails right here)
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ___ pairings
]],
          [[
# A, B, C: 증명의 점 셋 (A, C는 G1; B는 G2)
# alpha, beta, gamma, delta: vk에서 온 점들 (setup의 접착제)
# L: 윙 아저씨가 clues 16개와 vk로 직접 만드는 점 하나
#    (그래서 다른 판의 증명은 바로 여기서 실패한다)
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # 페어링 ___번
]],
          [[
# A, B, C: 證明嘅三個點（A、C 喺 G1；B 喺 G2）
# alpha, beta, gamma, delta: 嚟自 vk 嘅點（setup 嘅膠水）
# L: 榮叔自己用 16 個 clues 同 vk 砌出嚟嘅一個點
#    （所以另一塊板嘅證明喺呢度即刻死）
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ___ 次配對
]]
        ),
        accept = { "4", "four", "넷", "네 번", "4번", "四" },
        answer = "4",
        hint = L("Count the e( ).", "e( )를 세어보세요.", "數下有幾多個 e( )。"),
        ok = L(
          "4. rust/src/api.rs: 1.5 ms. The same four whether the circuit has 112 lines or a million.",
          "4. rust/src/api.rs: 1.5ms. 회로가 112줄이든 백만 줄이든 똑같이 네 번.",
          "4。rust/src/api.rs：1.5 ms。電路 112 行定一百萬行，都係四次。"
        ),
      },
      {
        topic = "PAIRING",
        q = L(
          "A and C live in G1, B in G2. Both sides of the check live in ___.",
          "A와 C는 G1에, B는 G2에 산다. 검사식의 양변은 ___에 산다.",
          "A 同 C 住喺 G1，B 住喺 G2。檢查式兩邊住喺 ___。"
        ),
        code = L(
          [[
# where things live on BN254:
# A, C  -> G1   (32 bytes each, compressed)
# B     -> G2   (64 bytes: its coordinates are pairs of numbers)
# e(.,.) output, both sides of the check -> ___
]],
          [[
# BN254에서 각자 사는 곳:
# A, C  -> G1   (압축하면 각 32바이트)
# B     -> G2   (64바이트: 좌표가 수의 쌍이라서)
# e(.,.)의 출력, 검사식의 양변 -> ___
]],
          [[
# 喺 BN254 上面各自住邊：
# A, C  -> G1   （壓縮後各 32 bytes）
# B     -> G2   （64 bytes：佢嘅座標係數對）
# e(.,.) 嘅輸出，檢查式兩邊 -> ___
]]
        ),
        accept = { "gt", "g_t", "g t", "target group", "타깃 그룹", "目標群" },
        answer = "GT",
        hint = L("G with a T: the Target group.", "G에 T: Target 그룹.", "G 加 T：Target 群。"),
        ok = L(
          "GT. Three groups, one bridge between them. That bridge is the whole reason for the curve.",
          "GT. 그룹 셋, 그 사이 다리 하나. 그 다리가 이 곡선을 쓰는 이유의 전부다.",
          "GT。三組，中間一條橋。呢條橋就係用呢條曲線嘅全部原因。"
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 7 PROOF
  {
    id = "proof",
    station = "PROOF",
    name = L("Lucky Mart, the counter", "럭키 마트, 계산대", "幸運士多，收銀處"),
    title = L("128 bytes, 4 pairings, done", "128바이트, 페어링 4번, 끝", "128 bytes，4 次配對，搞掂"),
    lesson = L(
      "3 points, 128 bytes, 4 pairings - the same for ANY circuit. That is 'succinct'.",
      "점 3개, 128바이트, 페어링 4번 - 어떤 회로든 똑같다. 그것이 '간결(succinct)'.",
      "3 個點，128 bytes，4 次配對 - 任何電路都一樣。呢個就係「簡潔（succinct）」。"
    ),
    bg = "bg_store",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美"),
    ground = 348,
    spawn = 160,
    width = 1680,
    npcs = {
      {
        kind = "clerk",
        x = 1160,
        facing = 1,
        line = L(
          "128 bytes and my four mirrors say yes. Beer's yours. Answer's still yours too.",
          "128바이트에 거울 넷이 그렇다고 하네. 맥주는 네 거야. 답도 여전히 네 거고.",
          "128 bytes，四面鏡都話得。啤酒係你嘅。答案都仲係你嘅。"
        ),
      },
      {
        kind = "mei",
        x = 1290,
        facing = -1,
        line = L(
          "prove() on my phone, verify() on his. Real Groth16, running in Rust right now.",
          "내 폰에서 prove(), 아저씨 폰에서 verify(). 지금 러스트로 도는 진짜 Groth16.",
          "我部電話行 prove()，佢部電話行 verify()。真正嘅 Groth16，而家用 Rust 行緊。"
        ),
      },
    },
    viz = "proof",
    story = L(
      "Back at the counter. Mei's phone runs prove(): in go pk, the clues and her 16 cells; out come "
        .. "128 bytes - three points A, B, C. Uncle Wing runs verify(): vk, the clues, the proof, four "
        .. "pairings, about a millisecond. Same size and same time for a 4x4 or a million-line circuit. "
        .. "Above, the real thing is running: Rust + arkworks, reached from this game over ffi.",
      "다시 계산대. 메이의 폰이 prove()를 돌린다: pk, clues, 그리고 비밀 16칸이 들어가고 128바이트 - "
        .. "점 셋 A, B, C - 가 나온다. 윙 아저씨는 verify(): vk, clues, 증명, 페어링 네 번, 약 1밀리초. "
        .. "4x4든 백만 줄 회로든 같은 크기, 같은 시간. 위 화면에서 진짜가 돌고 있다: 러스트 + arkworks, "
        .. "이 게임에서 ffi로 호출.",
      "返到收銀處。阿美部電話行 prove()：入 pk、clues 同佢嘅 16 格；出 128 bytes - 三個點 A、B、C。"
        .. "榮叔行 verify()：vk、clues、證明，四次配對，大約一毫秒。4x4 定一百萬行嘅電路，一樣大小、"
        .. "一樣時間。上面真嘢行緊：Rust + arkworks，由呢個遊戲經 ffi 叫出嚟。"
    ),
    stages = {
      {
        topic = "PROOF",
        q = L(
          "The proof is exactly ___ curve points.",
          "증명은 정확히 곡선 점 ___개.",
          "證明啱啱係 ___ 個曲線點。"
        ),
        code = L(
          [[
# rust/src/api.rs prove():   in: pk, clues, secret    out: proof
# proof = (A, B, C)  three points; nothing about the 16 cells survives in them
# (like quest 1's (t, s): a real proof is a few numbers, not the secret)
points_in_proof = ___
]],
          [[
# rust/src/api.rs prove():   입력: pk, clues, secret    출력: proof
# proof = (A, B, C)  점 셋; 16칸에 대한 정보는 그 안에 남지 않는다
# (퀘스트 1의 (t, s)처럼: 진짜 증명은 숫자 몇 개지, 비밀이 아니다)
points_in_proof = ___
]],
          [[
# rust/src/api.rs prove():   入：pk、clues、secret    出：proof
# proof = (A, B, C)  三個點；關於 16 格嘅嘢一啲都冇留喺入面
# （好似任務 1 嘅 (t, s)：真正嘅證明係幾個數字，唔係秘密）
points_in_proof = ___
]]
        ),
        accept = { "3", "three", "셋", "세 개", "3개", "三" },
        answer = "3",
        hint = L("A, B and C.", "A, B, C.", "A、B 同 C。"),
        ok = L(
          "3. A and C in G1, B in G2 - the ones the pairing check eats.",
          "3. A와 C는 G1, B는 G2 - 페어링 검사가 먹는 바로 그 점들.",
          "3。A 同 C 喺 G1，B 喺 G2 - 就係配對檢查食嘅嗰啲點。"
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Sizes: A 32 + B 64 + C 32 = ___ bytes.",
          "크기: A 32 + B 64 + C 32 = ___바이트.",
          "大小：A 32 + B 64 + C 32 = ___ bytes。"
        ),
        code = L(
          [[
# compressed: a curve point stored as one coordinate plus one sign bit
A_bytes = 32       # G1 point
B_bytes = 64       # G2 point (coordinates are pairs)
C_bytes = 32       # G1 point
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]],
          [[
# 압축: 곡선 점을 좌표 하나 + 부호 비트 하나로 저장
A_bytes = 32       # G1 점
B_bytes = 64       # G2 점 (좌표가 쌍)
C_bytes = 32       # G1 점
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]],
          [[
# 壓縮：一個曲線點淨係存一個座標加一個正負號 bit
A_bytes = 32       # G1 點
B_bytes = 64       # G2 點（座標係數對）
C_bytes = 32       # G1 點
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]]
        ),
        accept = { "128", "백이십팔", "一百二十八" },
        answer = "128",
        hint = L("32 + 64 + 32.", "32 + 64 + 32.", "32 + 64 + 32。"),
        ok = L(
          "128 bytes. Quest 1's proof was several KB and grew with every bit.",
          "128바이트. 퀘스트 1의 증명은 몇 KB였고 비트마다 커졌다.",
          "128 bytes。任務 1 嘅證明有幾 KB，每多一個 bit 就大啲。"
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Does the proof size grow with the circuit? (yes / no)",
          "증명 크기가 회로와 함께 커지나? (yes / no)",
          "證明大小會唔會跟住電路變大？（yes / no）"
        ),
        code = L(
          [[
# succinct: proof size AND verify time do not depend on the circuit size
# 112 lines or 1,000,000 lines: still A, B, C - still 4 pairings
# (only Mei's prove() gets slower with a bigger circuit)
proof_grows_with_circuit = "___"      # yes / no
]],
          [[
# succinct(간결): 증명 크기와 검증 시간이 회로 크기와 무관
# 112줄이든 1,000,000줄이든: 여전히 A, B, C - 여전히 페어링 4번
# (회로가 커지면 메이의 prove()만 느려진다)
proof_grows_with_circuit = "___"      # yes / no
]],
          [[
# succinct（簡潔）：證明大小同驗證時間都唔取決於電路大小
# 112 行定 1,000,000 行：都係 A、B、C - 都係 4 次配對
# （電路大咗，淨係阿美嘅 prove() 會慢啲）
proof_grows_with_circuit = "___"      # yes / no
]]
        ),
        accept = { "no", "never", "nope", "false", "constant", "아니오", "아니요", "아니", "아니다", "唔會", "唔係", "不", "否" },
        answer = "no",
        hint = L(
          "That is what the S in SNARK stands for.",
          "SNARK의 S가 뜻하는 바로 그것.",
          "SNARK 個 S 就係講呢樣嘢。"
        ),
        ok = L(
          "no. Succinct. The verifier's work is tiny no matter how big the secret computation was.",
          "no. 간결하다. 비밀 계산이 아무리 커도 검증자의 일은 아주 작다.",
          "no。簡潔。無論秘密計算有幾大，驗證者嘅工作都好細。"
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Uncle Wing's verdict when e(A,B) equals the right-hand side:",
          "e(A,B)가 우변과 같을 때 윙 아저씨의 판정:",
          "當 e(A,B) 等於右邊嗰陣，榮叔嘅裁決："
        ),
        code = L(
          [[
# rust/src/api.rs verify():   in: vk, clues, proof     out: yes / no
# L: built from the 16 clues; a proof for another board fails here
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]],
          [[
# rust/src/api.rs verify():   입력: vk, clues, proof     출력: yes / no
# L: clues 16개로 만든다; 다른 판의 증명은 여기서 실패
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]],
          [[
# rust/src/api.rs verify():   入：vk、clues、proof     出：yes / no
# L: 用 16 個 clues 砌；另一塊板嘅證明喺度失敗
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]]
        ),
        accept = { "accept", "admit", "ok", "pass", "yes", "통과", "허가", "승인", "接受", "通過", "批准" },
        answer = "ACCEPT",
        hint = L(
          "The opposite of REJECT.",
          "REJECT의 반대.",
          "REJECT 嘅相反。"
        ),
        ok = L(
          "ACCEPT. He learned: the board has a solution. He did not learn: any of the 16 cells.",
          "ACCEPT. 그가 알게 된 것: 판에 답이 있다. 모르는 것: 16칸 중 그 어떤 값도.",
          "ACCEPT。佢知道咗：塊板有答案。佢唔知道：16 格入面任何一個。"
        ),
      },
    },
  },
}

return maps
