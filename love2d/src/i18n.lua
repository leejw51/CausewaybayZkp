-- The seven UI languages.
--
--   en   English                    ko  Korean
--   yue  Cantonese (Hong Kong written Chinese, Traditional)
--   zh   Simplified Chinese (Mandarin)
--   ja   Japanese      cs  Czech      es  Spanish
--
--   I18n.t("key", ...)    a UI string in the current language (string.format)
--   I18n.pick(v)          v is a table keyed by language code (from data.lua)
--                         or a plain string; falls back to en
--   I18n.cycle()          next language; the choice is saved with the display
--
-- The code blocks in data.lua keep their python; only comments are translated.
-- Czech and Spanish render straight from the pixel fonts, which carry the
-- accented Latin; CJK falls back to Noto Sans CJK (assets.lua, and
-- tools/subset_cjk.py for what that subset has to cover).

local I18n = { lang = "en" }

I18n.LANGS = { "en", "ko", "yue", "zh", "ja", "cs", "es" }
I18n.NAMES = {
  en = "EN",
  ko = "한국어",
  yue = "粵語",
  zh = "简体",
  ja = "日本語",
  cs = "ČESKY",
  es = "ESPAÑOL",
}

local S = {
  subtitle = {
    en = "Causeway Bay",
    ko = "코즈웨이베이",
    yue = "銅鑼灣",
    zh = "铜锣湾",
    ja = "コーズウェイベイ",
    cs = "Causeway Bay",
    es = "Causeway Bay",
  },
  tagline = {
    en = "Prove you are an adult. Keep your birthday.",
    ko = "성인임을 증명하세요. 생년월일은 지키세요.",
    yue = "證明你係成年人，生日日期留返俾自己。",
    zh = "证明你是成年人。生日留给自己。",
    ja = "成人であることを証明せよ。誕生日は渡すな。",
    cs = "Dokaž, že jsi dospělý. Datum narození si nech.",
    es = "Demuestra que eres adulto. Guarda tu fecha de nacimiento.",
  },
  title_enter = {
    en = "ENTER  pick a street",
    ko = "ENTER  거리 고르기",
    yue = "ENTER  揀條街",
    zh = "ENTER  选一条街",
    ja = "ENTER  通りを選ぶ",
    cs = "ENTER  vyber ulici",
    es = "ENTER  elige una calle",
  },
  title_continue = {
    en = "C  continue at %s   (%d/%d streets clear)",
    ko = "C  %s에서 이어하기   (%d/%d 거리 클리어)",
    yue = "C  喺 %s 繼續   (%d/%d 條街完成)",
    zh = "C  从 %s 继续   (%d/%d 条街完成)",
    ja = "C  %s から再開   (%d/%d 通りクリア)",
    cs = "C  pokračuj na %s   (%d/%d ulic hotovo)",
    es = "C  continuar en %s   (%d/%d calles listas)",
  },
  title_fresh = {
    en = "7 streets. One ZKP. Type the answers.",
    ko = "7개의 거리, 하나의 ZKP. 답을 입력하세요.",
    yue = "7條街，一個ZKP。打答案。",
    zh = "7 条街，一个 ZKP。输入答案。",
    ja = "7つの通り、1つのZKP。答えを入力せよ。",
    cs = "7 ulic. Jeden ZKP. Piš odpovědi.",
    es = "7 calles. Un ZKP. Escribe las respuestas.",
  },
  title_help = {
    en = "1-7 jump straight in.   Q quest.   F3 language.   F4 sound.   ESC quit.",
    ko = "1-7 바로 이동.   Q 퀘스트.   F3 언어.   F4 소리.   ESC 종료.",
    yue = "1-7 直接跳去。  Q 任務。  F3 語言。  F4 聲音。  ESC 離開。",
    zh = "1-7 直接跳入。   Q 任务。   F3 语言。   F4 声音。   ESC 退出。",
    ja = "1-7 直接ジャンプ。   Q クエスト。   F3 言語。   F4 音。   ESC 終了。",
    cs = "1-7 skoč rovnou.   Q úkol.   F3 jazyk.   F4 zvuk.   ESC konec.",
    es = "1-7 salta directo.   Q misión.   F3 idioma.   F4 sonido.   ESC salir.",
  },
  clear = {
    en = "CLEAR",
    ko = "클리어",
    yue = "完成",
    zh = "完成",
    ja = "クリア",
    cs = "HOTOVO",
    es = "LISTO",
  },
  here = {
    en = "HERE",
    ko = "여기",
    yue = "而家喺度",
    zh = "当前",
    ja = "現在地",
    cs = "TADY",
    es = "AQUÍ",
  },
  map_help = {
    en = "ARROWS walk    ENTER go    1-7 jump    Q quest    %s",
    ko = "방향키 이동    ENTER 입장    1-7 점프    Q 퀘스트    %s",
    yue = "方向鍵行    ENTER 入去    1-7 跳    Q 任務    %s",
    zh = "方向键 行走    ENTER 进入    1-7 跳转    Q 任务    %s",
    ja = "方向キー 移動    ENTER 入る    1-7 ジャンプ    Q クエスト    %s",
    cs = "ŠIPKY chůze    ENTER vstup    1-7 skok    Q úkol    %s",
    es = "FLECHAS caminar    ENTER entrar    1-7 saltar    Q misión    %s",
  },
  clear_count = {
    en = "%d / %d clear",
    ko = "%d / %d 클리어",
    yue = "%d / %d 完成",
    zh = "%d / %d 完成",
    ja = "%d / %d クリア",
    cs = "%d / %d hotovo",
    es = "%d / %d listas",
  },
  esc_back = {
    en = "ESC back",
    ko = "ESC 돌아가기",
    yue = "ESC 返去",
    zh = "ESC 返回",
    ja = "ESC 戻る",
    cs = "ESC zpět",
    es = "ESC volver",
  },
  esc_title = {
    en = "ESC title",
    ko = "ESC 타이틀",
    yue = "ESC 標題",
    zh = "ESC 标题",
    ja = "ESC タイトル",
    cs = "ESC úvod",
    es = "ESC inicio",
  },
  map_label = {
    en = "%s  MAP %d/%d  %s",
    ko = "%s  맵 %d/%d  %s",
    yue = "%s  地圖 %d/%d  %s",
    zh = "%s  地图 %d/%d  %s",
    ja = "%s  マップ %d/%d  %s",
    cs = "%s  MAPA %d/%d  %s",
    es = "%s  MAPA %d/%d  %s",
  },
  clear_stamp = {
    en = "CLEAR   ENTER for the stamp",
    ko = "클리어   ENTER 도장 받기",
    yue = "完成   ENTER 攞印",
    zh = "完成   ENTER 领取印章",
    ja = "クリア   ENTER スタンプをもらう",
    cs = "HOTOVO   ENTER pro razítko",
    es = "LISTO   ENTER por el sello",
  },
  clear_map = {
    en = "CLEAR   ENTER back to the map",
    ko = "클리어   ENTER 맵으로",
    yue = "完成   ENTER 返地圖",
    zh = "完成   ENTER 返回地图",
    ja = "クリア   ENTER マップへ戻る",
    cs = "HOTOVO   ENTER zpět na mapu",
    es = "LISTO   ENTER volver al mapa",
  },
  clear_next = {
    en = "CLEAR   ENTER next street",
    ko = "클리어   ENTER 다음 거리",
    yue = "完成   ENTER 下一條街",
    zh = "完成   ENTER 下一条街",
    ja = "クリア   ENTER 次の通り",
    cs = "HOTOVO   ENTER další ulice",
    es = "LISTO   ENTER siguiente calle",
  },
  q_prefix = {
    en = "Q: ",
    ko = "Q: ",
    yue = "Q: ",
    zh = "Q: ",
    ja = "Q: ",
    cs = "Q: ",
    es = "Q: ",
  },
  hint = {
    en = "HINT",
    ko = "힌트",
    yue = "提示",
    zh = "提示",
    ja = "ヒント",
    cs = "RADA",
    es = "PISTA",
  },
  answer = {
    en = "ANSWER",
    ko = "정답",
    yue = "答案",
    zh = "答案",
    ja = "答え",
    cs = "ŘEŠENÍ",
    es = "SOLUCIÓN",
  },
  hide = {
    en = "HIDE",
    ko = "닫기",
    yue = "收埋",
    zh = "隐藏",
    ja = "隠す",
    cs = "SKRÝT",
    es = "OCULTAR",
  },
  ok = {
    en = "OK",
    ko = "확인",
    yue = "確定",
    zh = "确定",
    ja = "OK",
    cs = "OK",
    es = "OK",
  },
  auto = {
    en = "AUTO",
    ko = "자동",
    yue = "自動",
    zh = "自动",
    ja = "オート",
    cs = "AUTO",
    es = "AUTO",
  },
  auto_on = {
    en = "STOP",
    ko = "멈춤",
    yue = "停",
    zh = "停止",
    ja = "停止",
    cs = "STOP",
    es = "PARAR",
  },
  next = {
    en = "NEXT",
    ko = "다음",
    yue = "下一個",
    zh = "下一个",
    ja = "次へ",
    cs = "DALŠÍ",
    es = "SIGUE",
  },
  step_prev = {
    en = "< PREV",
    ko = "< 이전",
    yue = "< 上一個",
    zh = "< 上一个",
    ja = "< 前へ",
    cs = "< ZPĚT",
    es = "< ANTES",
  },
  step_next = {
    en = "NEXT >",
    ko = "다음 >",
    yue = "下一個 >",
    zh = "下一个 >",
    ja = "次へ >",
    cs = "DALŠÍ >",
    es = "SIGUE >",
  },
  type_answer = {
    en = "type the answer",
    ko = "답을 입력하세요",
    yue = "打答案",
    zh = "输入答案",
    ja = "答えを入力",
    cs = "napiš odpověď",
    es = "escribe la respuesta",
  },
  clear_prompt = {
    en = "CLEAR   ENTER  next",
    ko = "클리어   ENTER  다음",
    yue = "完成   ENTER  下一個",
    zh = "完成   ENTER  下一个",
    ja = "クリア   ENTER  次へ",
    cs = "HOTOVO   ENTER  další",
    es = "LISTO   ENTER  siguiente",
  },
  help_play = {
    en = "TAB hint   F5 auto   ESC map",
    ko = "TAB 힌트   F5 자동   ESC 맵",
    yue = "TAB 提示   F5 自動   ESC 地圖",
    zh = "TAB 提示   F5 自动   ESC 地图",
    ja = "TAB ヒント   F5 オート   ESC マップ",
    cs = "TAB rada   F5 auto   ESC mapa",
    es = "TAB pista   F5 auto   ESC mapa",
  },
  help_walk = {
    en = "arrows walk   ESC map",
    ko = "방향키 걷기   ESC 맵",
    yue = "方向鍵行   ESC 地圖",
    zh = "方向键 行走   ESC 地图",
    ja = "方向キー 移動   ESC マップ",
    cs = "šipky chůze   ESC mapa",
    es = "flechas caminar   ESC mapa",
  },
  help_answer = {
    en = "TAB again: answer   ESC map",
    ko = "TAB 한 번 더: 정답   ESC 맵",
    yue = "再撳TAB：答案   ESC 地圖",
    zh = "再按 TAB：答案   ESC 地图",
    ja = "もう一度 TAB: 答え   ESC マップ",
    cs = "TAB znovu: řešení   ESC mapa",
    es = "TAB otra vez: solución   ESC mapa",
  },
  msg_empty = {
    en = "Type the answer, then ENTER.",
    ko = "답을 입력하고 ENTER.",
    yue = "打答案，然後撳ENTER。",
    zh = "输入答案，然后按 ENTER。",
    ja = "答えを入力して ENTER。",
    cs = "Napiš odpověď a stiskni ENTER.",
    es = "Escribe la respuesta y pulsa ENTER.",
  },
  msg_wrong = {
    en = "Not quite. Read the hint and try again. HINT again shows the answer.",
    ko = "아쉽네요. 힌트를 읽고 다시 해보세요. 힌트를 한 번 더 누르면 정답이 보입니다.",
    yue = "唔啱。睇下提示再試。再撳提示會顯示答案。",
    zh = "差一点。读一下提示再试。再按提示会显示答案。",
    ja = "惜しい。ヒントを読んでもう一度。ヒントをもう一度押すと答えが出る。",
    cs = "Skoro. Přečti si radu a zkus to znovu. Další RADA ukáže řešení.",
    es = "Casi. Lee la pista e inténtalo de nuevo. PISTA otra vez muestra la solución.",
  },
  win_title = {
    en = "Lucky Mart  ·  Causeway Bay",
    ko = "럭키 마트  ·  코즈웨이베이",
    yue = "幸運士多  ·  銅鑼灣",
    zh = "幸运士多  ·  铜锣湾",
    ja = "ラッキーマート  ·  コーズウェイベイ",
    cs = "Lucky Mart  ·  Causeway Bay",
    es = "Lucky Mart  ·  Causeway Bay",
  },
  win_head = {
    en = "WHAT UNCLE WING LEARNED: age >= 18.   NOT: 25, r, sk, the bits.",
    ko = "윙 아저씨가 알게 된 것: age >= 18.   모르는 것: 25, r, sk, 비트.",
    yue = "榮叔知道咗：age >= 18。   唔知道：25、r、sk、啲bit。",
    zh = "荣叔知道的: age >= 18。   不知道的: 25、r、sk、那些比特。",
    ja = "ウィンおじさんが知ったこと: age >= 18。   知らないこと: 25、r、sk、ビット。",
    cs = "CO SE STRÝC WING DOZVĚDĚL: age >= 18.   NE: 25, r, sk, ty bity.",
    es = "LO QUE APRENDIÓ EL TÍO WING: age >= 18.   NO: 25, r, sk, los bits.",
  },
  win_help = {
    en = "ENTER  street map      ESC  title",
    ko = "ENTER  거리 맵      ESC  타이틀",
    yue = "ENTER  街道地圖      ESC  標題",
    zh = "ENTER  街道地图      ESC  标题",
    ja = "ENTER  街のマップ      ESC  タイトル",
    cs = "ENTER  mapa ulic      ESC  úvod",
    es = "ENTER  mapa de calles      ESC  inicio",
  },
  -- quests
  quest_tab = {
    en = "QUEST %d",
    ko = "퀘스트 %d",
    yue = "任務 %d",
    zh = "任务 %d",
    ja = "クエスト %d",
    cs = "ÚKOL %d",
    es = "MISIÓN %d",
  },
  quest_help = {
    en = "Q other quest",
    ko = "Q 다른 퀘스트",
    yue = "Q 另一個任務",
    zh = "Q 另一个任务",
    ja = "Q 別のクエスト",
    cs = "Q jiný úkol",
    es = "Q otra misión",
  },
  quest_locked_hint = {
    en = "Two quests, two kinds of ZKP. Q switches.",
    ko = "퀘스트 둘, ZKP 두 종류. Q로 전환.",
    yue = "兩個任務，兩種 ZKP。撳 Q 轉。",
    zh = "两个任务，两种 ZKP。按 Q 切换。",
    ja = "クエスト2つ、ZKP2種類。Q で切り替え。",
    cs = "Dva úkoly, dva druhy ZKP. Q přepíná.",
    es = "Dos misiones, dos tipos de ZKP. Q cambia.",
  },
  win2_title = {
    en = "Lucky Mart  ·  the puzzle prize",
    ko = "럭키 마트  ·  퍼즐 상품",
    yue = "幸運士多  ·  謎題獎品",
    zh = "幸运士多  ·  谜题奖品",
    ja = "ラッキーマート  ·  パズルの賞品",
    cs = "Lucky Mart  ·  cena za hlavolam",
    es = "Lucky Mart  ·  el premio del rompecabezas",
  },
  win2_head = {
    en = "WHAT UNCLE WING LEARNED: the board has a solution.   NOT: any of the 16 cells.",
    ko = "윙 아저씨가 알게 된 것: 판에 답이 있다.   모르는 것: 16칸 중 어느 하나도.",
    yue = "榮叔知道咗：塊板有答案。   唔知道：16 格入面任何一格。",
    zh = "荣叔知道的: 盘面有解。   不知道的: 16 格中的任何一格。",
    ja = "ウィンおじさんが知ったこと: 盤に解がある。   知らないこと: 16マスのどれも。",
    cs = "CO SE STRÝC WING DOZVĚDĚL: mřížka má řešení.   NE: ani jedno z 16 políček.",
    es = "LO QUE APRENDIÓ EL TÍO WING: el tablero tiene solución.   NO: ninguna de las 16 casillas.",
  },
  clear_prize = {
    en = "CLEAR   ENTER for the prize",
    ko = "클리어   ENTER 상품 받기",
    yue = "完成   ENTER 攞獎",
    zh = "完成   ENTER 领取奖品",
    ja = "クリア   ENTER 賞品をもらう",
    cs = "HOTOVO   ENTER pro cenu",
    es = "LISTO   ENTER por el premio",
  },
  -- live SNARK panel (PROOF street)
  snark_title = {
    en = "LIVE  Groth16 / BN254 (Rust)",
    ko = "실시간  Groth16 / BN254 (러스트)",
    yue = "即場  Groth16 / BN254 (Rust)",
    zh = "实时  Groth16 / BN254 (Rust)",
    ja = "ライブ  Groth16 / BN254 (Rust)",
    cs = "ŽIVĚ  Groth16 / BN254 (Rust)",
    es = "EN VIVO  Groth16 / BN254 (Rust)",
  },
  snark_missing = {
    en = "Rust library not built.  cd rust && cargo build --release",
    ko = "러스트 라이브러리가 없습니다.  cd rust && cargo build --release",
    yue = "未 build Rust library。  cd rust && cargo build --release",
    zh = "Rust 库未构建。  cd rust && cargo build --release",
    ja = "Rust ライブラリが未ビルド。  cd rust && cargo build --release",
    cs = "Knihovna v Rustu není sestavená.  cd rust && cargo build --release",
    es = "La biblioteca de Rust no está compilada.  cd rust && cargo build --release",
  },
  snark_lines = {
    en = "%d lines   %d public   %d secret",
    ko = "%d줄   공개 %d   비밀 %d",
    yue = "%d 行   公開 %d   秘密 %d",
    zh = "%d 行   公开 %d   秘密 %d",
    ja = "%d 行   公開 %d   秘密 %d",
    cs = "%d řádků   %d veřejných   %d tajných",
    es = "%d líneas   %d públicas   %d secretas",
  },
  snark_keys = {
    en = "pk %d B   vk %d B   setup %.1f ms",
    ko = "pk %dB   vk %dB   setup %.1fms",
    yue = "pk %d B   vk %d B   setup %.1f ms",
    zh = "pk %d B   vk %d B   setup %.1f ms",
    ja = "pk %d B   vk %d B   setup %.1f ms",
    cs = "pk %d B   vk %d B   setup %.1f ms",
    es = "pk %d B   vk %d B   setup %.1f ms",
  },
  snark_proof = {
    en = "proof %d B   prove %.1f ms   verify %.1f ms (%d pairings)",
    ko = "증명 %dB   prove %.1fms   verify %.1fms (페어링 %d)",
    yue = "證明 %d B   prove %.1f ms   verify %.1f ms (%d 次配對)",
    zh = "证明 %d B   prove %.1f ms   verify %.1f ms (%d 次配对)",
    ja = "証明 %d B   prove %.1f ms   verify %.1f ms (ペアリング %d 回)",
    cs = "důkaz %d B   prove %.1f ms   verify %.1f ms (%d párování)",
    es = "prueba %d B   prove %.1f ms   verify %.1f ms (%d emparejamientos)",
  },
  snark_tamper = {
    en = "other clues -> %s",
    ko = "다른 clues -> %s",
    yue = "另一組 clues -> %s",
    zh = "另一组 clues -> %s",
    ja = "別の clues -> %s",
    cs = "jiné clues -> %s",
    es = "otras clues -> %s",
  },
  hud_map = {
    en = "MAP",
    ko = "맵",
    yue = "地圖",
    zh = "地图",
    ja = "マップ",
    cs = "MAPA",
    es = "MAPA",
  },
  hud_back = {
    en = "BACK",
    ko = "뒤로",
    yue = "返去",
    zh = "返回",
    ja = "もどる",
    cs = "ZPĚT",
    es = "ATRÁS",
  },
  hud_full = {
    en = "FULL",
    ko = "전체",
    yue = "全屏",
    zh = "全屏",
    ja = "全画面",
    cs = "CELÁ",
    es = "LLENA",
  },
  hud_wind = {
    en = "WIND",
    ko = "창",
    yue = "視窗",
    zh = "窗口",
    ja = "窓",
    cs = "OKNO",
    es = "VENTANA",
  },
  hud_port = {
    en = "PORT",
    ko = "세로",
    yue = "直向",
    zh = "竖屏",
    ja = "縦",
    cs = "VÝŠKA",
    es = "VERT",
  },
  hud_land = {
    en = "LAND",
    ko = "가로",
    yue = "橫向",
    zh = "横屏",
    ja = "横",
    cs = "ŠÍŘKA",
    es = "HORIZ",
  },
}

function I18n.set(lang)
  if I18n.NAMES[lang] then
    I18n.lang = lang
  end
  return I18n.lang
end

function I18n.cycle()
  for i, l in ipairs(I18n.LANGS) do
    if l == I18n.lang then
      return I18n.set(I18n.LANGS[i % #I18n.LANGS + 1])
    end
  end
  return I18n.set("en")
end

function I18n.pick(v, lang)
  if type(v) == "table" then
    return v[lang or I18n.lang] or v.en or ""
  end
  return v == nil and "" or tostring(v)
end

function I18n.t(key, ...)
  local v = S[key]
  local s = v and (v[I18n.lang] or v.en) or key
  if select("#", ...) > 0 then
    return string.format(s, ...)
  end
  return s
end

return I18n
