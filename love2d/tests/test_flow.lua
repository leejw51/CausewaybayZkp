-- The title -> map -> play -> win state machine, driven through the same
-- keypressed / textinput entry points main.lua uses. No drawing.

local Store = require "src.store"
local Game = require "src.game"
local maps = require "src.data"

return function(t)
  t.describe("game flow")

  local scratch = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "") .. "/gate18-flow-test"

  local function fresh()
    os.execute(string.format('rm -rf "%s"', scratch))
    Store.use(scratch)
    local g = Game.new()
    g:ingestProgress(nil)
    g:enterTitle()
    return g
  end

  -- keypressed + the textinput LOVE sends in the same event batch
  local function press(g, key)
    g:keypressed(key)
    if #key == 1 then
      g:textinput(key)
    elseif key == "space" then
      g:textinput(" ")
    end
    g.frame = g.frame + 1
  end

  local function type_(g, s)
    for ch in s:gmatch(".") do
      g:textinput(ch)
    end
    g.frame = g.frame + 1
  end

  -- answer every stage of the current street
  local function solveStreet(g)
    local m = maps[g.step]
    for _, st in ipairs(m.stages) do
      type_(g, st.answer)
      press(g, "return")
    end
  end

  t.it("every stage has a question, a blank, an answer and a hint in every language", function()
    local I18n = require "src.i18n"
    for _, lang in ipairs(I18n.LANGS) do
      for _, m in ipairs(maps) do
        t.ok(#I18n.pick(m.lesson, lang) > 0, lang .. " " .. m.id .. " lesson")
        t.ok(#I18n.pick(m.story, lang) > 0, lang .. " " .. m.id .. " story")
        for si, st in ipairs(m.stages) do
          local where = lang .. " " .. m.id .. "/" .. si
          local code = I18n.pick(st.code, lang)
          t.ok(#I18n.pick(st.q, lang) > 0, where .. " q")
          t.ok(code:find("___", 1, true), where .. " blank")
          t.ok(st.answer and #st.answer > 0, where .. " answer")
          t.ok(#I18n.pick(st.hint, lang) > 0, where .. " hint")
          t.ok(#I18n.pick(st.ok, lang) > 0, where .. " ok")
          t.ok(Game.accepts(st.answer, st.accept), where .. " answer is accepted")
          local n = 0
          for _ in (code:gsub("\n+$", "") .. "\n"):gmatch("(.-)\n") do
            n = n + 1
          end
          t.ok(n <= 7, where .. " code fits (" .. n .. " lines)")
          -- the answer must not be given away in the code itself
          local lower = code:lower()
          for line in lower:gmatch("[^\n]+") do
            if line:find("___", 1, true) then
              local rest = line:gsub("___", "")
              t.ok(
                not rest:match("#%s*" .. Game.norm(st.answer):gsub("%p", "%%%0") .. "%s*$"),
                where .. " leaks the answer in a comment"
              )
            end
          end
        end
      end
    end
  end)

  t.it("language cycles and falls back to English", function()
    local I18n = require "src.i18n"
    I18n.set("en")
    t.eq(I18n.t("hint"), "HINT")
    I18n.cycle()
    t.eq(I18n.lang, "ko")
    t.eq(I18n.t("hint"), "힌트")
    t.eq(I18n.pick({ en = "a" }), "a", "missing translation falls back")
    I18n.cycle()
    t.eq(I18n.lang, "yue")
    I18n.cycle()
    t.eq(I18n.lang, "en")
    t.eq(I18n.pick("plain"), "plain")
  end)

  t.it("answers compare loosely", function()
    t.eq(Game.accepts("SHA-256", { "sha256" }), true)
    t.eq(Game.accepts(" hiding ", { "hiding" }), true)
    t.eq(Game.accepts('"ADMIT"', { "admit" }), true)
    t.eq(Game.accepts("-1", { "-1" }), true)
    t.eq(Game.accepts("1", { "-1" }), false)
    t.eq(Game.accepts("", { "18" }), false)
    t.eq(Game.accepts("19", { "18" }), false)
    t.eq(Game.accepts(">=", { ">=" }), true)
    t.eq(Game.accepts("> =", { ">=" }), true)
  end)

  t.it("title -> ENTER -> map -> ENTER -> play on street 1", function()
    local g = fresh()
    t.eq(g.state, "title")
    press(g, "return")
    t.eq(g.state, "map")
    t.eq(g.mapCursor, 1)
    press(g, "return")
    t.eq(g.state, "play")
    t.eq(g.step, 1)
    t.eq(g.input, "", "ENTER must not be typed into the blank")
  end)

  t.it("map cursor moves and wraps; digits jump", function()
    local g = fresh()
    press(g, "return")
    press(g, "down")
    press(g, "down")
    t.eq(g.mapCursor, 3)
    press(g, "up")
    t.eq(g.mapCursor, 2)
    press(g, "up")
    press(g, "up")
    t.eq(g.mapCursor, #maps, "wraps to the last street")
    press(g, "5")
    t.eq(g.state, "play")
    t.eq(g.step, 5)
    t.eq(g.input, "", "the digit that picked the street is not typed")
  end)

  t.it("title digits jump straight into a street", function()
    local g = fresh()
    press(g, "3")
    t.eq(g.state, "play")
    t.eq(g.step, 3)
    t.eq(g.input, "")
  end)

  t.it("hint is two-tier: nudge, then answer, then hidden", function()
    local g = fresh()
    press(g, "3")
    t.eq(g.hintLevel, 0)
    press(g, "tab")
    t.eq(g.hintLevel, 1, "first TAB: nudge")
    press(g, "tab")
    t.eq(g.hintLevel, 2, "second TAB: answer")
    press(g, "tab")
    t.eq(g.hintLevel, 0, "third TAB: hidden")
    t.eq(g.hintOn, false)
  end)

  t.it("wrong answer opens the nudge, right answers advance stages, last one clears", function()
    local g = fresh()
    press(g, "3") -- office
    local stages = maps[3].stages
    type_(g, "x")
    press(g, "return")
    t.eq(g.solved, false)
    t.eq(g.msgKind, "bad")
    t.eq(g.stage, 1)
    t.eq(g.hintLevel, 1, "a wrong attempt shows the nudge")
    t.ok(g.input ~= "", "the wrong text stays for editing")
    press(g, "backspace")
    t.eq(g.input, "")
    for i = 1, #stages - 1 do
      type_(g, stages[i].answer)
      press(g, "return")
      t.eq(g.stage, i + 1, "stage " .. i .. " -> " .. (i + 1))
      t.eq(g.solved, false)
      t.eq(g.hintLevel, 0, "hint closes on a new stage")
      t.eq(g.input, "")
    end
    type_(g, stages[#stages].answer:upper())
    press(g, "return")
    t.eq(g.solved, true)
    t.eq(g:isCleared(3), true)
    type_(g, "zzz")
    t.eq(g.input, "", "no typing after CLEAR")
    press(g, "return")
    t.eq(g.state, "play")
    t.eq(g.step, 4, "ENTER after CLEAR moves to the next street")
    t.eq(g.stage, 1)
  end)

  t.it("ESC from play opens the map, ESC again returns without resetting", function()
    local g = fresh()
    press(g, "4")
    type_(g, maps[4].stages[1].answer)
    press(g, "return")
    t.eq(g.stage, 2)
    press(g, "escape")
    t.eq(g.state, "map")
    t.eq(g.mapCursor, 4)
    press(g, "escape")
    t.eq(g.state, "play")
    t.eq(g.step, 4)
    t.eq(g.stage, 2, "progress inside the street survives the map")
    press(g, "escape")
    press(g, "return") -- pick the same street again
    t.eq(g.state, "play")
    t.eq(g.stage, 2, "re-picking the current street resumes it")
    press(g, "escape")
    press(g, "2")
    t.eq(g.step, 2)
    t.eq(g.stage, 1, "picking another street starts it fresh")
  end)

  t.it("clearing the last street alone goes to the map, not the stamp", function()
    local g = fresh()
    press(g, tostring(#maps))
    solveStreet(g)
    t.eq(g.solved, true)
    press(g, "return")
    t.eq(g.state, "map", "other streets still open")
    t.eq(g:isCleared(#maps), true)
  end)

  t.it("win only when all streets are clear; ENTER -> map, ESC -> title", function()
    local g = fresh()
    press(g, "1")
    for i = 1, #maps do
      t.eq(g.state, "play")
      t.eq(g.step, i)
      solveStreet(g)
      t.eq(g.solved, true, "street " .. i .. " clear")
      press(g, "return")
    end
    t.eq(g.state, "win")
    press(g, "return")
    t.eq(g.state, "map")
    press(g, "escape")
    t.eq(g.state, "title")
  end)

  t.it("progress persists: C on the title continues", function()
    local g = fresh()
    press(g, "2")
    type_(g, maps[2].stages[1].answer)
    press(g, "return")
    t.eq(g.stage, 2)
    -- new process
    local g2 = Game.new()
    g2:ingestProgress(require("src.persist").loadProgress())
    g2:enterTitle()
    t.ok(g2.saved, "saved record")
    t.eq(g2.saved.step, 2)
    t.eq(g2.saved.stage, 2)
    press(g2, "c")
    t.eq(g2.state, "play")
    t.eq(g2.step, 2)
    t.eq(g2.stage, 2)
    t.eq(g2.input, "", "the C key is not typed")
  end)

  t.it("continue after a CLEAR goes to the next street; map cursor follows", function()
    local g = fresh()
    press(g, "1")
    solveStreet(g)
    t.eq(g.solved, true)
    local g2 = Game.new()
    g2:ingestProgress(require("src.persist").loadProgress())
    g2:enterTitle()
    t.eq(g2:isCleared(1), true)
    t.eq(g2:continueTarget(), 2)
    press(g2, "return")
    t.eq(g2.state, "map")
    t.eq(g2.mapCursor, 2, "cursor sits on the next street to do")
    press(g2, "escape")
    press(g2, "c")
    t.eq(g2.state, "play")
    t.eq(g2.step, 2)
  end)
end
