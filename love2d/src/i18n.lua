-- English / Korean / Cantonese (Hong Kong written Chinese) for the UI.
--
--   I18n.t("key", ...)    a UI string in the current language (string.format)
--   I18n.pick(v)          v is a { en=, ko=, yue= } table (from data.lua) or a
--                         plain string; returns the current language, else en
--   I18n.cycle()          next language; the choice is saved with the display
--
-- The code blocks in data.lua keep their python; only comments are translated.

local I18n = { lang = "en" }

I18n.LANGS = { "en", "ko", "yue" }
I18n.NAMES = { en = "EN", ko = "한국어", yue = "粵語" }

local S = {
  subtitle = { en = "Causeway Bay", ko = "코즈웨이베이", yue = "銅鑼灣" },
  tagline = {
    en = "Prove you are an adult. Keep your birthday.",
    ko = "성인임을 증명하세요. 생년월일은 지키세요.",
    yue = "證明你係成年人，生日日期留返俾自己。",
  },
  title_enter = { en = "ENTER  pick a street", ko = "ENTER  거리 고르기", yue = "ENTER  揀條街" },
  title_continue = {
    en = "C  continue at %s   (%d/%d streets clear)",
    ko = "C  %s에서 이어하기   (%d/%d 거리 클리어)",
    yue = "C  喺 %s 繼續   (%d/%d 條街完成)",
  },
  title_fresh = {
    en = "7 streets. One ZKP. Type the answers.",
    ko = "7개의 거리, 하나의 ZKP. 답을 입력하세요.",
    yue = "7條街，一個ZKP。打答案。",
  },
  title_help = {
    en = "1-7 jump straight in.   Q quest.   F3 language.   F4 sound.   ESC quit.",
    ko = "1-7 바로 이동.   Q 퀘스트.   F3 언어.   F4 소리.   ESC 종료.",
    yue = "1-7 直接跳去。  Q 任務。  F3 語言。  F4 聲音。  ESC 離開。",
  },
  clear = { en = "CLEAR", ko = "클리어", yue = "完成" },
  here = { en = "HERE", ko = "여기", yue = "而家喺度" },
  map_help = {
    en = "ARROWS walk    ENTER go    1-7 jump    Q quest    %s",
    ko = "방향키 이동    ENTER 입장    1-7 점프    Q 퀘스트    %s",
    yue = "方向鍵行    ENTER 入去    1-7 跳    Q 任務    %s",
  },
  clear_count = { en = "%d / %d clear", ko = "%d / %d 클리어", yue = "%d / %d 完成" },
  esc_back = { en = "ESC back", ko = "ESC 돌아가기", yue = "ESC 返去" },
  esc_title = { en = "ESC title", ko = "ESC 타이틀", yue = "ESC 標題" },
  map_label = { en = "%s  MAP %d/%d  %s", ko = "%s  맵 %d/%d  %s", yue = "%s  地圖 %d/%d  %s" },
  clear_stamp = {
    en = "CLEAR   ENTER for the stamp",
    ko = "클리어   ENTER 도장 받기",
    yue = "完成   ENTER 攞印",
  },
  clear_map = {
    en = "CLEAR   ENTER back to the map",
    ko = "클리어   ENTER 맵으로",
    yue = "完成   ENTER 返地圖",
  },
  clear_next = {
    en = "CLEAR   ENTER next street",
    ko = "클리어   ENTER 다음 거리",
    yue = "完成   ENTER 下一條街",
  },
  q_prefix = { en = "Q: ", ko = "Q: ", yue = "Q: " },
  hint = { en = "HINT", ko = "힌트", yue = "提示" },
  answer = { en = "ANSWER", ko = "정답", yue = "答案" },
  hide = { en = "HIDE", ko = "닫기", yue = "收埋" },
  ok = { en = "OK", ko = "확인", yue = "確定" },
  auto = { en = "AUTO", ko = "자동", yue = "自動" },
  auto_on = { en = "STOP", ko = "멈춤", yue = "停" },
  next = { en = "NEXT", ko = "다음", yue = "下一個" },
  step_prev = { en = "< PREV", ko = "< 이전", yue = "< 上一個" },
  step_next = { en = "NEXT >", ko = "다음 >", yue = "下一個 >" },
  type_answer = { en = "type the answer", ko = "답을 입력하세요", yue = "打答案" },
  clear_prompt = { en = "CLEAR   ENTER  next", ko = "클리어   ENTER  다음", yue = "完成   ENTER  下一個" },
  help_play = { en = "TAB hint   F5 auto   ESC map", ko = "TAB 힌트   F5 자동   ESC 맵", yue = "TAB 提示   F5 自動   ESC 地圖" },
  help_walk = { en = "arrows walk   ESC map", ko = "방향키 걷기   ESC 맵", yue = "方向鍵行   ESC 地圖" },
  help_answer = {
    en = "TAB again: answer   ESC map",
    ko = "TAB 한 번 더: 정답   ESC 맵",
    yue = "再撳TAB：答案   ESC 地圖",
  },
  msg_empty = {
    en = "Type the answer, then ENTER.",
    ko = "답을 입력하고 ENTER.",
    yue = "打答案，然後撳ENTER。",
  },
  msg_wrong = {
    en = "Not quite. Read the hint and try again. HINT again shows the answer.",
    ko = "아쉽네요. 힌트를 읽고 다시 해보세요. 힌트를 한 번 더 누르면 정답이 보입니다.",
    yue = "唔啱。睇下提示再試。再撳提示會顯示答案。",
  },
  win_title = {
    en = "Lucky Mart  ·  Causeway Bay",
    ko = "럭키 마트  ·  코즈웨이베이",
    yue = "幸運士多  ·  銅鑼灣",
  },
  win_head = {
    en = "WHAT UNCLE WING LEARNED: age >= 18.   NOT: 25, r, sk, the bits.",
    ko = "윙 아저씨가 알게 된 것: age >= 18.   모르는 것: 25, r, sk, 비트.",
    yue = "榮叔知道咗：age >= 18。   唔知道：25、r、sk、啲bit。",
  },
  win_help = {
    en = "ENTER  street map      ESC  title",
    ko = "ENTER  거리 맵      ESC  타이틀",
    yue = "ENTER  街道地圖      ESC  標題",
  },
  -- quests
  quest_tab = { en = "QUEST %d", ko = "퀘스트 %d", yue = "任務 %d" },
  quest_help = { en = "Q other quest", ko = "Q 다른 퀘스트", yue = "Q 另一個任務" },
  quest_locked_hint = {
    en = "Two quests, two kinds of ZKP. Q switches.",
    ko = "퀘스트 둘, ZKP 두 종류. Q로 전환.",
    yue = "兩個任務，兩種 ZKP。撳 Q 轉。",
  },
  win2_title = {
    en = "Lucky Mart  ·  the puzzle prize",
    ko = "럭키 마트  ·  퍼즐 상품",
    yue = "幸運士多  ·  謎題獎品",
  },
  win2_head = {
    en = "WHAT UNCLE WING LEARNED: the board has a solution.   NOT: any of the 16 cells.",
    ko = "윙 아저씨가 알게 된 것: 판에 답이 있다.   모르는 것: 16칸 중 어느 하나도.",
    yue = "榮叔知道咗：塊板有答案。   唔知道：16 格入面任何一格。",
  },
  clear_prize = {
    en = "CLEAR   ENTER for the prize",
    ko = "클리어   ENTER 상품 받기",
    yue = "完成   ENTER 攞獎",
  },
  -- live SNARK panel (PROOF street)
  snark_title = { en = "LIVE  Groth16 / BN254 (Rust)", ko = "실시간  Groth16 / BN254 (러스트)", yue = "即場  Groth16 / BN254 (Rust)" },
  snark_missing = {
    en = "Rust library not built.  cd rust && cargo build --release",
    ko = "러스트 라이브러리가 없습니다.  cd rust && cargo build --release",
    yue = "未 build Rust library。  cd rust && cargo build --release",
  },
  snark_lines = { en = "%d lines   %d public   %d secret", ko = "%d줄   공개 %d   비밀 %d", yue = "%d 行   公開 %d   秘密 %d" },
  snark_keys = { en = "pk %d B   vk %d B   setup %.1f ms", ko = "pk %dB   vk %dB   setup %.1fms", yue = "pk %d B   vk %d B   setup %.1f ms" },
  snark_proof = { en = "proof %d B   prove %.1f ms   verify %.1f ms (%d pairings)", ko = "증명 %dB   prove %.1fms   verify %.1fms (페어링 %d)", yue = "證明 %d B   prove %.1f ms   verify %.1f ms (%d 次配對)" },
  snark_tamper = { en = "other clues -> %s", ko = "다른 clues -> %s", yue = "另一組 clues -> %s" },
  hud_map = { en = "MAP", ko = "맵", yue = "地圖" },
  hud_back = { en = "BACK", ko = "뒤로", yue = "返去" },
  hud_full = { en = "FULL", ko = "전체", yue = "全屏" },
  hud_wind = { en = "WIND", ko = "창", yue = "視窗" },
  hud_port = { en = "PORT", ko = "세로", yue = "直向" },
  hud_land = { en = "LAND", ko = "가로", yue = "橫向" },
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
