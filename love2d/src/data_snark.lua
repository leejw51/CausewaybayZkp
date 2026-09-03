-- Quest 2: one map per zk-SNARK step. Answers match rust/src (sudoku.rs,
-- api.rs). Mei solved Uncle Wing's 4x4 wall puzzle. Prize: a free beer.
-- Showing the answer would let the whole queue copy it, so she proves
-- "I have a solution" and shows nothing else.
--
-- Written for someone who has never seen a proof system. Every name that
-- appears in a code block is explained in a comment on the same screen:
-- what it is, who can see it, where it comes from. Same fields as
-- src/data.lua (see the note there).

-- Argument order is fixed and matches I18n.LANGS. Every call passes all seven;
-- tests/test_flow.lua walks the data and fails if any language is missing.
local function L(en, ko, yue, zh, ja, cs, es)
  return { en = en, ko = ko, yue = yue, zh = zh, ja = ja, cs = cs, es = es }
end

local maps = {
  -- ------------------------------------------------------------ 1 PUZZLE
  {
    id = "puzzle",
    station = "PUZZLE",
    name = L(
      "Lucky Mart, puzzle wall",
      "럭키 마트, 퍼즐 벽",
      "幸運士多，謎題牆",
      "幸运士多，谜题墙",
      "ラッキーマート、パズルの壁",
      "Lucky Mart, stěna s hádankou",
      "Lucky Mart, pared de acertijos"
    ),
    title = L(
      "A secret, a statement, a proof",
      "비밀, 문장, 증명",
      "一個秘密，一句話，一個證明",
      "一个秘密，一句陈述，一个证明",
      "秘密、ステートメント、証明",
      "Tajemství, tvrzení, důkaz",
      "Un secreto, una declaración, una prueba"
    ),
    lesson = L(
      "The SECRET (witness) is Mei's 16 cells. The STATEMENT is public: 'this board has a solution'.",
      "비밀(witness)은 메이의 16칸. 문장(statement)은 공개: '이 판에는 답이 있다'.",
      "秘密（witness）係阿美嘅 16 格。句子（statement）係公開嘅：「呢個板有答案」。",
      "秘密（witness）是阿美的 16 格。陈述（statement）是公开的：「这个盘有解」。",
      "秘密（witness）はメイの 16 マス。ステートメント（statement）は公開:「この盤には答えがある」。",
      "TAJEMSTVÍ (witness) je 16 Meiných políček. TVRZENÍ je veřejné: 'tahle mřížka má řešení'.",
      "El SECRETO (witness) son las 16 casillas de Mei. La DECLARACIÓN es pública: 'este tablero "
        .. "tiene solución'."
    ),
    bg = "bg_store",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美", "阿美", "メイ", "Mei", "Mei"),
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
          "解到我幅牆嘅謎題，啤酒免費。畀我睇答案。",
          "解开我墙上的谜题，啤酒免费。把答案给我看。",
          "壁のパズルを解いたらビールはタダだ。答えを見せてくれ。",
          "Vyřeš mi hádanku na stěně a pivo je zdarma. Ukaž mi řešení.",
          "Resuelve el acertijo de mi pared y la cerveza es gratis. Muéstrame la respuesta."
        ),
      },
      {
        kind = "mei",
        x = 1040,
        facing = -1,
        line = L(
          "If I show it, everyone in the queue copies it. I'll PROVE it instead.",
          "보여주면 줄 선 사람들이 다 베끼잖아. 대신 증명할게.",
          "我一畀你睇，成條隊嘅人都會抄。我證明畀你睇。",
          "我一给你看，排队的人全都会抄。我改用证明。",
          "見せたら並んでる人みんなに写される。代わりに証明する。",
          "Když ho ukážu, opíše ho celá fronta. Radši ho DOKÁŽU.",
          "Si la muestro, toda la fila la copia. Mejor la PRUEBO."
        ),
      },
    },
    viz = "puzzle",
    story = L(
      "Uncle Wing's wall puzzle: a 4x4 board. Every row, every column and every 2x2 box must hold "
        .. "1, 2, 3, 4 once each. Some cells are printed (everyone sees them); Mei filled the rest. New "
        .. "quest, new kind of proof: a zk-SNARK. Same promise as quest 1 - convince without revealing.",
      "윙 아저씨의 벽 퍼즐: 4x4 판. 모든 행, 열, 2x2 상자에 1, 2, 3, 4가 한 번씩 들어가야 한다. 몇 칸은 인쇄돼 있고(누구나 봄), 나머지는 메이가 "
        .. "채웠다. 새 퀘스트, 새 종류의 증명: zk-SNARK. 약속은 퀘스트 1과 같다 - 보여주지 않고 납득시키기.",
      "榮叔幅牆嘅謎題：一個 4x4 板。每行、每列、每個 2x2 格都要有 1、2、3、4 "
        .. "各一次。有啲格係印咗嘅（人人見到），其餘係阿美填嘅。新任務，新嘅證明種類：zk-SNARK。承諾同任務 1 一樣 - 唔露底都令人信服。",
      "荣叔墙上的谜题：一个 4x4 的盘。每行、每列、每个 2x2 格都要有 1、2、3、4 "
        .. "各一次。有些格是印好的（人人看得到），其余是阿美填的。新任务，新的证明种类：zk-SNARK。承诺和任务 1 一样 - 不泄露也能让人信服。",
      "ウィンおじさんの壁パズル: 4x4 の盤。どの行、どの列、どの 2x2 ボックスにも 1, 2, 3, 4 "
        .. "が一度ずつ入る。いくつかのマスは印刷済み（誰でも見える）、残りはメイが埋めた。新しいクエスト、新しい種類の証明: zk-SNARK。約束はクエスト 1 と同じ - "
        .. "明かさずに納得させる。",
      "Hádanka na stěně strýce Winga: mřížka 4x4. Každý řádek, každý sloupec i každý čtverec 2x2 "
        .. "musí mít 1, 2, 3, 4 právě jednou. Některá políčka jsou vytištěná (vidí je každý); zbytek "
        .. "doplnila Mei. Nový úkol, nový druh důkazu: zk-SNARK. Slib stejný jako v úkolu 1 - přesvědčit "
        .. "bez prozrazení.",
      "El acertijo de la pared del tío Wing: un tablero 4x4. Cada fila, cada columna y cada caja "
        .. "2x2 debe llevar 1, 2, 3, 4 una vez cada uno. Algunas casillas están impresas (todos las "
        .. "ven); Mei llenó el resto. Nueva misión, nuevo tipo de prueba: un zk-SNARK. La misma promesa "
        .. "que en la misión 1: convencer sin revelar."
    ),
    stages = {
      {
        topic = "SECRET",
        q = L(
          "How many cells does Mei keep secret?",
          "메이가 비밀로 지키는 칸은 몇 개?",
          "阿美要保密嘅格有幾多個？",
          "阿美要保密的格有几个？",
          "メイが秘密にするマスはいくつ？",
          "Kolik políček drží Mei v tajnosti?",
          "¿Cuántas casillas mantiene Mei en secreto?"
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
]],
          [[
# board:  4 x 4 = 16 格。每格是 1、2、3 或 4
# clues:  印在墙上的数字。人人看到。0 = 空格
# secret: 阿美写的数字。没有人看到
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # 公开
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # 只有阿美
len(secret) == ___
]],
          [[
# board:  4 x 4 = 16 マス。各マスは 1, 2, 3, 4 のどれか
# clues:  壁に印刷された数字。誰でも見える。0 = 空きマス
# secret: メイが書いた数字。他の誰にも見えない
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # 公開
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # メイだけ
len(secret) == ___
]],
          [[
# board:  4 x 4 = 16 políček. V každém je 1, 2, 3 nebo 4
# clues:  čísla vytištěná na stěně. Vidí je každý. 0 = prázdno
# secret: čísla, která napsala Mei. Nikdo jiný je nevidí
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # veřejné
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # jen Mei
len(secret) == ___
]],
          [[
# board:  4 x 4 = 16 casillas. Cada casilla lleva 1, 2, 3 o 4
# clues:  números impresos en la pared. Todos los ven. 0 = vacío
# secret: los números que escribió Mei. Nadie más los ve
clues  = [1,0,0,4,  0,4,1,0,  0,1,4,0,  4,0,0,1]   # público
secret = [?,?,?,?,  ?,?,?,?,  ?,?,?,?,  ?,?,?,?]   # solo Mei
len(secret) == ___
]]
        ),
        accept = { "16", "sixteen", "열여섯", "16개", "十六", "šestnáct", "dieciséis" },
        answer = "16",
        hint = L(
          "4 rows of 4 cells.",
          "4칸짜리 행이 4개.",
          "4 行，每行 4 格。",
          "4 行，每行 4 格。",
          "4 マスの行が 4 つ。",
          "4 řádky po 4 políčkách.",
          "4 filas de 4 casillas."
        ),
        ok = L(
          "16 secret numbers. Uncle Wing will learn that they exist - never what they are.",
          "비밀 숫자 16개. 윙 아저씨는 그것이 존재한다는 것만 알게 되고, 값은 절대 모른다.",
          "16 個秘密數字。榮叔只會知道佢哋存在 - 永遠唔知係乜。",
          "16 个秘密数字。荣叔只会知道它们存在 - 永远不知道是什么。",
          "秘密の数字 16 個。ウィンおじさんはそれが存在することだけを知る - 中身は決して知らない。",
          "16 tajných čísel. Strýc Wing se dozví, že existují - nikdy ne jaká jsou.",
          "16 números secretos. El tío Wing sabrá que existen; nunca sabrá cuáles son."
        ),
      },
      {
        topic = "SECRET",
        q = L(
          "In SNARK words, the secret input is called the ___.",
          "SNARK 용어로, 비밀 입력을 ___라고 부른다.",
          "用 SNARK 嘅講法，秘密輸入叫做 ___。",
          "用 SNARK 的说法，秘密输入叫做 ___。",
          "SNARK の用語では、秘密の入力を ___ と呼ぶ。",
          "V řeči SNARKů se tajný vstup jmenuje ___.",
          "En jerga SNARK, la entrada secreta se llama ___."
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
]],
          [[
# statement: 要证明的句子。公开。人人都读得到
# witness:   使句子成立的秘密。私密
# prover:    阿美。她持有 witness
# verifier:  荣叔。他只看到句子和一个证明
statement = "印好的盘面可以填满"
___       = secret     # 16 个数字，永远不会送出去
]],
          [[
# statement: 証明する文。公開。誰でも読める
# witness:   その文を真にする秘密。非公開
# prover:    メイ。witness を持つ人
# verifier:  ウィンおじさん。文と証明しか見えない
statement = "印刷された盤は完成できる"
___       = secret     # 16 個の数字、決して送らない
]],
          [[
# statement: dokazovaná věta. Veřejná. Čte ji každý
# witness:   tajemství, které tu větu DĚLÁ pravdivou. Soukromé
# prover:    Mei. Ta drží witness
# verifier:  strýc Wing. Vidí jen tvrzení a důkaz
statement = "vytištěnou mřížku lze doplnit"
___       = secret     # těch 16 čísel, nikdy se neposílá
]],
          [[
# statement: la frase que se prueba. Pública. Todos la leen
# witness:   el secreto que HACE cierta la frase. Privado
# prover:    Mei. Ella tiene el witness
# verifier:  el tío Wing. Solo ve la frase y una prueba
statement = "el tablero impreso se puede completar"
___       = secret     # los 16 números, nunca se envían
]]
        ),
        accept = {
          "witness",
          "위트니스",
          "증인",
          "見證",
          "见证",
          "証人",
          "ウィットネス",
          "svědek",
          "testigo",
        },
        answer = "witness",
        hint = L(
          "The word for a secret that proves something. Like a person who saw it happen.",
          "무언가를 증명하는 비밀을 부르는 말. 사건을 목격한 사람과 같은 단어.",
          "指「證明到嘢嘅秘密」嘅字。同「目擊者」係同一個字。",
          "指「能证明事情的秘密」的那个词。就像亲眼见过的人。",
          "何かを証明する秘密を指す言葉。それを見た人と同じ単語。",
          "Slovo pro tajemství, které něco dokazuje. Jako člověk, který to viděl.",
          "La palabra para un secreto que prueba algo. Como alguien que vio lo que pasó."
        ),
        ok = L(
          "witness. Prover holds it, verifier never gets it. Quest 1's witness was (age, r).",
          "witness. 증명자가 갖고, 검증자는 절대 받지 않는다. 퀘스트 1의 witness는 (age, r)이었다.",
          "witness。證明者有佢，驗證者永遠攞唔到。任務 1 嘅 witness 係 (age, r)。",
          "witness。证明者持有它，验证者永远拿不到。任务 1 的 witness 是 (age, r)。",
          "witness。証明者が持ち、検証者は決して受け取らない。クエスト 1 の witness は (age, r) だった。",
          "witness. Dokazovatel ho drží, ověřovatel ho nikdy nedostane. V úkolu 1 byl witness (age, r).",
          "witness. El probador lo tiene, el verificador nunca lo recibe. El witness de la misión 1 era "
            .. "(age, r)."
        ),
      },
      {
        topic = "SECRET",
        q = L(
          "The rule: a row holds each of 1, 2, 3, 4 exactly how many times?",
          "규칙: 한 행에는 1, 2, 3, 4가 각각 정확히 몇 번씩 들어가나?",
          "規則：一行入面，1、2、3、4 每個要出現幾多次？",
          "规则：一行里面，1、2、3、4 每个恰好出现几次？",
          "規則: 一つの行に 1, 2, 3, 4 はそれぞれちょうど何回入る？",
          "Pravidlo: kolikrát přesně je v řádku každé z čísel 1, 2, 3, 4?",
          "La regla: ¿cuántas veces exactas aparece cada uno de 1, 2, 3, 4 en una fila?"
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
]],
          [[
# row: 横排四格。竖列和 2x2 格也是同一规则
# 规则：1、2、3、4 每个恰好 ___ 次，次序不限
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> 这行没问题
]],
          [[
# row: 横に並んだ 4 マス。列と 2x2 ボックスも同じ規則
# 規則: 1, 2, 3, 4 がそれぞれちょうど ___ 回、順番は自由
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> この行は OK
]],
          [[
# row: čtyři políčka vedle sebe. Totéž pro sloupce a čtverce 2x2
# pravidlo: 1, 2, 3, 4 každé přesně ___ x, v libovolném pořadí
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> řádek je v pořádku
]],
          [[
# row: cuatro casillas seguidas. Misma regla en columnas y cajas 2x2
# la regla: 1, 2, 3, 4 cada uno ___ vez, en cualquier orden
row = [1, 3, 2, 4]
sorted(row) == [1, 2, 3, 4]    # True -> la fila está bien
]]
        ),
        accept = {
          "1",
          "once",
          "one",
          "one time",
          "한 번",
          "한번",
          "1번",
          "一次",
          "一",
          "一回",
          "jednou",
          "una vez",
        },
        answer = "once",
        hint = L(
          "No repeats, nothing missing.",
          "중복 없이, 빠짐없이.",
          "冇重複，冇漏。",
          "没有重复，没有遗漏。",
          "重複なし、抜けなし。",
          "Nic dvakrát, nic nechybí.",
          "Sin repetidos, sin faltantes."
        ),
        ok = L(
          "Once each. Next street turns this rule into arithmetic a SNARK can check.",
          "각 한 번씩. 다음 거리에서 이 규칙을 SNARK가 검사할 수 있는 산수로 바꾼다.",
          "各一次。下一條街會將呢條規則變成 SNARK 檢查到嘅算術。",
          "各一次。下一条街会把这条规则变成 SNARK 能检查的算术。",
          "各一回。次の通りで、この規則を SNARK が調べられる算術に変える。",
          "Každé jednou. Další ulice udělá z tohohle pravidla počty, které SNARK umí ověřit.",
          "Una vez cada uno. La calle siguiente convierte esta regla en aritmética que un SNARK puede " .. "revisar."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 2 CIRCUIT
  {
    id = "circuit",
    station = "CIRCUIT",
    name = L(
      "Wire alley",
      "전선 골목",
      "電線小巷",
      "电线小巷",
      "電線の路地",
      "Drátová ulička",
      "Callejón de los cables"
    ),
    title = L(
      "Rules become + and x",
      "규칙이 +와 x가 된다",
      "規則變成 + 同 x",
      "规则变成 + 和 x",
      "規則が + と x になる",
      "Z pravidel se stane + a x",
      "Las reglas se vuelven + y x"
    ),
    lesson = L(
      "Every rule becomes + and x only: (v-1)(v-2)(v-3)(v-4) = 0, sum = 10, product = 24.",
      "모든 규칙이 +와 x만으로: (v-1)(v-2)(v-3)(v-4) = 0, 합 = 10, 곱 = 24.",
      "所有規則只用 + 同 x：(v-1)(v-2)(v-3)(v-4) = 0，總和 = 10，乘積 = 24。",
      "每条规则都只用 + 和 x：(v-1)(v-2)(v-3)(v-4) = 0，和 = 10，积 = 24。",
      "どの規則も + と x だけになる: (v-1)(v-2)(v-3)(v-4) = 0、和 = 10、積 = 24。",
      "Každé pravidlo jen přes + a x: (v-1)(v-2)(v-3)(v-4) = 0, součet = 10, součin = 24.",
      "Toda regla se vuelve solo + y x: (v-1)(v-2)(v-3)(v-4) = 0, suma = 10, producto = 24."
    ),
    bg = "bg_bits",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美", "阿美", "メイ", "Mei", "Mei"),
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
          "機器唔識讀「各一次」。佢只識加同乘。",
          "机器读不懂「各一次」。它只会加和乘。",
          "機械は「各一回」なんて読めない。足し算と掛け算しかできない。",
          "Stroj neumí přečíst 'každé jednou'. Umí jen sčítat a násobit.",
          "Una máquina no sabe leer 'una vez cada uno'. Solo suma y multiplica."
        ),
      },
    },
    viz = "circuit",
    story = L(
      "A SNARK cannot read rules in words. It understands exactly two things: add and multiply. So "
        .. "every rule is rewritten as an equation using only + and x. That rewritten form is called an "
        .. "arithmetic circuit. Quest 1 already did this once: 'b is a bit' became b(b-1) = 0.",
      "SNARK는 말로 된 규칙을 못 읽는다. 아는 것은 딱 둘: 더하기와 곱하기. 그래서 모든 규칙을 +와 x만 쓰는 등식으로 다시 쓴다. 그렇게 다시 쓴 것을 산술 "
        .. "회로(arithmetic circuit)라 한다. 퀘스트 1에서 이미 한 번 했다: 'b는 비트다'가 b(b-1) = 0이 됐다.",
      "SNARK 讀唔到文字規則。佢只識兩樣嘢：加同乘。所以每條規則都要改寫成只用 + 同 x 嘅等式。改寫出嚟嘅嘢叫做算術電路（arithmetic circuit）。任務 1 "
        .. "已經做過一次：「b 係一個 bit」變成咗 b(b-1) = 0。",
      "SNARK 读不懂文字规则。它只懂两样东西：加和乘。所以每条规则都要改写成只用 + 和 x 的等式。改写出来的形式叫算术电路（arithmetic circuit）。任务 1 "
        .. "已经做过一次：「b 是一个 bit」变成了 b(b-1) = 0。",
      "SNARK は言葉の規則を読めない。分かるのはきっかり二つ: 足し算と掛け算。だから規則はすべて + と x だけの等式に書き直す。書き直した形を算術回路（arithmetic "
        .. "circuit）という。クエスト 1 で一度やった:「b はビット」が b(b-1) = 0 になった。",
      "SNARK neumí číst pravidla ve slovech. Rozumí přesně dvěma věcem: sčítání a násobení. Takže "
        .. "se každé pravidlo přepíše na rovnici, kde je jen + a x. Tomu přepisu se říká aritmetický "
        .. "obvod. V úkolu 1 jsme to už jednou udělali: z 'b je bit' se stalo b(b-1) = 0.",
      "Un SNARK no puede leer reglas en palabras. Entiende exactamente dos cosas: sumar y "
        .. "multiplicar. Así que cada regla se reescribe como una ecuación que usa solo + y x. Esa forma "
        .. "reescrita se llama circuito aritmético. La misión 1 ya lo hizo una vez: 'b es un bit' se "
        .. "volvió b(b-1) = 0."
    ),
    stages = {
      {
        topic = "GATES",
        q = L(
          "v is one cell. (v-1)(v-2)(v-3)(v-4) equals ___ exactly when v is 1, 2, 3 or 4.",
          "v는 한 칸의 값. (v-1)(v-2)(v-3)(v-4)는 v가 1, 2, 3, 4일 때만 정확히 ___이다.",
          "v 係一格嘅值。(v-1)(v-2)(v-3)(v-4) 啱啱等於 ___，當且僅當 v 係 1、2、3 或 4。",
          "v 是一格的值。(v-1)(v-2)(v-3)(v-4) 恰好等于 ___，当且仅当 v 是 1、2、3 或 4。",
          "v は 1 マスの値。(v-1)(v-2)(v-3)(v-4) がちょうど ___ になるのは v が 1, 2, 3, 4 のときだけ。",
          "v je jedno políčko. (v-1)(v-2)(v-3)(v-4) se rovná ___ právě tehdy, když je v 1, 2, 3 nebo 4.",
          "v es una casilla. (v-1)(v-2)(v-3)(v-4) vale ___ exactamente cuando v es 1, 2, 3 o 4."
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
]],
          [[
# v: 一格的值（秘密）
# 乘积等于 0，当且仅当其中一个因子是 0
# 所以下面这行是 0  <=>  v 是 1、2、3 或 4
# （任务 1 对 bit 做过同样的事：  b * (b - 1) = 0）
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]],
          [[
# v: 1 マスの値（秘密）
# 積が 0 になるのは、因数のどれかが 0 のときだけ
# だから下の行が 0  <=>  v は 1, 2, 3, 4 のどれか
# (クエスト 1 はビットに同じことをした:  b * (b - 1) = 0)
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]],
          [[
# v: hodnota v jednom políčku (tajná)
# součin je 0 právě tehdy, když je jeden z činitelů 0
# takže řádek níže je 0  <=>  v je 1, 2, 3 nebo 4
# (úkol 1 udělal totéž pro bity:  b * (b - 1) = 0)
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]],
          [[
# v: el valor de una casilla (secreto)
# un producto es 0 justo cuando uno de sus factores es 0
# así la línea de abajo es 0  <=>  v es 1, 2, 3 o 4
# (la misión 1 hizo lo mismo con bits:  b * (b - 1) = 0)
v = 3
(v - 1) * (v - 2) * (v - 3) * (v - 4) == ___
]]
        ),
        accept = { "0", "zero", "영", "0이다", "零", "ゼロ", "nula", "cero" },
        answer = "0",
        hint = L(
          "v = 3 makes the third bracket (3 - 3) zero.",
          "v = 3이면 세 번째 괄호 (3 - 3)이 0.",
          "v = 3 令第三個括號 (3 - 3) 變成零。",
          "v = 3 让第三个括号 (3 - 3) 变成零。",
          "v = 3 だと三つ目の括弧 (3 - 3) がゼロ。",
          "v = 3 vynuluje třetí závorku (3 - 3).",
          "v = 3 hace cero el tercer paréntesis (3 - 3)."
        ),
        ok = L(
          "0. One line, no words, and a cell can only be 1..4. This is a 'gadget'.",
          "0. 말 없이 한 줄로 칸은 1..4만 가능해진다. 이런 걸 '가젯(gadget)'이라 한다.",
          "0。一行，冇文字，一格就只可以係 1..4。呢樣嘢叫「gadget」。",
          "0。一行，没有文字，一格就只能是 1..4。这东西叫「gadget」。",
          "0。一行、言葉なし、それでマスは 1..4 しか取れない。これを「gadget」と呼ぶ。",
          "0. Jeden řádek, žádná slova, a políčko může být jen 1..4. Tomuhle se říká 'gadget'.",
          "0. Una línea, sin palabras, y una casilla solo puede ser 1..4. Esto es un 'gadget'."
        ),
      },
      {
        topic = "GATES",
        q = L(
          "A row holds 1, 2, 3, 4 once each. What do the four cells add up to?",
          "한 행에 1, 2, 3, 4가 한 번씩. 네 칸을 더하면?",
          "一行有 1、2、3、4 各一次。四格加埋係幾多？",
          "一行有 1、2、3、4 各一次。四格加起来是多少？",
          "一つの行に 1, 2, 3, 4 が一度ずつ。四つのマスを足すといくつ？",
          "V řádku je 1, 2, 3, 4 každé jednou. Kolik dají ta čtyři políčka dohromady?",
          "Una fila lleva 1, 2, 3, 4 una vez cada uno. ¿Cuánto suman las cuatro casillas?"
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
]],
          [[
# a, b, c, d: 一行的四格（秘密），次序不限
# 1 + 2 + 3 + 4 = ___   不管次序如何
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]],
          [[
# a, b, c, d: 1 行の 4 マス（秘密）、順番は自由
# 1 + 2 + 3 + 4 = ___   順番に関係なく
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]],
          [[
# a, b, c, d: čtyři políčka řádku (tajná), v libovolném pořadí
# 1 + 2 + 3 + 4 = ___   ať je pořadí jakékoli
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]],
          [[
# a, b, c, d: las 4 casillas de una fila (secreto), orden libre
# 1 + 2 + 3 + 4 = ___   sin importar el orden
a, b, c, d = 3, 4, 1, 2
a + b + c + d == ___
]]
        ),
        accept = { "10", "ten", "열", "십", "十", "deset", "diez" },
        answer = "10",
        hint = L(
          "1 + 2 + 3 + 4.",
          "1 + 2 + 3 + 4.",
          "1 + 2 + 3 + 4。",
          "1 + 2 + 3 + 4。",
          "1 + 2 + 3 + 4。",
          "1 + 2 + 3 + 4.",
          "1 + 2 + 3 + 4."
        ),
        ok = L(
          "10. But 4 + 4 + 1 + 1 is also 10, so the sum alone is not enough...",
          "10. 하지만 4 + 4 + 1 + 1도 10이라서 합만으로는 부족하다...",
          "10。但 4 + 4 + 1 + 1 都係 10，所以淨係總和唔夠...",
          "10。但 4 + 4 + 1 + 1 也是 10，所以光有和还不够...",
          "10。でも 4 + 4 + 1 + 1 も 10 だから、和だけでは足りない...",
          "10. Jenže 4 + 4 + 1 + 1 je taky 10, takže samotný součet nestačí...",
          "10. Pero 4 + 4 + 1 + 1 también da 10, así que la suma sola no basta..."
        ),
      },
      {
        topic = "GATES",
        q = L(
          "...and what do the same four cells multiply to?",
          "...같은 네 칸을 곱하면?",
          "...同樣嘅四格乘埋係幾多？",
          "...同样的四格乘起来是多少？",
          "...同じ四つのマスを掛けるといくつ？",
          "...a kolik dají ta samá čtyři políčka vynásobená?",
          "...¿y cuánto da el producto de esas mismas cuatro casillas?"
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
]],
          [[
# 同样的四格。1 * 2 * 3 * 4 = ___
# 和 10 加上积 ___ 只有 1、2、3、4 才做得到
# （其他和为 10 的组合，积是 16、27、32 或 36）
a * b * c * d == ___
]],
          [[
# 同じ 4 マス。1 * 2 * 3 * 4 = ___
# 和 10 かつ積 ___ になるのは 1, 2, 3, 4 のときだけ
# (和が 10 の他の組は積が 16, 27, 32, 36)
a * b * c * d == ___
]],
          [[
# ta samá čtyři políčka. 1 * 2 * 3 * 4 = ___
# součet 10 A součin ___ nastane JEN pro 1, 2, 3, 4
# (jiné čtveřice se součtem 10 dají 16, 27, 32, 36)
a * b * c * d == ___
]],
          [[
# las mismas cuatro casillas. 1 * 2 * 3 * 4 = ___
# suma 10 Y producto ___ pasa SOLO con 1, 2, 3, 4
# (los otros grupos que suman 10 dan 16, 27, 32 o 36)
a * b * c * d == ___
]]
        ),
        accept = {
          "24",
          "twenty four",
          "twenty-four",
          "이십사",
          "스물넷",
          "二十四",
          "dvacet čtyři",
          "veinticuatro",
        },
        answer = "24",
        hint = L(
          "1 x 2 x 3 x 4.",
          "1 x 2 x 3 x 4.",
          "1 x 2 x 3 x 4。",
          "1 x 2 x 3 x 4。",
          "1 x 2 x 3 x 4。",
          "1 x 2 x 3 x 4.",
          "1 x 2 x 3 x 4."
        ),
        ok = L(
          "24. Sum 10 plus product 24 = 'each once', said with only + and x.",
          "24. 합 10 더하기 곱 24 = '각 한 번씩'을 +와 x만으로 말한 것.",
          "24。總和 10 加乘積 24 = 用 + 同 x 講出「各一次」。",
          "24。和 10 加上积 24 = 用 + 和 x 说出「各一次」。",
          "24。和 10 と積 24 =「各一回」を + と x だけで言ったもの。",
          "24. Součet 10 plus součin 24 = 'každé jednou', řečeno jen přes + a x.",
          "24. Suma 10 más producto 24 = 'una vez cada uno', dicho solo con + y x."
        ),
      },
      {
        topic = "GATES",
        q = L(
          "How many multiplications does one cell check take? (additions are free)",
          "칸 하나 검사에 곱셈이 몇 번? (덧셈은 공짜)",
          "檢查一格要乘幾多次？（加法係免費嘅）",
          "检查一格要乘几次？（加法是免费的）",
          "マス一つの検査に掛け算は何回？（足し算はタダ）",
          "Kolik násobení stojí kontrola jednoho políčka? (sčítání je zdarma)",
          "¿Cuántas multiplicaciones cuesta revisar una casilla? (las sumas son gratis)"
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
]],
          [[
# SNARK 只数乘法；加法不花钱
# rust/src/sudoku.rs，一格：
t1 = (v - 1) * (v - 2)     # 第 1 次乘法
t2 = t1 * (v - 3)          # 第 2 次
t3 = t2 * (v - 4)          # 第 3 次 -> 必须等于 0
mults_per_cell = ___
]],
          [[
# SNARK は掛け算だけを数える。足し算はタダ
# rust/src/sudoku.rs、1 マス分:
t1 = (v - 1) * (v - 2)     # 1 回目の掛け算
t2 = t1 * (v - 3)          # 2 回目
t3 = t2 * (v - 4)          # 3 回目 -> 0 でなければならない
mults_per_cell = ___
]],
          [[
# SNARK počítá násobení; sčítání nic nestojí
# rust/src/sudoku.rs, jedno políčko:
t1 = (v - 1) * (v - 2)     # 1. násobení
t2 = t1 * (v - 3)          # 2.
t3 = t2 * (v - 4)          # 3. -> musí být 0
mults_per_cell = ___
]],
          [[
# un SNARK cuenta multiplicaciones; las sumas no cuestan nada
# rust/src/sudoku.rs, una casilla:
t1 = (v - 1) * (v - 2)     # 1ra multiplicación
t2 = t1 * (v - 3)          # 2da
t3 = t2 * (v - 4)          # 3ra -> debe ser 0
mults_per_cell = ___
]]
        ),
        accept = { "3", "three", "셋", "세 번", "3번", "三", "tři", "tres" },
        answer = "3",
        hint = L(
          "Count the * signs.",
          "* 기호를 세어보세요.",
          "數下有幾多個 *。",
          "数一数有几个 *。",
          "* の数を数えてみて。",
          "Spočítej znaky *.",
          "Cuenta los signos *."
        ),
        ok = L(
          "3. Four brackets, three multiplications. t1, t2 are temporaries the circuit keeps.",
          "3. 괄호 넷, 곱셈 셋. t1, t2는 회로가 갖고 있는 임시값.",
          "3。四個括號，三次乘法。t1、t2 係電路保留嘅臨時值。",
          "3。四个括号，三次乘法。t1、t2 是电路保留的临时值。",
          "3。括弧が四つ、掛け算が三回。t1, t2 は回路が持つ一時値。",
          "3. Čtyři závorky, tři násobení. t1, t2 jsou pomocné hodnoty, které si obvod drží.",
          "3. Cuatro paréntesis, tres multiplicaciones. t1, t2 son temporales que el circuito guarda."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 3 R1CS
  {
    id = "r1cs",
    station = "R1CS",
    name = L(
      "Ledger office",
      "장부 사무실",
      "帳簿辦公室",
      "账簿办公室",
      "帳簿の事務所",
      "Účtárna",
      "Oficina del libro mayor"
    ),
    title = L(
      "One line per multiplication",
      "곱셈 하나에 한 줄",
      "每次乘法一行",
      "每次乘法一行",
      "掛け算一回につき一行",
      "Jeden řádek na jedno násobení",
      "Una línea por multiplicación"
    ),
    lesson = L(
      "Each x is one line (A.w) x (B.w) = (C.w). The puzzle is 112 lines over one vector w.",
      "곱셈 하나가 한 줄 (A.w) x (B.w) = (C.w). 퍼즐은 벡터 w 하나 위의 112줄.",
      "每個 x 係一行 (A.w) x (B.w) = (C.w)。個謎題係一個向量 w 上面嘅 112 行。",
      "每个 x 是一行 (A.w) x (B.w) = (C.w)。这个谜题是一个向量 w 上的 112 行。",
      "x 一つが一行 (A.w) x (B.w) = (C.w)。パズルはベクトル w 一本の上の 112 行。",
      "Každé x je jeden řádek (A.w) x (B.w) = (C.w). Hádanka je 112 řádků nad jedním vektorem w.",
      "Cada x es una línea (A.w) x (B.w) = (C.w). El acertijo son 112 líneas sobre un vector w."
    ),
    bg = "bg_office",
    portrait = "portrait_hero",
    speaker = L(
      "Alex (you)",
      "알렉스 (나)",
      "阿力 (你)",
      "阿力 (你)",
      "アレックス（あなた）",
      "Alex (ty)",
      "Alex (tú)"
    ),
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
          "所有值放喺一張表。每次乘法一行。成張表格就係咁。",
          "所有值放在一张表上。每次乘法一行。整张表格就是这样。",
          "値は全部一つのリストに。掛け算は一回につき一行。書式はそれだけ。",
          "Všechny hodnoty v jednom seznamu. Každé násobení na jednom řádku. To je celý formulář.",
          "Todos los valores en una lista. Cada multiplicación en una línea. Ese es todo el formulario."
        ),
      },
    },
    viz = "r1cs",
    story = L(
      "Every multiplication of the circuit becomes ONE line of the form (a) x (b) = (c). A list of "
        .. "such lines is an R1CS (rank-1 constraint system; 'constraint' = one line). All values live "
        .. "in a single list w, the witness vector: the constant 1, then the public clues, then Mei's "
        .. "secret cells, then temporaries like t1 and t2.",
      "회로의 곱셈 하나하나가 (a) x (b) = (c) 꼴의 한 줄이 된다. 그런 줄의 목록이 R1CS (rank-1 constraint system; "
        .. "'constraint' = 줄 하나)다. 모든 값은 한 목록 w, 즉 witness 벡터에 산다: 상수 1, 그다음 공개 clues, 그다음 메이의 비밀 칸, 그다음 "
        .. "t1, t2 같은 임시값.",
      "電路每一次乘法都變成一行 (a) x (b) = (c)。呢啲行嘅清單叫 R1CS（rank-1 constraint system；「constraint」= "
        .. "一行）。所有值都住喺一張表 w，即係 witness 向量：常數 1，然後係公開嘅 clues，然後係阿美嘅秘密格，然後係 t1、t2 呢類臨時值。",
      "电路的每一次乘法都变成一行 (a) x (b) = (c)。这些行的清单叫 R1CS（rank-1 constraint system；「constraint」= "
        .. "一行）。所有值都住在一张表 w 里，即 witness 向量：常数 1，然后是公开的 clues，然后是阿美的秘密格，然后是 t1、t2 这类临时值。",
      "回路の掛け算一つ一つが (a) x (b) = (c) の形の一行になる。その行のリストが R1CS（rank-1 constraint system;「constraint」= "
        .. "一行）。値はすべて一つのリスト w、つまりウィットネス・ベクトルに住む: 定数 1、次に公開の clues、次にメイの秘密のマス、次に t1 や t2 のような一時値。",
      "Každé násobení v obvodu se stane JEDNÍM řádkem tvaru (a) x (b) = (c). Seznam takových řádků "
        .. "je R1CS (rank-1 constraint system; 'constraint' = jeden řádek). Všechny hodnoty žijí v "
        .. "jednom seznamu w, ve vektoru witness: konstanta 1, pak veřejné clues, pak Meina tajná "
        .. "políčka, pak pomocné hodnoty jako t1 a t2.",
      "Cada multiplicación del circuito se vuelve UNA línea de la forma (a) x (b) = (c). Una lista "
        .. "de esas líneas es un R1CS (rank-1 constraint system; 'constraint' = una línea). Todos los "
        .. "valores viven en una sola lista w, el vector witness: la constante 1, luego las pistas "
        .. "públicas, luego las casillas secretas de Mei, luego temporales como t1 y t2."
    ),
    stages = {
      {
        topic = "R1CS",
        q = L(
          "w[0] is always the number ___ (so a line can mention plain numbers).",
          "w[0]은 항상 숫자 ___ (그래야 줄에서 보통 숫자를 쓸 수 있다).",
          "w[0] 永遠係數字 ___（咁一行先可以提到普通數字）。",
          "w[0] 永远是数字 ___（这样一行里才能提到普通数字）。",
          "w[0] は必ず数字の ___（そうすれば行の中で普通の数字を使える）。",
          "w[0] je vždycky číslo ___ (aby řádek mohl zmínit obyčejná čísla).",
          "w[0] siempre es el número ___ (así una línea puede mencionar números normales)."
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
]],
          [[
# w: witness 向量 - 一张表，装着电路碰到的每一个值
# w[0]      = ___  固定常数，这样「= 10」才能写成 10 * w[0]
# w[1..16]  16 个 clues（公开）
# w[17..32] 16 个秘密格
# w[33..]   临时值（t1、t2、p1、p2 ...）   -> 总共 89 项
w = [___, 1, 0, 0, 4, ...]
]],
          [[
# w: ウィットネス・ベクトル - 回路が触る値を全部入れた 1 本のリスト
# w[0]      = ___  固定の定数。だから "= 10" を 10 * w[0] と書ける
# w[1..16]  16 個の clues（公開）
# w[17..32] 16 個の秘密のマス
# w[33..]   一時値 (t1, t2, p1, p2 ...)   -> 全部で 89 項目
w = [___, 1, 0, 0, 4, ...]
]],
          [[
# w: vektor witness - JEDEN seznam se všemi hodnotami obvodu
# w[0]      = ___  pevná konstanta, aby "= 10" šlo psát jako 10 * w[0]
# w[1..16]  16 clues (veřejné)
# w[17..32] 16 tajných políček
# w[33..]   pomocné (t1, t2, p1, p2 ...)   -> celkem 89 položek
w = [___, 1, 0, 0, 4, ...]
]],
          [[
# w: el vector witness - UNA lista con todo valor que toca el circuito
# w[0]      = ___  constante fija, así "= 10" se escribe 10 * w[0]
# w[1..16]  las 16 pistas (públicas)
# w[17..32] las 16 casillas secretas
# w[33..]   temporales (t1, t2, p1, p2 ...)   -> 89 en total
w = [___, 1, 0, 0, 4, ...]
]]
        ),
        accept = { "1", "one", "일", "하나", "一", "jedna", "uno" },
        answer = "1",
        hint = L(
          "Multiply anything by it and nothing changes.",
          "무엇을 곱해도 그대로인 수.",
          "乘乜嘢都唔變嘅數。",
          "乘什么都不变的数。",
          "何に掛けても変わらない数。",
          "Vynásob jím cokoli a nic se nezmění.",
          "Multiplica lo que sea por él y nada cambia."
        ),
        ok = L(
          "1. With w[0] = 1 the line 'sum = 10' is (a+b+c+d) x 1 = 10 x w[0].",
          "1. w[0] = 1이면 '합 = 10' 줄은 (a+b+c+d) x 1 = 10 x w[0].",
          "1。有咗 w[0] = 1，「總和 = 10」呢行就係 (a+b+c+d) x 1 = 10 x w[0]。",
          "1。有了 w[0] = 1，「和 = 10」这行就是 (a+b+c+d) x 1 = 10 x w[0]。",
          "1。w[0] = 1 なら「和 = 10」の行は (a+b+c+d) x 1 = 10 x w[0]。",
          "1. S w[0] = 1 vypadá řádek 'součet = 10' takto: (a+b+c+d) x 1 = 10 x w[0].",
          "1. Con w[0] = 1, la línea 'suma = 10' es (a+b+c+d) x 1 = 10 x w[0]."
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "One line is (A.w) x (B.w) = (C.w). For t1 = (v-1)(v-2): A picks v-1, B picks v-2, C picks ___.",
          "한 줄은 (A.w) x (B.w) = (C.w). t1 = (v-1)(v-2)에서 A는 v-1, B는 v-2, C는 ___를 고른다.",
          "一行係 (A.w) x (B.w) = (C.w)。對 t1 = (v-1)(v-2)：A 揀 v-1，B 揀 v-2，C 揀 ___。",
          "一行是 (A.w) x (B.w) = (C.w)。对 t1 = (v-1)(v-2)：A 挑 v-1，B 挑 v-2，C 挑 ___。",
          "一行は (A.w) x (B.w) = (C.w)。t1 = (v-1)(v-2) では A が v-1、B が v-2、C が ___ を選ぶ。",
          "Jeden řádek je (A.w) x (B.w) = (C.w). Pro t1 = (v-1)(v-2): A vybere v-1, B vybere v-2, C " .. "vybere ___.",
          "Una línea es (A.w) x (B.w) = (C.w). Para t1 = (v-1)(v-2): A toma v-1, B toma v-2, C toma ___."
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
]],
          [[
# A, B, C: w 上面的三张「挑选表」，每行一组
# A.w 挑左边因子，B.w 挑右边因子，C.w 挑结果
# t1 = (v - 1) * (v - 2) 这行：
A_w = v - 1          # v 是 w[17]，那个 1 是 w[0]
B_w = v - 2
C_w = ___            # 这行的答案存在哪
]],
          [[
# A, B, C: w の上の三つの「選択リスト」、一行につき一組
# A.w が左の因数、B.w が右の因数、C.w が結果を選ぶ
# t1 = (v - 1) * (v - 2) の行:
A_w = v - 1          # v は w[17]、1 は w[0]
B_w = v - 2
C_w = ___            # この行の答えが入る場所
]],
          [[
# A, B, C: tři "výběrové seznamy" nad w, jedna trojice na řádek
# A.w vybere levý činitel, B.w pravý činitel, C.w výsledek
# řádek pro t1 = (v - 1) * (v - 2):
A_w = v - 1          # v je w[17], ta 1 je w[0]
B_w = v - 2
C_w = ___            # kam se ukládá výsledek řádku
]],
          [[
# A, B, C: tres "listas de selección" sobre w, un trío por línea
# A.w toma el factor izquierdo, B.w el derecho, C.w el resultado
# la línea de t1 = (v - 1) * (v - 2):
A_w = v - 1          # v es w[17], el 1 es w[0]
B_w = v - 2
C_w = ___            # donde se guarda la respuesta de esta línea
]]
        ),
        accept = { "t1", "t_1", "t 1" },
        answer = "t1",
        hint = L(
          "The temporary that holds (v-1)(v-2).",
          "(v-1)(v-2)를 담는 임시값.",
          "裝住 (v-1)(v-2) 嘅臨時值。",
          "装着 (v-1)(v-2) 的临时值。",
          "(v-1)(v-2) を入れておく一時値。",
          "Pomocná hodnota, která drží (v-1)(v-2).",
          "El temporal que guarda (v-1)(v-2)."
        ),
        ok = L(
          "t1. A, B, C are the whole circuit; Mei fills w, Uncle Wing keeps A, B, C.",
          "t1. A, B, C가 회로의 전부. 메이는 w를 채우고, 윙 아저씨는 A, B, C를 갖는다.",
          "t1。A、B、C 就係成個電路；阿美填 w，榮叔保留 A、B、C。",
          "t1。A、B、C 就是整个电路；阿美填 w，荣叔保留 A、B、C。",
          "t1。A, B, C が回路のすべて。メイが w を埋め、ウィンおじさんが A, B, C を持つ。",
          "t1. A, B, C jsou celý obvod; Mei plní w, strýc Wing drží A, B, C.",
          "t1. A, B, C son todo el circuito; Mei llena w, el tío Wing guarda A, B, C."
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "How many lines does the whole 4x4 puzzle take?",
          "4x4 퍼즐 전체는 몇 줄?",
          "成個 4x4 謎題要幾多行？",
          "整个 4x4 谜题要几行？",
          "4x4 のパズル全体で何行？",
          "Kolik řádků zabere celá hádanka 4x4?",
          "¿Cuántas líneas ocupa todo el acertijo 4x4?"
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
]],
          [[
# rust/src/sudoku.rs - 数行数（每个 x 是一行）
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 12 个行/列/格：和 = 10 (1)，积 = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]],
          [[
# rust/src/sudoku.rs - 行数を数える（掛け算一回が一行）
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 行/列/ボックス 12 個: 和 = 10 (1)、積 = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]],
          [[
# rust/src/sudoku.rs - počítání řádků (každé x je jeden řádek)
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 12 řádků/sloupců/2x2: součet = 10 (1), součin = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]],
          [[
# rust/src/sudoku.rs - contando las líneas (cada x es una línea)
clue_checks = 16 * 1          # clue * (cell - clue) = 0
cell_checks = 16 * 3          # (v-1)(v-2)(v-3)(v-4) = 0
line_checks = 12 * (1 + 3)    # 12 filas/cols/cajas: suma = 10 (1), producto = 24 (3)
constraints = clue_checks + cell_checks + line_checks
constraints == ___
]]
        ),
        accept = { "112", "백십이", "一百一十二", "sto dvanáct", "ciento doce" },
        answer = "112",
        hint = L(
          "16 + 48 + 48.",
          "16 + 48 + 48.",
          "16 + 48 + 48。",
          "16 + 48 + 48。",
          "16 + 48 + 48。",
          "16 + 48 + 48.",
          "16 + 48 + 48."
        ),
        ok = L(
          "112 lines. A 9x9 sudoku would be thousands; the proof size will not care.",
          "112줄. 9x9 스도쿠라면 수천 줄; 증명 크기는 신경 쓰지 않는다.",
          "112 行。9x9 數獨會有幾千行；證明大小唔會在乎。",
          "112 行。9x9 数独会有几千行；证明大小不会在乎。",
          "112 行。9x9 の数独なら数千行; 証明の大きさは気にしない。",
          "112 řádků. Sudoku 9x9 by jich mělo tisíce; velikosti důkazu je to jedno.",
          "112 líneas. Un sudoku 9x9 tendría miles; al tamaño de la prueba no le importa."
        ),
      },
      {
        topic = "R1CS",
        q = L(
          "Uncle Wing types the public inputs in himself. How many are there?",
          "윙 아저씨는 공개 입력을 직접 넣는다. 몇 개인가?",
          "榮叔自己輸入公開輸入。有幾多個？",
          "荣叔自己输入公开输入。有几个？",
          "ウィンおじさんは公開入力を自分で入力する。いくつある？",
          "Strýc Wing si veřejné vstupy zadá sám. Kolik jich je?",
          "El tío Wing escribe él mismo las entradas públicas. ¿Cuántas son?"
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
]],
          [[
# public inputs: 验证者自己填的那部分 w
# 这里是 16 个 clues。他永远不会输入秘密格
public_inputs = len(clues)
public_inputs == ___
]],
          [[
# public inputs: 検証者が自分で埋める w の部分
# ここでは 16 個の clues。秘密のマスは絶対に入力しない
public_inputs = len(clues)
public_inputs == ___
]],
          [[
# public inputs: část w, kterou ověřovatel vyplní SÁM
# tady: 16 clues. Tajná políčka nikdy nezadává
public_inputs = len(clues)
public_inputs == ___
]],
          [[
# public inputs: la parte de w que el verificador llena ÉL MISMO
# aquí: las 16 pistas. Nunca escribe las casillas secretas
public_inputs = len(clues)
public_inputs == ___
]]
        ),
        accept = { "16", "sixteen", "열여섯", "16개", "十六", "šestnáct", "dieciséis" },
        answer = "16",
        hint = L(
          "One per cell of the board.",
          "판의 칸마다 하나.",
          "板上每格一個。",
          "盘上每格一个。",
          "盤のマスごとに一つ。",
          "Jeden na každé políčko mřížky.",
          "Una por cada casilla del tablero."
        ),
        ok = L(
          "16. A proof is tied to these 16 numbers; change a clue and it stops verifying.",
          "16. 증명은 이 16개 숫자에 묶여 있다; clue 하나만 바꿔도 검증이 실패한다.",
          "16。證明同呢 16 個數字綁埋一齊；改一個 clue 就驗證唔到。",
          "16。证明和这 16 个数字绑在一起；改一个 clue 就验证不过。",
          "16。証明はこの 16 個の数字に結びついている; clue を一つ変えると検証は通らない。",
          "16. Důkaz je svázaný s těmi 16 čísly; změň jedno vodítko a ověření selže.",
          "16. Una prueba queda atada a esos 16 números; cambia una pista y deja de verificar."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 4 QAP
  {
    id = "qap",
    station = "QAP",
    name = L(
      "Curve street",
      "곡선 거리",
      "曲線街",
      "曲线街",
      "曲線通り",
      "Ulice křivek",
      "Calle de la curva"
    ),
    title = L(
      "112 checks become one",
      "112개 검사가 하나로",
      "112 個檢查變成一個",
      "112 个检查变成一个",
      "112 個の検査が一つに",
      "Ze 112 kontrol je jedna",
      "112 revisiones se vuelven una"
    ),
    lesson = L(
      "112 lines become one polynomial identity A.B - C = H.Z, checked at ONE secret point tau.",
      "112줄이 다항식 등식 하나 A.B - C = H.Z가 되고, 비밀 점 tau 하나에서만 검사한다.",
      "112 行變成一條多項式恆等式 A.B - C = H.Z，只喺一個秘密點 tau 檢查。",
      "112 行变成一条多项式恒等式 A.B - C = H.Z，只在一个秘密点 tau 上检查。",
      "112 行が多項式の等式 A.B - C = H.Z 一本になり、秘密の点 tau ただ一つで調べる。",
      "112 řádků se stane jednou polynomiální identitou A.B - C = H.Z, ověřenou v JEDINÉM tajném "
        .. "bodě tau.",
      "112 líneas se vuelven una identidad polinomial A.B - C = H.Z, revisada en UN punto secreto tau."
    ),
    bg = "bg_sigma",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美", "阿美", "メイ", "Mei", "Mei"),
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
          "112 行逐行檢查好慢。不如一次過檢查晒。",
          "112 行逐行检查很慢。不如一次全部检查完。",
          "112 行を一行ずつ調べるのは遅い。全部まとめて調べる。",
          "Kontrolovat 112 řádků po jednom je pomalé. Zkontroluj je radši všechny naráz.",
          "Revisar 112 líneas una por una es lento. Mejor revísalas todas de una vez."
        ),
      },
    },
    viz = "qap",
    story = L(
      "112 lines are 112 things to check. A SNARK squeezes them into ONE equation about polynomials "
        .. "(curves). Number the lines 1..112 and build curves A(x), B(x), C(x) so that at x = k they "
        .. "give line k's values. Then ALL lines hold exactly when A(x).B(x) - C(x) is zero at x = 1, 2, "
        .. "..., 112. This form is the QAP (quadratic arithmetic program).",
      "112줄은 검사할 것 112개. SNARK는 이것을 다항식(곡선)에 대한 등식 하나로 압축한다. 줄에 1..112 번호를 붙이고, x = k에서 k번째 줄의 값을 "
        .. "내는 곡선 A(x), B(x), C(x)를 만든다. 그러면 모든 줄이 성립한다 <=> A(x).B(x) - C(x)가 x = 1, 2, ..., 112에서 0. 이 "
        .. "형태가 QAP(quadratic arithmetic program)다.",
      "112 行就係 112 樣要檢查嘅嘢。SNARK 將佢哋壓縮成一條關於多項式（曲線）嘅等式。將行編號 1..112，砌出曲線 A(x)、B(x)、C(x)，令 x = k 時畀出第 k "
        .. "行嘅值。咁樣所有行成立 <=> A(x).B(x) - C(x) 喺 x = 1, 2, ..., 112 都係零。呢個形式叫 QAP（quadratic arithmetic "
        .. "program）。",
      "112 行就是 112 样要检查的东西。SNARK 把它们压缩成一条关于多项式（曲线）的等式。把行编号 1..112，造出曲线 A(x)、B(x)、C(x)，让 x = k 时给出第 "
        .. "k 行的值。这样所有行成立 <=> A(x).B(x) - C(x) 在 x = 1, 2, ..., 112 都是零。这个形式叫 QAP（quadratic arithmetic "
        .. "program）。",
      "112 行は調べるものが 112 個。SNARK はそれを多項式（曲線）についての等式一本に押し込む。行に 1..112 と番号をつけ、x = k で k 行目の値を返す曲線 "
        .. "A(x), B(x), C(x) を作る。すると全部の行が成り立つ <=> A(x).B(x) - C(x) が x = 1, 2, ..., 112 でゼロ。この形が "
        .. "QAP（quadratic arithmetic program）。",
      "112 řádků je 112 věcí ke kontrole. SNARK je vmáčkne do JEDNÉ rovnice o polynomech "
        .. "(křivkách). Očísluj řádky 1..112 a postav křivky A(x), B(x), C(x) tak, aby v x = k dávaly "
        .. "hodnoty řádku k. Pak platí VŠECHNY řádky právě tehdy, když je A(x).B(x) - C(x) nula v x = 1, "
        .. "2, ..., 112. Tenhle tvar je QAP (quadratic arithmetic program).",
      "112 líneas son 112 cosas por revisar. Un SNARK las comprime en UNA ecuación sobre polinomios "
        .. "(curvas). Numera las líneas 1..112 y construye curvas A(x), B(x), C(x) tales que en x = k "
        .. "den los valores de la línea k. Entonces TODAS las líneas se cumplen exactamente cuando "
        .. "A(x).B(x) - C(x) es cero en x = 1, 2, ..., 112. Esta forma es el QAP (quadratic arithmetic "
        .. "program)."
    ),
    stages = {
      {
        topic = "QAP",
        q = L(
          "Z(x) = (x-1)(x-2)...(x-112). What is Z(5)?",
          "Z(x) = (x-1)(x-2)...(x-112). Z(5)는?",
          "Z(x) = (x-1)(x-2)...(x-112)。Z(5) 係幾多？",
          "Z(x) = (x-1)(x-2)...(x-112)。Z(5) 是多少？",
          "Z(x) = (x-1)(x-2)...(x-112)。Z(5) は？",
          "Z(x) = (x-1)(x-2)...(x-112). Kolik je Z(5)?",
          "Z(x) = (x-1)(x-2)...(x-112). ¿Cuánto vale Z(5)?"
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
]],
          [[
# Z(x): 「消失多项式（vanishing polynomial）」- 造成在每个行号都是 0
# x: 只是一个变量；k 跑遍行号 1..112
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # 其中一个因子是 (5 - 5)
]],
          [[
# Z(x): 「消失多項式（vanishing polynomial）」- どの行番号でも 0 になるように作る
# x: ただの変数。k は行番号 1..112 を回る
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # 因数の一つが (5 - 5)
]],
          [[
# Z(x): "mizející polynom" - je 0 v KAŽDÉM čísle řádku
# x: jen proměnná; k probíhá čísla řádků 1..112
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # jeden činitel je (5 - 5)
]],
          [[
# Z(x): el "polinomio evanescente" - es 0 en CADA número de línea
# x: solo una variable; k recorre los números de línea 1..112
Z = lambda x: prod(x - k for k in range(1, 113))
Z(5) == ___        # un factor es (5 - 5)
]]
        ),
        accept = { "0", "zero", "영", "零", "ゼロ", "nula", "cero" },
        answer = "0",
        hint = L(
          "Same trick as (v-1)(v-2)(v-3)(v-4): one zero factor kills the product.",
          "(v-1)(v-2)(v-3)(v-4)와 같은 트릭: 0인 인수 하나가 곱 전체를 0으로.",
          "同 (v-1)(v-2)(v-3)(v-4) 一樣嘅招數：一個零因子令成個乘積變零。",
          "和 (v-1)(v-2)(v-3)(v-4) 一样的招数：一个零因子让整个乘积变零。",
          "(v-1)(v-2)(v-3)(v-4) と同じ手: ゼロの因数が一つあれば積は消える。",
          "Stejný trik jako u (v-1)(v-2)(v-3)(v-4): jeden nulový činitel zabije celý součin.",
          "El mismo truco que (v-1)(v-2)(v-3)(v-4): un factor cero mata el producto."
        ),
        ok = L(
          "0. Z is zero at 1..112 and nowhere else. It marks 'the line numbers'.",
          "0. Z는 1..112에서만 0. '줄 번호들'을 표시하는 다항식.",
          "0。Z 只喺 1..112 係零。佢標記住「啲行號」。",
          "0。Z 只在 1..112 是零，别处都不是。它标记着「那些行号」。",
          "0。Z は 1..112 でだけゼロ。「行番号たち」に印をつける。",
          "0. Z je nula v 1..112 a nikde jinde. Označuje 'čísla řádků'.",
          "0. Z es cero en 1..112 y en ningún otro lado. Marca 'los números de línea'."
        ),
      },
      {
        topic = "QAP",
        q = L(
          "If every line holds, dividing A.B - C by Z leaves remainder ___.",
          "모든 줄이 성립하면, A.B - C를 Z로 나눈 나머지는 ___.",
          "如果每行都成立，A.B - C 除以 Z 嘅餘數係 ___。",
          "如果每行都成立，A.B - C 除以 Z 的余数是 ___。",
          "全部の行が成り立つなら、A.B - C を Z で割った余りは ___。",
          "Když platí každý řádek, dělení A.B - C polynomem Z dá zbytek ___.",
          "Si toda línea se cumple, dividir A.B - C entre Z deja residuo ___."
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
]],
          [[
# A(x), B(x), C(x): 每张挑选表一条曲线，在 x = k 时与第 k 行一致
# H(x): 商。阿美算出来；只有每行都成立它才存在
# （有一行坏了就会剩下非零余数，没有 H 遮得住）
A(x) * B(x) - C(x) == H(x) * Z(x)     # 余数 ___
]],
          [[
# A(x), B(x), C(x): 選択リストごとに一本の曲線。x = k で k 行目と一致
# H(x): 商。メイが計算する。全部の行が成り立つときだけ存在する
# (壊れた行があれば 0 でない余りが残り、どんな H でも隠せない)
A(x) * B(x) - C(x) == H(x) * Z(x)     # 余り ___
]],
          [[
# A(x), B(x), C(x): křivka na každý seznam, v x = k sedí s řádkem k
# H(x): podíl. Mei ho spočítá; EXISTUJE, jen když platí každý řádek
# (rozbitý řádek nechá nenulový zbytek a žádné H ho neschová)
A(x) * B(x) - C(x) == H(x) * Z(x)     # zbytek ___
]],
          [[
# A(x), B(x), C(x): una curva por lista, igual a la línea k en x = k
# H(x): el cociente. Mei lo calcula; EXISTE solo si toda línea se cumple
# (una línea rota deja residuo no cero, y ningún H lo tapa)
A(x) * B(x) - C(x) == H(x) * Z(x)     # residuo ___
]]
        ),
        accept = {
          "0",
          "zero",
          "none",
          "nothing",
          "영",
          "없음",
          "零",
          "冇",
          "没有",
          "何もない",
          "ゼロ",
          "nula",
          "nic",
          "cero",
          "nada",
          "ninguno",
        },
        answer = "0",
        hint = L(
          "'Divides exactly' means what remainder?",
          "'딱 나누어떨어진다'는 나머지가 얼마라는 뜻?",
          "「啱啱除得盡」即係餘數係幾多？",
          "「刚好除得尽」是指余数是多少？",
          "「ちょうど割り切れる」とは余りがいくつということ？",
          "'Dělí beze zbytku' znamená jaký zbytek?",
          "'Divide exacto' significa ¿qué residuo?"
        ),
        ok = L(
          "0. Mei's proof will really be: 'here is H, the division worked'.",
          "0. 메이의 증명은 결국 '여기 H가 있다, 나눗셈이 됐다'는 말이다.",
          "0。阿美嘅證明其實就係：「H 喺度，除到盡」。",
          "0。阿美的证明其实就是：「H 在这里，除得尽」。",
          "0。メイの証明は結局「ここに H がある、割り算はできた」ということ。",
          "0. Meiin důkaz vlastně říká: 'tady je H, dělení vyšlo'.",
          "0. La prueba de Mei será en realidad: 'aquí está H, la división salió'."
        ),
      },
      {
        topic = "QAP",
        q = L(
          "Check at ONE random point instead of 112. Two different curves can agree on at most as many "
            .. "points as their ___.",
          "112개 대신 무작위 점 하나에서 검사. 서로 다른 두 곡선이 겹칠 수 있는 점의 수는 최대 그 ___만큼.",
          "唔使檢查 112 個點，淨係檢查一個隨機點。兩條唔同嘅曲線最多只可以喺 ___ 咁多個點重合。",
          "不用检查 112 个点，只检查一个随机点。两条不同的曲线重合的点数，最多等于它们的 ___。",
          "112 個ではなく無作為な点 1 つで調べる。異なる 2 本の曲線が一致できる点は、多くてもその ___ の分だけ。",
          "Kontroluj v JEDNOM náhodném bodě místo 112. Dvě různé křivky se mohou shodnout nejvýš v "
            .. "tolika bodech, kolik je jejich ___.",
          "Revisa en UN punto al azar en vez de 112. Dos curvas distintas coinciden a lo más en tantos "
            .. "puntos como su ___."
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
]],
          [[
# tau: 一个秘密随机数，在 setup 时选一次（下一条街）
# 只在一个点检查 A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) 就够了：
# 两条不同的曲线最多只能在 `___` 这么多个点上重合
# （这里大约 112 个点，而可能的 tau 有 ~2^254 个：作弊几乎永远撞不中）
degree_of_A = 111
]],
          [[
# tau: 秘密の乱数。setup で一度だけ選ぶ（次の通り）
# A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) を 1 点で調べれば十分:
# 異なる 2 本の曲線が一致できる点は多くても `___` 個
# (ここでは約 112 点、tau の候補は ~2^254 個: いかさまはまず当たらない)
degree_of_A = 111
]],
          [[
# tau: tajné náhodné číslo, zvolené jednou při setupu (další ulice)
# stačí ověřit A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) v JEDNOM bodě:
# dvě různé křivky se shodnou nejvýš v `___` bodech
# (tady asi 112 bodů z ~2^254 možných tau: podvod skoro nikdy netrefí)
degree_of_A = 111
]],
          [[
# tau: número secreto al azar, elegido en el setup (calle siguiente)
# revisar A(tau)*B(tau) - C(tau) == H(tau)*Z(tau) en UN punto basta:
# dos curvas distintas coinciden a lo más en `___` puntos
# (aquí unos 112 puntos, de ~2^254 taus posibles: la trampa casi nunca pega)
degree_of_A = 111
]]
        ),
        accept = { "degree", "d", "차수", "次數", "度數", "次数", "度数", "stupeň", "grado" },
        answer = "degree",
        hint = L(
          "The highest power of x in the curve. A straight line has 1, a parabola 2.",
          "곡선에서 x의 최고 차수. 직선은 1, 포물선은 2.",
          "曲線入面 x 嘅最高次方。直線係 1，拋物線係 2。",
          "曲线里 x 的最高次方。直线是 1，抛物线是 2。",
          "曲線に出てくる x の最高次数。直線は 1、放物線は 2。",
          "Nejvyšší mocnina x v křivce. Přímka má 1, parabola 2.",
          "La potencia más alta de x en la curva. Una recta tiene 1, una parábola 2."
        ),
        ok = L(
          "degree. This is the Schwartz-Zippel idea: one random point is as good as all of them.",
          "degree(차수). 슈와르츠-지펠 아이디어: 무작위 점 하나가 모든 점만큼 좋다.",
          "degree（次數）。呢個係 Schwartz-Zippel 嘅諗法：一個隨機點同全部點一樣好。",
          "degree（次数）。这就是 Schwartz-Zippel 的想法：一个随机点和全部点一样好。",
          "degree（次数）。これが Schwartz-Zippel の考え: 無作為な点 1 つは全部の点と同じくらい良い。",
          "degree (stupeň). To je myšlenka Schwartz-Zippel: jeden náhodný bod je stejně dobrý jako všechny.",
          "degree (grado). Es la idea de Schwartz-Zippel: un punto al azar vale tanto como todos."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 5 SETUP
  {
    id = "setup",
    station = "SETUP",
    name = L(
      "Ceremony hall",
      "의식 홀",
      "儀式大堂",
      "仪式大厅",
      "儀式の広間",
      "Obřadní síň",
      "Salón de la ceremonia"
    ),
    title = L(
      "Toxic waste and two keys",
      "독성 폐기물과 열쇠 둘",
      "有毒廢料同兩條鎖匙",
      "有毒废料和两把密钥",
      "有害廃棄物と鍵二つ",
      "Toxický odpad a dva klíče",
      "Residuo tóxico y dos llaves"
    ),
    lesson = L(
      "Setup hides tau, alpha, beta, gamma, delta in curve points, hands out pk and vk, and must "
        .. "delete the toxic waste.",
      "Setup은 tau, alpha, beta, gamma, delta를 곡선 점 안에 숨기고 pk와 vk를 나눠 준 뒤, 독성 폐기물을 반드시 지운다.",
      "Setup 將 tau、alpha、beta、gamma、delta 藏入曲線點，派出 pk 同 vk，然後一定要銷毀有毒廢料。",
      "Setup 把 tau、alpha、beta、gamma、delta 藏进曲线点，发出 pk 和 vk，然后必须销毁有毒废料。",
      "Setup は tau, alpha, beta, gamma, delta を曲線の点に隠し、pk と vk を配り、有害廃棄物を必ず消す。",
      "Setup schová tau, alpha, beta, gamma, delta do bodů na křivce, vydá pk a vk a musí smazat "
        .. "toxický odpad.",
      "El setup esconde tau, alpha, beta, gamma, delta en puntos de la curva, entrega pk y vk, y "
        .. "debe borrar el residuo tóxico."
    ),
    bg = "bg_office",
    portrait = "portrait_officer",
    speaker = L(
      "Ceremony host",
      "의식 진행자",
      "儀式主持",
      "仪式主持",
      "儀式の進行役",
      "Vedoucí obřadu",
      "Anfitrión"
    ),
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
          "我抽隨機數，封入點入面，然後燒咗張紙。",
          "我抽随机数，封进点里面，然后把纸烧掉。",
          "私が乱数を引き、点の中に封じ、紙を燃やす。",
          "Vylosuju náhodná čísla, zapečetím je do bodů a papír spálím.",
          "Yo saco los números al azar, los sello en puntos y quemo el papel."
        ),
      },
    },
    viz = "setup",
    story = L(
      "Before any proof, a one-time setup. Random secrets are drawn: tau (the check point) and "
        .. "alpha, beta, gamma, delta (glue that stops cheating). They are hidden inside curve points - "
        .. "like g^tau in quest 1, you can compute WITH the number but cannot read it - and then "
        .. "DELETED. What remains are two keys: pk (big, for Mei) and vk (small, for Uncle Wing).",
      "증명 전에 딱 한 번 setup. 무작위 비밀을 뽑는다: tau(검사 지점)와 alpha, beta, gamma, delta(속임수를 막는 접착제). 이들은 곡선 점 "
        .. "안에 숨겨진다 - 퀘스트 1의 g^tau처럼 그 수로 계산은 할 수 있지만 읽을 수는 없다 - 그리고 삭제된다. 남는 것은 열쇠 둘: pk(크다, 메이용)와 "
        .. "vk(작다, 윙 아저씨용).",
      "證明之前，先做一次 setup。抽出隨機秘密：tau（檢查點）同 alpha、beta、gamma、delta（防止作弊嘅膠水）。佢哋藏喺曲線點入面 - 好似任務 1 嘅 "
        .. "g^tau，可以用個數字計嘢但讀唔到佢 - 然後就銷毀。剩低兩條鎖匙：pk（大，畀阿美）同 vk（細，畀榮叔）。",
      "任何证明之前，先做一次性的 setup。抽出随机秘密：tau（检查点）和 alpha、beta、gamma、delta（防止作弊的胶水）。它们藏在曲线点里面 - 就像任务 1 的 "
        .. "g^tau，可以用这个数字算东西但读不出它 - 然后被删除。剩下两把密钥：pk（大，给阿美）和 vk（小，给荣叔）。",
      "証明の前に一度だけ setup。無作為な秘密を引く: tau（検査する点）と alpha, beta, gamma, "
        .. "delta（いかさまを止める接着剤）。これらは曲線の点の中に隠される - クエスト 1 の g^tau のように、その数で計算はできるが読めない - "
        .. "そして削除される。残るのは鍵が二つ: pk（大きい、メイ用）と vk（小さい、ウィンおじさん用）。",
      "Před každým důkazem je jednorázový setup. Vylosují se náhodná tajemství: tau (kontrolní bod) "
        .. "a alpha, beta, gamma, delta (lepidlo proti podvodům). Schovají se do bodů na křivce - jako "
        .. "g^tau v úkolu 1: s číslem se dá počítat, ale přečíst se nedá - a pak se SMAŽOU. Zbydou dva "
        .. "klíče: pk (velký, pro Mei) a vk (malý, pro strýce Winga).",
      "Antes de cualquier prueba, un setup único. Se sacan secretos al azar: tau (el punto de "
        .. "revisión) y alpha, beta, gamma, delta (el pegamento que impide hacer trampa). Se esconden "
        .. "dentro de puntos de la curva - como g^tau en la misión 1, puedes calcular CON el número pero "
        .. "no leerlo - y luego se BORRAN. Quedan dos llaves: pk (grande, para Mei) y vk (chica, para el "
        .. "tío Wing)."
    ),
    stages = {
      {
        topic = "SETUP",
        q = L(
          "After the setup, tau and friends must be ___ (whoever keeps them can forge proofs).",
          "setup이 끝나면 tau와 친구들은 반드시 ___ (갖고 있는 사람은 증명을 위조할 수 있다).",
          "setup 完咗之後，tau 同佢啲朋友一定要 ___（邊個留住就可以偽造證明）。",
          "setup 做完之后，tau 和它的朋友们必须 ___（谁留着它们就能伪造证明）。",
          "setup のあと、tau とその仲間は必ず ___（持っている者は証明を偽造できる）。",
          "Po setupu je nutné tau a spol. ___ (kdo si je nechá, umí padělat důkazy).",
          "Terminado el setup, tau y compañía deben quedar ___ (quien los guarde puede falsificar pruebas)."
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
]],
          [[
# setup: 每个电路做一次，在任何证明之前。rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: 随机秘密 = 「有毒废料（toxic waste）」
# [tau]G, [tau^2]G, ...: 同样的数字藏在曲线点里面
#                        （G 是固定的点；[n]G = 「G 自己加自己 n 次」）
# 点造好之后，原本的数字就 ___
]],
          [[
# setup: 回路ごとに一度、証明の前に実行。rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: 無作為な秘密 = 「有害廃棄物（toxic waste）」
# [tau]G, [tau^2]G, ...: 同じ数字を曲線の点の中に隠したもの
#                        (G は固定の点。[n]G =「G を n 回足したもの」)
# 点を作ったあと、生の数字は ___
]],
          [[
# setup: JEDNOU na obvod, před každým důkazem. rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: náhodná tajemství = "toxický odpad"
# [tau]G, [tau^2]G, ...: ta samá čísla schovaná v bodech na křivce
#                        (G je pevný bod; [n]G = "G sečtené se sebou n-krát")
# jakmile jsou body hotové, je nutné obyčejná čísla ___
]],
          [[
# setup: UNA vez por circuito, antes de probar. rust/src/api.rs setup()
# tau, alpha, beta, gamma, delta: secretos al azar = el "residuo tóxico"
# [tau]G, [tau^2]G, ...: los mismos números dentro de puntos de curva
#                        (G es un punto fijo; [n]G = "G sumado a sí mismo n veces")
# hechos los puntos, los números en claro quedan ___
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
          "删除",
          "销毁",
          "削除",
          "破棄",
          "消去",
          "smazat",
          "smazáno",
          "zničeno",
          "borrado",
          "borrados",
          "eliminado",
          "destruido",
        },
        answer = "deleted",
        hint = L(
          "The host burns the paper.",
          "진행자가 종이를 태운다.",
          "主持燒咗張紙。",
          "主持把纸烧掉。",
          "進行役が紙を燃やす。",
          "Vedoucí obřadu spálí papír.",
          "El anfitrión quema el papel."
        ),
        ok = L(
          "deleted. Note: rust/src/api.rs uses a FIXED seed for study. Real systems run a ceremony with "
            .. "many people.",
          "삭제. 참고: rust/src/api.rs는 공부용으로 고정 시드를 쓴다. 실제 시스템은 여러 사람이 참여하는 의식을 연다.",
          "銷毀。留意：rust/src/api.rs 用固定種子嚟學習。真正嘅系統會搞多人參與嘅儀式。",
          "删除。注意：rust/src/api.rs 为了学习用的是固定种子。真实系统会办一场很多人参与的仪式。",
          "削除。注: rust/src/api.rs は学習用に固定シードを使う。実際のシステムは大勢が参加する儀式を行う。",
          "smazat. Pozn.: rust/src/api.rs používá pro výuku PEVNÝ seed. Skutečné systémy pořádají obřad "
            .. "s mnoha lidmi.",
          "borrados. Nota: rust/src/api.rs usa una semilla FIJA para estudiar. Los sistemas reales "
            .. "hacen una ceremonia con mucha gente."
        ),
      },
      {
        topic = "SETUP",
        q = L(
          "Two keys come out. Mei, the prover, gets the ___ key.",
          "열쇠 둘이 나온다. 증명자 메이가 받는 것은 ___ 키.",
          "出到兩條鎖匙。證明者阿美攞 ___ 鎖匙。",
          "出来两把密钥。证明者阿美拿 ___ 密钥。",
          "鍵が二つ出てくる。証明者のメイが受け取るのは ___ の鍵。",
          "Vypadnou dva klíče. Mei, dokazovatelka, dostane klíč ___.",
          "Salen dos llaves. Mei, la probadora, recibe la llave ___."
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
]],
          [[
# pk: proving key（证明密钥）。这里 22736 bytes。装着整个电路的 [tau^i]G
# vk: verifying key（验证密钥）。这里 776 bytes。只有几个点
# 两个都是公开的；重点是大小的差别
prover_key   = ___    # 阿美
verifier_key = vk     # 荣叔
]],
          [[
# pk: proving key（証明鍵）。ここでは 22736 bytes。回路全体の [tau^i]G を持つ
# vk: verifying key（検証鍵）。ここでは 776 bytes。点が数個だけ
# どちらも公開。大きさの差こそが要点
prover_key   = ___    # メイ
verifier_key = vk     # ウィンおじさん
]],
          [[
# pk: proving key.   tady 22736 bytů. Drží [tau^i]G pro celý obvod
# vk: verifying key.   tady 776 bytů. Jen pár bodů
# oba jsou veřejné; jde právě o ten rozdíl ve velikosti
prover_key   = ___    # Mei
verifier_key = vk     # strýc Wing
]],
          [[
# pk: proving key.   22736 bytes aquí. Guarda [tau^i]G de todo el circuito
# vk: verifying key.   776 bytes aquí. Solo unos cuantos puntos
# ambas son públicas; la diferencia de tamaño es el punto
prover_key   = ___    # Mei
verifier_key = vk     # el tío Wing
]]
        ),
        accept = {
          "pk",
          "proving",
          "proving key",
          "prover key",
          "증명",
          "증명 키",
          "증명키",
          "證明",
          "證明鎖匙",
          "证明",
          "证明密钥",
          "証明鍵",
          "dokazovací klíč",
          "llave de prueba",
          "clave de prueba",
        },
        answer = "pk",
        hint = L(
          "p for prover.",
          "p는 prover(증명자).",
          "p 代表 prover。",
          "p 代表 prover。",
          "p は prover。",
          "p jako prover.",
          "p de probador."
        ),
        ok = L(
          "pk. Big key for the one who does the work, small key for the one who checks.",
          "pk. 일하는 쪽은 큰 열쇠, 확인하는 쪽은 작은 열쇠.",
          "pk。做嘢嗰個攞大鎖匙，檢查嗰個攞細鎖匙。",
          "pk。做事的那个拿大密钥，检查的那个拿小密钥。",
          "pk。働く側に大きい鍵、確かめる側に小さい鍵。",
          "pk. Velký klíč pro toho, kdo dělá práci, malý pro toho, kdo kontroluje.",
          "pk. Llave grande para quien hace el trabajo, llave chica para quien revisa."
        ),
      },
      {
        topic = "SETUP",
        q = L(
          "The keys are baked for THIS circuit. A 9x9 board would need a new ___.",
          "이 열쇠는 이 회로 전용. 9x9 판이면 새 ___이 필요하다.",
          "呢啲鎖匙係為呢個電路整嘅。9x9 板就要新嘅 ___。",
          "这些密钥是为这个电路造的。9x9 的盘就要新的 ___。",
          "鍵はこの回路のために焼かれている。9x9 の盤なら新しい ___ が要る。",
          "Klíče jsou upečené pro TENHLE obvod. Mřížka 9x9 by potřebovala nový ___.",
          "Las llaves se hornean para ESTE circuito. Un tablero 9x9 necesitaría un nuevo ___."
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
]],
          [[
# Groth16 密钥是电路专用的：112 行烘进了 pk 和 vk
# 换电路（9x9 盘、新规则）-> 跑一次新的 ___
# （PLONK 这类其他 SNARK 可以一个 setup 用在很多电路上）
]],
          [[
# Groth16 の鍵は回路専用: 112 行が pk と vk に焼き込まれている
# 回路を変えたら（9x9 の盤、新しい規則）-> 新しい ___ を実行
# (PLONK のような他の SNARK は一つの setup を多くの回路に使い回す)
]],
          [[
# klíče Groth16 patří jednomu obvodu: 112 řádků je zapečeno v pk a vk
# změň obvod (mřížka 9x9, nové pravidlo) -> spusť nový ___
# (jiné SNARKy, třeba PLONK, použijí jeden setup pro spoustu obvodů)
]],
          [[
# las llaves Groth16 son por circuito: las 112 líneas van en pk y vk
# cambia el circuito (tablero 9x9, nueva regla) -> corre un nuevo ___
# (otros SNARK, como PLONK, reusan un setup para muchos circuitos)
]]
        ),
        accept = {
          "setup",
          "trusted setup",
          "ceremony",
          "셋업",
          "세팅",
          "설정",
          "의식",
          "設置",
          "儀式",
          "设置",
          "仪式",
          "セットアップ",
          "設定",
          "nastavení",
          "ceremonie",
          "ceremonia",
          "configuración",
        },
        answer = "setup",
        hint = L(
          "This street's name.",
          "이 거리의 이름.",
          "呢條街嘅名。",
          "这条街的名字。",
          "この通りの名前。",
          "Jméno téhle ulice.",
          "El nombre de esta calle."
        ),
        ok = L(
          "setup. That is the price of Groth16's tiny proofs.",
          "setup. Groth16의 아주 작은 증명이 치르는 대가.",
          "setup。呢個就係 Groth16 超細證明嘅代價。",
          "setup。这就是 Groth16 超小证明的代价。",
          "setup。それが Groth16 の極小の証明が払う代価。",
          "setup. To je cena za maličké důkazy Groth16.",
          "setup. Ese es el precio de las pruebas diminutas de Groth16."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 6 PAIRING
  {
    id = "pairing",
    station = "PAIRING",
    name = L(
      "Mirror lane",
      "거울 골목",
      "鏡巷",
      "镜子巷",
      "鏡の路地",
      "Zrcadlová ulička",
      "Callejón de los espejos"
    ),
    title = L(
      "Multiply behind the curtain",
      "커튼 뒤에서 곱하기",
      "喺布簾後面乘",
      "在帘子后面做乘法",
      "カーテンの裏で掛ける",
      "Násobení za oponou",
      "Multiplicar tras la cortina"
    ),
    lesson = L(
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): the ONE hidden multiplication the check needs.",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): 검사에 필요한 단 한 번의 숨은 곱셈.",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b)：檢查需要嘅唯一一次隱藏乘法。",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b)：检查所需要的唯一一次隐藏乘法。",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): 検査に必要なただ一度の隠れた掛け算。",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): jediné skryté násobení, které kontrola potřebuje.",
      "e([a]G1, [b]G2) = e(G1, G2)^(a.b): la ÚNICA multiplicación oculta que necesita la revisión."
    ),
    bg = "bg_hash",
    portrait = "portrait_clerk",
    speaker = L("Uncle Wing", "윙 아저씨", "榮叔", "荣叔", "ウィンおじさん", "Strýc Wing", "Tío Wing"),
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
          "封咗嘅數我加到。要乘兩個，就要呢面鏡。",
          "封住的数我加得了。要把两个相乘，就需要这面镜子。",
          "封じた数は足せる。二つを掛けるには、この鏡が要る。",
          "Zapečetěná čísla umím sčítat. Abych dvě vynásobil, potřebuju tohle zrcadlo.",
          "Puedo sumar números sellados. Para multiplicar dos, necesito este espejo."
        ),
      },
    },
    viz = "pairing",
    story = L(
      "Uncle Wing holds vk and the proof. Every number inside is hidden in a curve point. Hidden "
        .. "numbers can be ADDED (quest 1: g^a . g^b = g^(a+b)), but the check A(tau).B(tau) needs one "
        .. "MULTIPLICATION of hidden numbers. A pairing e(P, Q) is exactly that: one G1 point and one G2 "
        .. "point go in, and out comes e(G1, G2) raised to the PRODUCT of the hidden numbers.",
      "윙 아저씨는 vk와 증명을 갖고 있다. 안의 모든 수는 곡선 점 안에 숨어 있다. 숨은 수는 더할 수 있다(퀘스트 1: g^a . g^b = g^(a+b)). 그런데 "
        .. "검사 A(tau).B(tau)에는 숨은 수끼리의 곱셈 한 번이 필요하다. 페어링 e(P, Q)가 바로 그것: G1 점 하나와 G2 점 하나가 들어가면, 숨은 두 수의 "
        .. "곱을 지수로 하는 e(G1, G2)가 나온다.",
      "榮叔手上有 vk 同證明。入面每個數字都藏喺曲線點入面。藏起嘅數可以加（任務 1：g^a . g^b = g^(a+b)），但檢查 A(tau).B(tau) "
        .. "需要隱藏數之間乘一次。配對 e(P, Q) 就係咁：入一個 G1 點同一個 G2 點，出嚟嘅係 e(G1, G2) 嘅「兩個隱藏數嘅乘積」次方。",
      "荣叔手上有 vk 和证明。里面每个数字都藏在曲线点里。藏起来的数可以相加（任务 1：g^a . g^b = g^(a+b)），但检查 A(tau).B(tau) "
        .. "需要隐藏数之间乘一次。配对 e(P, Q) 正是如此：进去一个 G1 点和一个 G2 点，出来的是 e(G1, G2) 的「两个隐藏数之积」次方。",
      "ウィンおじさんは vk と証明を持っている。中の数字はすべて曲線の点に隠れている。隠れた数は足せる（クエスト 1: g^a . g^b = g^(a+b)）が、検査 "
        .. "A(tau).B(tau) には隠れた数どうしの掛け算が一回必要。ペアリング e(P, Q) がまさにそれ: G1 の点一つと G2 の点一つを入れると、隠れた二つの数の積を指数にした "
        .. "e(G1, G2) が出てくる。",
      "Strýc Wing má vk a důkaz. Každé číslo uvnitř je schované v bodě na křivce. Skrytá čísla se "
        .. "dají SČÍTAT (úkol 1: g^a . g^b = g^(a+b)), ale kontrola A(tau).B(tau) potřebuje jedno "
        .. "NÁSOBENÍ skrytých čísel. Párování e(P, Q) je přesně to: dovnitř jde jeden bod z G1 a jeden z "
        .. "G2 a ven vyleze e(G1, G2) umocněné na SOUČIN těch skrytých čísel.",
      "El tío Wing tiene vk y la prueba. Cada número de adentro está escondido en un punto de la "
        .. "curva. Los números ocultos se pueden SUMAR (misión 1: g^a . g^b = g^(a+b)), pero la revisión "
        .. "A(tau).B(tau) necesita una MULTIPLICACIÓN de números ocultos. Un emparejamiento e(P, Q) es "
        .. "justo eso: entran un punto de G1 y un punto de G2, y sale e(G1, G2) elevado al PRODUCTO de "
        .. "los números ocultos."
    ),
    stages = {
      {
        topic = "PAIRING",
        q = L(
          "e([3]G1, [5]G2) = e(G1, G2)^___",
          "e([3]G1, [5]G2) = e(G1, G2)^___",
          "e([3]G1, [5]G2) = e(G1, G2)^___",
          "e([3]G1, [5]G2) = e(G1, G2)^___",
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
]],
          [[
# G1, G2: 曲线 BN254 上的两组点。[a]G1 = 「藏着 a 的点」
# e(P, Q): 配对。取一个 G1 点和一个 G2 点，落在第三组
#          GT 里。让它有用的规则：
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- 把隐藏的数相乘
e([3]G1, [5]G2) == e(G1, G2) ** ___
]],
          [[
# G1, G2: 曲線 BN254 上の点の二つの群。[a]G1 =「a を隠した点」
# e(P, Q): ペアリング。G1 の点と G2 の点を一つずつ取り、三つ目の
#          群 GT に着地する。これを役立たせる規則:
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- 隠れた数を掛ける
e([3]G1, [5]G2) == e(G1, G2) ** ___
]],
          [[
# G1, G2: dvě grupy bodů na křivce BN254. [a]G1 = "bod schovávající a"
# e(P, Q): párování. Vezme bod z G1 a bod z G2 a spadne do
#          třetí grupy GT. Pravidlo, díky kterému je užitečné:
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- vynásobí skrytá čísla
e([3]G1, [5]G2) == e(G1, G2) ** ___
]],
          [[
# G1, G2: dos grupos de puntos en la curva BN254. [a]G1 = "el punto que oculta a"
# e(P, Q): el emparejamiento. Toma un punto G1 y uno G2, y cae en un
#          tercer grupo GT. La regla que lo hace útil:
#          e([a]G1, [b]G2) = e(G1, G2)^(a * b)   <- multiplica los ocultos
e([3]G1, [5]G2) == e(G1, G2) ** ___
]]
        ),
        accept = { "15", "fifteen", "십오", "열다섯", "十五", "patnáct", "quince" },
        answer = "15",
        hint = L("3 x 5.", "3 x 5.", "3 x 5。", "3 x 5。", "3 x 5。", "3 x 5.", "3 x 5."),
        ok = L(
          "15. Neither 3 nor 5 was ever visible; their product appeared anyway.",
          "15. 3도 5도 한 번도 보이지 않았지만, 곱은 나타났다.",
          "15。3 同 5 由頭到尾都冇露面，佢哋嘅乘積照樣出現。",
          "15。3 和 5 从头到尾都没露面，它们的积照样出现了。",
          "15。3 も 5 も一度も見えなかったのに、積は出てきた。",
          "15. Ani 3, ani 5 nebyly nikdy vidět; jejich součin se stejně objevil.",
          "15. Ni el 3 ni el 5 se vieron nunca; su producto apareció igual."
        ),
      },
      {
        topic = "PAIRING",
        q = L(
          "Groth16 verify is one line: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). How many pairings?",
          "Groth16 검증은 한 줄: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). 페어링 몇 번?",
          "Groth16 驗證就一行：e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta)。幾多次配對？",
          "Groth16 验证就一行：e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta)。几次配对？",
          "Groth16 の検証は一行: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta)。ペアリングは何回？",
          "Ověření Groth16 je jeden řádek: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). Kolik párování?",
          "Verificar Groth16 es una línea: e(A,B) = e(alpha,beta) . e(L,gamma) . e(C,delta). ¿Cuántos "
            .. "emparejamientos?"
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
]],
          [[
# A, B, C: 证明的三个点（A、C 在 G1；B 在 G2）
# alpha, beta, gamma, delta: 来自 vk 的点（setup 的胶水）
# L: 荣叔自己用 16 个 clues 和 vk 造出来的一个点
#    （所以另一块盘的证明在这里就死）
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ___ 次配对
]],
          [[
# A, B, C: 証明の三つの点 (A, C は G1、B は G2)
# alpha, beta, gamma, delta: vk から来る点 (setup の接着剤)
# L: ウィンおじさんが 16 個の clues と vk から自分で作る点
#    (だから別の盤の証明はまさにここで落ちる)
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ペアリング ___ 回
]],
          [[
# A, B, C: tři body důkazu (A, C v G1; B v G2)
# alpha, beta, gamma, delta: body z vk (lepidlo ze setupu)
# L: bod, který si strýc Wing postaví SÁM z 16 clues a vk
#    (proto důkaz pro jinou mřížku selže právě tady)
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ___ párování
]],
          [[
# A, B, C: los tres puntos de la prueba (A, C en G1; B en G2)
# alpha, beta, gamma, delta: puntos de vk (el pegamento del setup)
# L: un punto que el tío Wing arma ÉL MISMO con las 16 pistas y vk
#    (por eso una prueba de otro tablero muere aquí mismo)
e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)     # ___ emparejamientos
]]
        ),
        accept = { "4", "four", "넷", "네 번", "4번", "四", "čtyři", "cuatro" },
        answer = "4",
        hint = L(
          "Count the e( ).",
          "e( )를 세어보세요.",
          "數下有幾多個 e( )。",
          "数一数有几个 e( )。",
          "e( ) の数を数えてみて。",
          "Spočítej e( ).",
          "Cuenta los e( )."
        ),
        ok = L(
          "4. rust/src/api.rs: 1.5 ms. The same four whether the circuit has 112 lines or a million.",
          "4. rust/src/api.rs: 1.5ms. 회로가 112줄이든 백만 줄이든 똑같이 네 번.",
          "4。rust/src/api.rs：1.5 ms。電路 112 行定一百萬行，都係四次。",
          "4。rust/src/api.rs：1.5 ms。电路是 112 行还是一百万行，都是四次。",
          "4。rust/src/api.rs: 1.5 ms。回路が 112 行でも百万行でも同じ四回。",
          "4. rust/src/api.rs: 1,5 ms. Pořád čtyři, ať má obvod 112 řádků nebo milion.",
          "4. rust/src/api.rs: 1.5 ms. Los mismos cuatro con 112 líneas o con un millón."
        ),
      },
      {
        topic = "PAIRING",
        q = L(
          "A and C live in G1, B in G2. Both sides of the check live in ___.",
          "A와 C는 G1에, B는 G2에 산다. 검사식의 양변은 ___에 산다.",
          "A 同 C 住喺 G1，B 住喺 G2。檢查式兩邊住喺 ___。",
          "A 和 C 住在 G1，B 住在 G2。检查式两边住在 ___。",
          "A と C は G1、B は G2 に住む。検査式の両辺は ___ に住む。",
          "A a C žijí v G1, B v G2. Obě strany kontroly žijí v ___.",
          "A y C viven en G1, B en G2. Los dos lados de la revisión viven en ___."
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
]],
          [[
# 在 BN254 上各自住哪：
# A, C  -> G1   （压缩后各 32 bytes）
# B     -> G2   （64 bytes：它的坐标是数对）
# e(.,.) 的输出，检查式两边 -> ___
]],
          [[
# BN254 の上でそれぞれが住む場所:
# A, C  -> G1   (圧縮して各 32 bytes)
# B     -> G2   (64 bytes: 座標が数の組だから)
# e(.,.) の出力、検査式の両辺 -> ___
]],
          [[
# kde co žije na BN254:
# A, C  -> G1   (po 32 bytech, komprimovaně)
# B     -> G2   (64 bytů: souřadnice jsou dvojice čísel)
# výstup e(.,.), obě strany kontroly -> ___
]],
          [[
# dónde vive cada cosa en BN254:
# A, C  -> G1   (32 bytes cada uno, comprimidos)
# B     -> G2   (64 bytes: sus coordenadas son pares de números)
# salida de e(.,.), los dos lados de la revisión -> ___
]]
        ),
        accept = {
          "gt",
          "g_t",
          "g t",
          "target group",
          "타깃 그룹",
          "目標群",
          "目标群",
          "ターゲット群",
          "cílová grupa",
          "grupo objetivo",
        },
        answer = "GT",
        hint = L(
          "G with a T: the Target group.",
          "G에 T: Target 그룹.",
          "G 加 T：Target 群。",
          "G 加 T：Target 群。",
          "G に T: Target 群。",
          "G s T: cílová (Target) grupa.",
          "G con T: el grupo Target."
        ),
        ok = L(
          "GT. Three groups, one bridge between them. That bridge is the whole reason for the curve.",
          "GT. 그룹 셋, 그 사이 다리 하나. 그 다리가 이 곡선을 쓰는 이유의 전부다.",
          "GT。三組，中間一條橋。呢條橋就係用呢條曲線嘅全部原因。",
          "GT。三个群，中间一座桥。这座桥就是用这条曲线的全部理由。",
          "GT。群が三つ、その間に橋が一本。この橋こそ、この曲線を使う理由のすべて。",
          "GT. Tři grupy a mezi nimi jeden most. Ten most je celý důvod, proč tahle křivka.",
          "GT. Tres grupos, un puente entre ellos. Ese puente es toda la razón de la curva."
        ),
      },
    },
  },

  -- ------------------------------------------------------------ 7 PROOF
  {
    id = "proof",
    station = "PROOF",
    name = L(
      "Lucky Mart, the counter",
      "럭키 마트, 계산대",
      "幸運士多，收銀處",
      "幸运士多，收银处",
      "ラッキーマート、レジ",
      "Lucky Mart, u pultu",
      "Lucky Mart, el mostrador"
    ),
    title = L(
      "128 bytes, 4 pairings, done",
      "128바이트, 페어링 4번, 끝",
      "128 bytes，4 次配對，搞掂",
      "128 bytes，4 次配对，搞定",
      "128 バイト、ペアリング 4 回、完了",
      "128 bytů, 4 párování, hotovo",
      "128 bytes, 4 emparejamientos, listo"
    ),
    lesson = L(
      "3 points, 128 bytes, 4 pairings - the same for ANY circuit. That is 'succinct'.",
      "점 3개, 128바이트, 페어링 4번 - 어떤 회로든 똑같다. 그것이 '간결(succinct)'.",
      "3 個點，128 bytes，4 次配對 - 任何電路都一樣。呢個就係「簡潔（succinct）」。",
      "3 个点，128 bytes，4 次配对 - 任何电路都一样。这就是「简洁（succinct）」。",
      "点 3 つ、128 バイト、ペアリング 4 回 - どんな回路でも同じ。これが「簡潔（succinct）」。",
      "3 body, 128 bytů, 4 párování - stejně pro JAKÝKOLI obvod. To je 'succinct'.",
      "3 puntos, 128 bytes, 4 emparejamientos: igual para CUALQUIER circuito. Eso es 'sucinto'."
    ),
    bg = "bg_store",
    portrait = "portrait_friends",
    speaker = L("Mei", "메이", "阿美", "阿美", "メイ", "Mei", "Mei"),
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
          "128 bytes，四面鏡都話得。啤酒係你嘅。答案都仲係你嘅。",
          "128 bytes，我的四面镜子都说行。啤酒是你的。答案也还是你的。",
          "128 バイト、鏡四つがイエスと言った。ビールはおごりだ。答えも君のままでいい。",
          "128 bytů a moje čtyři zrcadla říkají ano. Pivo je tvoje. A odpověď pořád taky.",
          "128 bytes y mis cuatro espejos dicen que sí. La cerveza es tuya. La respuesta también sigue "
            .. "siendo tuya."
        ),
      },
      {
        kind = "mei",
        x = 1290,
        facing = -1,
        line = L(
          "prove() on my phone, verify() on his. Real Groth16, running in Rust right now.",
          "내 폰에서 prove(), 아저씨 폰에서 verify(). 지금 러스트로 도는 진짜 Groth16.",
          "我部電話行 prove()，佢部電話行 verify()。真正嘅 Groth16，而家用 Rust 行緊。",
          "我的手机跑 prove()，他的手机跑 verify()。真正的 Groth16，现在正用 Rust 跑着。",
          "私の携帯で prove()、おじさんの携帯で verify()。今まさに Rust で動いてる本物の Groth16。",
          "prove() na mém telefonu, verify() na jeho. Opravdový Groth16, běží teď v Rustu.",
          "prove() en mi teléfono, verify() en el suyo. Groth16 de verdad, corriendo en Rust ahora mismo."
        ),
      },
    },
    viz = "proof",
    story = L(
      "Back at the counter. Mei's phone runs prove(): in go pk, the clues and her 16 cells; out "
        .. "come 128 bytes - three points A, B, C. Uncle Wing runs verify(): vk, the clues, the proof, "
        .. "four pairings, about a millisecond. Same size and same time for a 4x4 or a million-line "
        .. "circuit. Above, the real thing is running: Rust + arkworks, reached from this game over ffi.",
      "다시 계산대. 메이의 폰이 prove()를 돌린다: pk, clues, 그리고 비밀 16칸이 들어가고 128바이트 - 점 셋 A, B, C - 가 나온다. 윙 "
        .. "아저씨는 verify(): vk, clues, 증명, 페어링 네 번, 약 1밀리초. 4x4든 백만 줄 회로든 같은 크기, 같은 시간. 위 화면에서 진짜가 돌고 있다: "
        .. "러스트 + arkworks, 이 게임에서 ffi로 호출.",
      "返到收銀處。阿美部電話行 prove()：入 pk、clues 同佢嘅 16 格；出 128 bytes - 三個點 A、B、C。榮叔行 "
        .. "verify()：vk、clues、證明，四次配對，大約一毫秒。4x4 定一百萬行嘅電路，一樣大小、一樣時間。上面真嘢行緊：Rust + arkworks，由呢個遊戲經 ffi "
        .. "叫出嚟。",
      "回到收银处。阿美的手机跑 prove()：进去的是 pk、clues 和她的 16 格；出来 128 bytes - 三个点 A、B、C。荣叔跑 "
        .. "verify()：vk、clues、证明，四次配对，大约一毫秒。4x4 还是一百万行的电路，一样大小、一样时间。上面真家伙正在跑：Rust + arkworks，由这个游戏经 ffi "
        .. "调出来。",
      "またレジの前。メイの携帯が prove() を走らせる: pk、clues、彼女の 16 マスが入り、128 バイト - 点三つ A, B, C - が出てくる。ウィンおじさんは "
        .. "verify(): vk、clues、証明、ペアリング四回、およそ 1 ミリ秒。4x4 でも百万行の回路でも同じ大きさ、同じ時間。上では本物が動いている: Rust + "
        .. "arkworks、このゲームから ffi 経由で呼んでいる。",
      "Zpátky u pultu. Meiin telefon spustí prove(): dovnitř jde pk, clues a jejích 16 políček; ven "
        .. "vypadne 128 bytů - tři body A, B, C. Strýc Wing spustí verify(): vk, clues, důkaz, čtyři "
        .. "párování, asi milisekunda. Stejná velikost i stejný čas pro 4x4 i pro obvod o milionu řádků. "
        .. "Nahoře běží ta pravá věc: Rust + arkworks, volané z téhle hry přes ffi.",
      "De vuelta en el mostrador. El teléfono de Mei corre prove(): entran pk, las pistas y sus 16 "
        .. "casillas; salen 128 bytes: tres puntos A, B, C. El tío Wing corre verify(): vk, las pistas, "
        .. "la prueba, cuatro emparejamientos, como un milisegundo. Mismo tamaño y mismo tiempo para un "
        .. "4x4 o para un circuito de un millón de líneas. Arriba corre lo de verdad: Rust + arkworks, "
        .. "llamado desde este juego por ffi."
    ),
    stages = {
      {
        topic = "PROOF",
        q = L(
          "The proof is exactly ___ curve points.",
          "증명은 정확히 곡선 점 ___개.",
          "證明啱啱係 ___ 個曲線點。",
          "证明恰好是 ___ 个曲线点。",
          "証明はちょうど曲線の点 ___ 個。",
          "Důkaz je přesně ___ body na křivce.",
          "La prueba es exactamente ___ puntos de la curva."
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
]],
          [[
# rust/src/api.rs prove():   入：pk、clues、secret    出：proof
# proof = (A, B, C)  三个点；关于 16 格的东西一点都没留在里面
# （像任务 1 的 (t, s)：真正的证明是几个数字，不是秘密）
points_in_proof = ___
]],
          [[
# rust/src/api.rs prove():   入力: pk, clues, secret    出力: proof
# proof = (A, B, C)  三つの点。16 マスの情報は何一つ残らない
# (クエスト 1 の (t, s) と同じ: 本当の証明は数個の数字で、秘密ではない)
points_in_proof = ___
]],
          [[
# rust/src/api.rs prove():   dovnitř: pk, clues, secret    ven: proof
# proof = (A, B, C)  tři body; z 16 políček v nich nezůstane nic
# (jako (t, s) v úkolu 1: pravý důkaz je pár čísel, ne tajemství)
points_in_proof = ___
]],
          [[
# rust/src/api.rs prove():   entra: pk, clues, secret    sale: proof
# proof = (A, B, C)  tres puntos; nada de las 16 casillas sobrevive ahí
# (como el (t, s) de la misión 1: unos números, no el secreto)
points_in_proof = ___
]]
        ),
        accept = { "3", "three", "셋", "세 개", "3개", "三", "tři", "tres" },
        answer = "3",
        hint = L(
          "A, B and C.",
          "A, B, C.",
          "A、B 同 C。",
          "A、B 和 C。",
          "A と B と C。",
          "A, B a C.",
          "A, B y C."
        ),
        ok = L(
          "3. A and C in G1, B in G2 - the ones the pairing check eats.",
          "3. A와 C는 G1, B는 G2 - 페어링 검사가 먹는 바로 그 점들.",
          "3。A 同 C 喺 G1，B 喺 G2 - 就係配對檢查食嘅嗰啲點。",
          "3。A 和 C 在 G1，B 在 G2 - 就是配对检查吃的那些点。",
          "3。A と C は G1、B は G2 - ペアリング検査が食べるあの点たち。",
          "3. A a C v G1, B v G2 - přesně ty, které sežere kontrola párováním.",
          "3. A y C en G1, B en G2: los que se come la revisión de emparejamiento."
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Sizes: A 32 + B 64 + C 32 = ___ bytes.",
          "크기: A 32 + B 64 + C 32 = ___바이트.",
          "大小：A 32 + B 64 + C 32 = ___ bytes。",
          "大小：A 32 + B 64 + C 32 = ___ bytes。",
          "大きさ: A 32 + B 64 + C 32 = ___ バイト。",
          "Velikosti: A 32 + B 64 + C 32 = ___ bytů.",
          "Tamaños: A 32 + B 64 + C 32 = ___ bytes."
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
]],
          [[
# 压缩：一个曲线点只存一个坐标加一个正负号 bit
A_bytes = 32       # G1 点
B_bytes = 64       # G2 点（坐标是数对）
C_bytes = 32       # G1 点
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]],
          [[
# 圧縮: 曲線の点を座標一つ + 符号ビット一つで保存
A_bytes = 32       # G1 の点
B_bytes = 64       # G2 の点 (座標は数の組)
C_bytes = 32       # G1 の点
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]],
          [[
# komprimovaně: bod na křivce jako jedna souřadnice plus bit znaménka
A_bytes = 32       # bod z G1
B_bytes = 64       # bod z G2 (souřadnice jsou dvojice)
C_bytes = 32       # bod z G1
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]],
          [[
# comprimido: un punto guardado como una coordenada más un bit de signo
A_bytes = 32       # punto G1
B_bytes = 64       # punto G2 (coordenadas en pares)
C_bytes = 32       # punto G1
proof_bytes = A_bytes + B_bytes + C_bytes    # == ___
]]
        ),
        accept = { "128", "백이십팔", "一百二十八", "sto dvacet osm", "ciento veintiocho" },
        answer = "128",
        hint = L(
          "32 + 64 + 32.",
          "32 + 64 + 32.",
          "32 + 64 + 32。",
          "32 + 64 + 32。",
          "32 + 64 + 32。",
          "32 + 64 + 32.",
          "32 + 64 + 32."
        ),
        ok = L(
          "128 bytes. Quest 1's proof was several KB and grew with every bit.",
          "128바이트. 퀘스트 1의 증명은 몇 KB였고 비트마다 커졌다.",
          "128 bytes。任務 1 嘅證明有幾 KB，每多一個 bit 就大啲。",
          "128 bytes。任务 1 的证明有好几 KB，每多一个 bit 就变大。",
          "128 バイト。クエスト 1 の証明は数 KB で、ビットごとに大きくなった。",
          "128 bytů. Důkaz z úkolu 1 měl několik KB a rostl s každým bitem.",
          "128 bytes. La prueba de la misión 1 pesaba varios KB y crecía con cada bit."
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Does the proof size grow with the circuit? (yes / no)",
          "증명 크기가 회로와 함께 커지나? (yes / no)",
          "證明大小會唔會跟住電路變大？（yes / no）",
          "证明大小会跟着电路变大吗？（yes / no）",
          "証明の大きさは回路と一緒に大きくなる？（yes / no）",
          "Roste velikost důkazu s obvodem? (yes / no)",
          "¿El tamaño de la prueba crece con el circuito? (yes / no)"
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
]],
          [[
# succinct（简洁）：证明大小和验证时间都不取决于电路大小
# 112 行还是 1,000,000 行：都是 A、B、C - 都是 4 次配对
# （电路大了，只有阿美的 prove() 会变慢）
proof_grows_with_circuit = "___"      # yes / no
]],
          [[
# succinct（簡潔）: 証明の大きさも検証時間も回路の大きさに依存しない
# 112 行でも 1,000,000 行でも: A, B, C のまま - ペアリング 4 回のまま
# (回路が大きくなって遅くなるのはメイの prove() だけ)
proof_grows_with_circuit = "___"      # yes / no
]],
          [[
# succinct: velikost důkazu I čas ověření nezávisí na velikosti obvodu
# 112 řádků nebo 1 000 000 řádků: pořád A, B, C - pořád 4 párování
# (s větším obvodem se zpomalí jen Meino prove())
proof_grows_with_circuit = "___"      # yes / no
]],
          [[
# succinct: el tamaño y el tiempo no dependen del tamaño del circuito
# 112 líneas o 1,000,000: siguen A, B, C - siguen 4 emparejamientos
# (solo el prove() de Mei se hace lento con más circuito)
proof_grows_with_circuit = "___"      # yes / no
]]
        ),
        accept = {
          "no",
          "never",
          "nope",
          "false",
          "constant",
          "아니오",
          "아니요",
          "아니",
          "아니다",
          "唔會",
          "唔係",
          "不",
          "否",
          "不会",
          "不是",
          "いいえ",
          "ない",
          "ne",
          "nikdy",
          "nunca",
        },
        answer = "no",
        hint = L(
          "That is what the S in SNARK stands for.",
          "SNARK의 S가 뜻하는 바로 그것.",
          "SNARK 個 S 就係講呢樣嘢。",
          "SNARK 里的 S 说的就是这个。",
          "SNARK の S が意味しているのがそれ。",
          "Přesně to znamená S ve slově SNARK.",
          "Eso es lo que significa la S de SNARK."
        ),
        ok = L(
          "no. Succinct. The verifier's work is tiny no matter how big the secret computation was.",
          "no. 간결하다. 비밀 계산이 아무리 커도 검증자의 일은 아주 작다.",
          "no。簡潔。無論秘密計算有幾大，驗證者嘅工作都好細。",
          "no。简洁。不管秘密计算有多大，验证者的工作都很小。",
          "no。簡潔（succinct）。秘密の計算がどれだけ大きくても、検証者の仕事はごく小さい。",
          "no. Succinct, čili stručný. Práce ověřovatele je maličká, ať byl tajný výpočet jakkoli velký.",
          "no. Sucinto. El trabajo del verificador es diminuto por más grande que sea el cálculo secreto."
        ),
      },
      {
        topic = "PROOF",
        q = L(
          "Uncle Wing's verdict when e(A,B) equals the right-hand side:",
          "e(A,B)가 우변과 같을 때 윙 아저씨의 판정:",
          "當 e(A,B) 等於右邊嗰陣，榮叔嘅裁決：",
          "当 e(A,B) 等于右边时，荣叔的裁决：",
          "e(A,B) が右辺と等しいときのウィンおじさんの判定:",
          "Verdikt strýce Winga, když se e(A,B) rovná pravé straně:",
          "El veredicto del tío Wing cuando e(A,B) es igual al lado derecho:"
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
]],
          [[
# rust/src/api.rs verify():   入：vk、clues、proof     出：yes / no
# L: 用 16 个 clues 造；另一块盘的证明在这里失败
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]],
          [[
# rust/src/api.rs verify():   入力: vk, clues, proof     出力: yes / no
# L: 16 個の clues から作る。別の盤の証明はここで落ちる
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]],
          [[
# rust/src/api.rs verify():   dovnitř: vk, clues, proof     ven: yes / no
# L: postavený z 16 clues; důkaz pro jinou mřížku tu selže
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]],
          [[
# rust/src/api.rs verify():   entra: vk, clues, proof     sale: yes / no
# L: se arma con las 16 pistas; la prueba de otro tablero falla aquí
ok = e(A, B) == e(alpha, beta) * e(L, gamma) * e(C, delta)
verdict = "___" if ok else "REJECT"
]]
        ),
        accept = {
          "accept",
          "admit",
          "ok",
          "pass",
          "yes",
          "통과",
          "허가",
          "승인",
          "接受",
          "通過",
          "批准",
          "通过",
          "受理",
          "přijmout",
          "ano",
          "aceptar",
          "sí",
        },
        answer = "ACCEPT",
        hint = L(
          "The opposite of REJECT.",
          "REJECT의 반대.",
          "REJECT 嘅相反。",
          "REJECT 的相反。",
          "REJECT の反対。",
          "Opak REJECT.",
          "Lo contrario de REJECT."
        ),
        ok = L(
          "ACCEPT. He learned: the board has a solution. He did not learn: any of the 16 cells.",
          "ACCEPT. 그가 알게 된 것: 판에 답이 있다. 모르는 것: 16칸 중 그 어떤 값도.",
          "ACCEPT。佢知道咗：塊板有答案。佢唔知道：16 格入面任何一個。",
          "ACCEPT。他知道了：这个盘有解。他不知道：16 格里的任何一个。",
          "ACCEPT。分かったこと: 盤には答えがある。分からなかったこと: 16 マスのどの値も。",
          "ACCEPT. Zjistil: mřížka má řešení. Nezjistil: ani jedno z 16 políček.",
          "ACCEPT. Aprendió: el tablero tiene solución. No aprendió: ninguna de las 16 casillas."
        ),
      },
    },
  },
}

return maps
