-- GATE 18 game flow:
--
--   title  ->  map  ->  play  ->  (next map ...)  ->  win
--            ^  ^        |
--            |  +--------+   ESC / F2 / MAP button
--            +-- ESC from map returns to where it came from
--
-- Play is a quiz. One blank ___ per stage, the player types the answer.
-- HINT is two-tier: first press a nudge, second press the answer. A wrong
-- attempt opens the nudge; 30 s idle opens it too. Win needs all 7 CLEAR.

local ease = require "src.ease"
local E = ease
local assets = require "src.assets"
local sprites = require "src.sprites"
local maps = require "src.data"
local Layout = require "src.layout"
local Persist = require "src.persist"
local Theme = require "src.theme"
local World = require "src.world"
local UI = require "src.ui"
local I18n = require "src.i18n"
local SFX = require "src.sfx"
local P = I18n.pick
local T = I18n.t

local COL = {
  ink = Theme.ink,
  navy = Theme.navy,
  midnight = Theme.void,
  manila = Theme.panel,
  cream = Theme.cream,
  gold = Theme.coin,
  neon = Theme.pink,
  cyan = Theme.cyan,
  admit = Theme.admit,
  stamp = Theme.red,
  paper = { 0.12, 0.10, 0.28, 0.94 },
}

local W, H = Theme.landW, Theme.landH
local TOP, SCENE_H, TERM_Y = 18, 180, 198
local PORT = false
local HUD = {
  full = { 0, 6, 108, 34 },
  ori = { 0, 6, 108, 34 },
  map = { 0, 6, 108, 34 },
  lang = { 0, 6, 108, 34 },
}
local HINT_WAIT = 30
local MAX_INPUT = 24

local function setC(c, a)
  love.graphics.setColor(c[1], c[2], c[3], a or c[4] or 1)
end

local function roundrect(mode, x, y, w, h, r)
  love.graphics.rectangle(mode, x, y, w, h, r or 8, r or 8)
end

local function unclip(sx, sy, sw, sh)
  if sx then
    love.graphics.setScissor(sx, sy, sw, sh)
  else
    love.graphics.setScissor()
  end
end

local function clip(x, y, w, h)
  local sx, sy, sw, sh = love.graphics.getScissor()
  if love.graphics.intersectScissor then
    love.graphics.intersectScissor(x, y, math.max(1, w), math.max(1, h))
  else
    love.graphics.setScissor(x, y, math.max(1, w), math.max(1, h))
  end
  return sx, sy, sw, sh
end

local function fontOf(name)
  return assets.font[name] or assets.font.ui
end

local function inRect(x, y, r)
  return r and x >= r[1] and y >= r[2] and x < r[1] + r[3] and y < r[2] + r[4]
end

-- Answers compare loosely: case, spaces, quotes, underscores, dashes and
-- dots are ignored, so "SHA-256", "sha256" and "sha_256" all match.
local function norm(s)
  s = tostring(s or ""):lower()
  s = s:gsub("[\"'`]", "")
  s = s:gsub("%s+", "")
  s = s:gsub("[_%.]", "")
  -- a leading minus is meaning ("-1"); any other dash is punctuation ("sha-256")
  local neg = s:sub(1, 1) == "-"
  s = s:gsub("%-", "")
  if neg then
    s = "-" .. s
  end
  return s
end

-- Every ___ in the stage code shows the same thing: the blank, what is
-- being typed, or the answer once CLEAR.
local function fillBlank(code, shown)
  local out = tostring(code or ""):gsub("___", (tostring(shown):gsub("%%", "%%%%")))
  return out
end

local function accepts(answer, list)
  local a = norm(answer)
  if a == "" then
    return false
  end
  for i = 1, #list do
    if a == norm(list[i]) then
      return true
    end
  end
  return false
end

local function neonPrint(font, text, x, y, col, t, align)
  love.graphics.setFont(font)
  local pulse = 0.7 + 0.3 * (0.5 + 0.5 * math.cos((t or 0) * 2.2))
  local function draw(dx)
    if align == "center" then
      love.graphics.printf(text, dx, y, W, "center")
    else
      love.graphics.print(text, x + dx, y)
    end
  end
  for i = 5, 1, -1 do
    love.graphics.setColor(col[1], col[2], col[3], 0.07 * i * pulse)
    draw(-i)
    draw(i)
  end
  love.graphics.setColor(1, 1, 1, pulse)
  draw(0)
end

local Game = {}
Game.__index = Game
Game.maps = maps
Game.accepts = accepts
Game.norm = norm

function Game.new()
  local g = setmetatable({}, Game)
  g.state = "title"
  g.t = 0
  g.frame = 0
  g.intro = 0
  g.particles = {}
  g.shake = 0
  g.flash = 0
  g.flashKind = "bad"
  g.fade = 1
  g.hintLevel = 0 -- 0 none, 1 nudge, 2 answer
  g.hintOn = false
  g.hintAuto = false
  g.hintK = 0
  g.msg = ""
  g.msgKind = "idle"
  g.input = ""
  g.step = 1
  g.stage = 1
  g.solved = false
  g.player = { x = 200, facing = 1, walk = false }
  g.cam = 0
  g.hop = 0
  g.stamp = 0
  g.winT = 0
  g.mapT = 0
  g.idle = 0
  g.enterK = 0
  g.cleared = {}
  g.mapCursor = 1
  g.mapFrom = "title"
  g.mapK = 0
  g.mapHeroAt = 1 -- node Alex is standing on (or leaving)
  g.mapHeroX, g.mapHeroY = nil, nil
  g.mapHeroFacing = 1
  g.mapWalking = false
  g.mapHits = {}
  g.stationHits = {}
  g.mapBtn = nil
  g.actHint, g.actOk, g.actNext = nil, nil, nil
  g.swallowFrame = -1
  g.saved = nil
  return g
end

function Game:syncMetrics()
  W, H = Layout.vw, Layout.vh
  PORT = Layout.isPortrait()
  assets.ensureFonts(Layout.uiScale())
  local stationH = fontOf("station"):getHeight()
  local btnH = math.max(36, fontOf("button"):getHeight() + 18)
  local btnW = math.max(112, fontOf("button"):getWidth("WIND") + 32)
  TOP = math.max(PORT and 80 or 70, stationH + 52)
  local termShare = PORT and 0.52 or 0.55
  SCENE_H = math.floor(H * (1 - termShare)) - TOP
  local sceneMin = math.floor(H * (PORT and 0.32 or 0.38))
  local sceneMax = math.floor(H * (PORT and 0.46 or 0.52))
  SCENE_H = math.max(sceneMin, math.min(sceneMax, SCENE_H))
  TERM_Y = TOP + SCENE_H
  HUD.full[2] = math.floor((TOP - btnH) * 0.5)
  HUD.ori[2] = HUD.full[2]
  HUD.map[2] = HUD.full[2]
  HUD.lang[2] = HUD.full[2]
  HUD.full[3], HUD.full[4] = btnW, btnH
  HUD.ori[3], HUD.ori[4] = btnW, btnH
  HUD.map[3], HUD.map[4] = btnW, btnH
  HUD.lang[3], HUD.lang[4] = btnW, btnH
  HUD.ori[1] = W - btnW - 10
  HUD.full[1] = W - btnW * 2 - 20
  HUD.map[1] = W - btnW * 3 - 30
  HUD.lang[1] = W - btnW * 4 - 40
end

function Game:load()
  assets.load()
  SFX.warm()
  love.keyboard.setKeyRepeat(true)
  love.graphics.setBackgroundColor(Theme.sky)
  self:ingestProgress(Persist.loadProgress())
  self:enterTitle()
end

-- progress.jsonl -> cleared set + the "continue" target
function Game:ingestProgress(rec)
  self.cleared = Persist.parseCleared(rec)
  self.saved = nil
  if type(rec) ~= "table" then
    return
  end
  local step = tonumber(rec.step)
  if step and step >= 1 and step <= #maps then
    local stage = tonumber(rec.stage) or 1
    stage = math.max(1, math.min(#maps[step].stages, stage))
    self.saved = { step = step, stage = stage, solved = rec.solved and true or false }
  end
  if step and not rec.cleared then
    -- legacy record without a cleared list: everything before step is done
    local last = rec.solved and step or step - 1
    for i = 1, math.min(#maps, last) do
      self.cleared[maps[i].id] = true
    end
  end
end

function Game:save()
  Persist.saveProgress(self)
  self.saved = { step = self.step, stage = self.stage, solved = self.solved }
end

function Game:clearedIds()
  local ids = {}
  for i = 1, #maps do
    if self.cleared[maps[i].id] then
      ids[#ids + 1] = maps[i].id
    end
  end
  return ids
end

function Game:isCleared(i)
  local m = maps[i]
  return m ~= nil and self.cleared[m.id] == true
end

function Game:allCleared()
  for i = 1, #maps do
    if not self:isCleared(i) then
      return false
    end
  end
  return true
end

-- First street that is not CLEAR yet; 1 when everything is done.
function Game:firstOpen()
  for i = 1, #maps do
    if not self:isCleared(i) then
      return i
    end
  end
  return 1
end

function Game:markClear(i)
  local m = maps[i] or self:map()
  if not m then
    return
  end
  if not self.cleared[m.id] then
    self.cleared[m.id] = true
    self:burst(W * 0.5, TOP + SCENE_H * 0.4, 48)
  end
end

-- ---------------------------------------------------------------- states

function Game:enterTitle()
  self.state = "title"
  self.t = 0
  self.intro = 0
  self.fade = 1
  self.particles = {}
end

-- from: the state the map was opened from. ESC on the map goes back there.
function Game:enterMap(from)
  from = from or self.state
  if from == "map" then
    from = self.mapFrom
  end
  self.mapFrom = from
  self.state = "map"
  self.mapK = 0
  self.fade = math.min(self.fade, 0.35)
  if from == "play" then
    self.mapCursor = self.step
  elseif self.saved and not self.saved.solved then
    self.mapCursor = self.saved.step -- a half-done street: pick up there
  else
    self.mapCursor = self:firstOpen()
  end
  self.mapHeroAt = self.mapCursor
  self.mapHeroX, self.mapHeroY = nil, nil
  self.mapWalking = false
  self:burst(W * 0.5, H * 0.45, 18)
  SFX.play("open")
end

-- ---------------------------------------------------------------- overworld

function Game:mapHelpText()
  local back = self.mapFrom == "play" and T("esc_back") or T("esc_title")
  return T("map_help", back)
end

-- Height of the level-name box at the bottom of the overworld. The key help
-- may wrap (portrait, CJK), so it is measured.
function Game:mapPanelH()
  local pad = PORT and 10 or 24
  local smF = fontOf("small")
  local _, helpLines = smF:getWrap(self:mapHelpText(), W - pad * 2 - 36)
  return fontOf("ui"):getHeight() + smF:getHeight() * (1 + math.max(1, #helpLines)) + 44
end

-- Level dots, in virtual coordinates. Landscape: a zig-zag left to right.
-- Portrait: a zig-zag from the bottom up.
function Game:mapNodes()
  local nodes = {}
  local n = #maps
  local panelH = self:mapPanelH()
  if PORT then
    local xs = { 0.26, 0.70, 0.30, 0.72, 0.28, 0.70, 0.42 }
    local y0, y1 = TOP + 90, H - panelH - 70
    for i = 1, n do
      local f = (i - 1) / math.max(1, n - 1)
      nodes[i] = { x = W * (xs[i] or 0.5), y = ease.lerp(y1, y0, f) }
    end
  else
    local ys = { 0.76, 0.40, 0.68, 0.30, 0.64, 0.36, 0.62 }
    local y0, y1 = TOP + 50, H - panelH - 56
    for i = 1, n do
      local f = (i - 1) / math.max(1, n - 1)
      nodes[i] = { x = ease.lerp(W * 0.09, W * 0.91, f), y = ease.lerp(y0, y1, ys[i] or 0.5) }
    end
  end
  return nodes
end

-- Alex walks the dotted path one node at a time toward the cursor.
function Game:updateMap(dt)
  self.mapK = math.min(1, self.mapK + dt * 3.2)
  local nodes = self:mapNodes()
  local at = nodes[self.mapHeroAt]
  if not self.mapHeroX then
    self.mapHeroX, self.mapHeroY = at.x, at.y
  end
  if self.mapHeroAt == self.mapCursor then
    self.mapHeroX, self.mapHeroY = at.x, at.y
    self.mapWalking = false
    return
  end
  local nxt = self.mapHeroAt + (self.mapCursor > self.mapHeroAt and 1 or -1)
  local tx, ty = nodes[nxt].x, nodes[nxt].y
  local dx, dy = tx - self.mapHeroX, ty - self.mapHeroY
  local dist = math.sqrt(dx * dx + dy * dy)
  local step = (PORT and 460 or 420) * dt
  self.mapWalking = true
  if math.abs(dx) > 1 then
    self.mapHeroFacing = dx > 0 and 1 or -1
  end
  if dist <= step then
    self.mapHeroX, self.mapHeroY = tx, ty
    self.mapHeroAt = nxt
    SFX.play("step")
  else
    self.mapHeroX = self.mapHeroX + dx / dist * step
    self.mapHeroY = self.mapHeroY + dy / dist * step
  end
end

function Game:leaveMap()
  SFX.play("back")
  if self.mapFrom == "play" then
    self.state = "play"
    self.swallowFrame = self.frame
    self.fade = math.min(self.fade, 0.35)
  else
    self:enterTitle()
  end
end

-- Start (or restart) street i. stage restores a saved position.
-- quiet: no "select" blip (advance plays its own sweep)
function Game:enterPlay(i, stage, quiet)
  i = math.max(1, math.min(#maps, tonumber(i) or 1))
  local resumeSame = self.state == "map" and self.mapFrom == "play" and i == self.step
  if resumeSame then
    self:leaveMap()
    return
  end
  self:loadMap(i)
  if stage then
    self.stage = math.max(1, math.min(#maps[i].stages, tonumber(stage) or 1))
  end
  self.state = "play"
  self.fade = 1
  self.swallowFrame = self.frame
  if not quiet then
    SFX.play("select")
  end
  self:save()
end

-- Where "C" on the title goes: the half-done street, else the one after
-- the last solved street, else the first street not yet CLEAR.
function Game:continueTarget()
  local s = self.saved
  if not s then
    return nil
  end
  if not s.solved then
    return s.step, s.stage
  end
  if s.step < #maps then
    return s.step + 1, 1
  end
  return self:firstOpen(), 1
end

-- Title "C": pick up where progress.jsonl left off.
function Game:continue()
  local step, stage = self:continueTarget()
  if step then
    self:enterPlay(step, stage)
  else
    self:enterMap("title")
  end
end

function Game:enterWin()
  self.state = "win"
  self.winT = 0
  SFX.play("win")
  self.fade = 1
  self:burst(W * 0.5, H * 0.4, 80)
  self:save()
end

function Game:loadMap(i)
  self.step = i
  self.stage = 1
  self.solved = false
  self:setHint(0)
  self.hintAuto = false
  self.hintK = 0
  self.input = ""
  self.msg = ""
  self.msgKind = "idle"
  self.stamp = 0
  self.hop = 0
  local m = maps[i]
  self.player.x = m.spawn
  self.player.facing = 1
  self.player.walk = false
  self.cam = math.max(0, m.spawn - W * 0.32)
  self.mapT = 0
  self.idle = 0
  self.enterK = 0
end

function Game:map()
  return maps[self.step]
end

function Game:currentStage()
  local m = self:map()
  return m.stages[math.max(1, math.min(#m.stages, self.stage))]
end

function Game:burst(x, y, n)
  n = n or 24
  for _ = 1, n do
    local ang = love.math.random() * math.pi * 2
    local sp = 60 + love.math.random() * 220
    local pal = { COL.gold, COL.neon, COL.cyan, COL.cream, COL.admit }
    local c = pal[love.math.random(#pal)]
    self.particles[#self.particles + 1] = {
      x = x,
      y = y,
      vx = math.cos(ang) * sp,
      vy = math.sin(ang) * sp - 80,
      life = 0.7 + love.math.random() * 0.8,
      max = 1.4,
      r = 2 + love.math.random() * 4,
      c = c,
    }
  end
end

-- ---------------------------------------------------------------- update

function Game:update(dt)
  self:syncMetrics()
  dt = math.min(dt, 1 / 20)
  self.frame = self.frame + 1
  self.t = self.t + dt
  self.intro = math.min(1, self.intro + dt * 0.55)
  self.shake = E.smooth(self.shake, 0, dt, 8)
  self.flash = math.max(0, self.flash - dt * 3)
  self.fade = E.smooth(self.fade, 0, dt, 3.2)
  self.hop = math.max(0, self.hop - dt)

  for i = #self.particles, 1, -1 do
    local p = self.particles[i]
    p.life = p.life - dt
    p.vy = p.vy + 420 * dt
    p.x = p.x + p.vx * dt
    p.y = p.y + p.vy * dt
    if p.life <= 0 then
      table.remove(self.particles, i)
    end
  end

  if self.state == "title" then
    self:updateTitle(dt)
  elseif self.state == "map" then
    self:updateMap(dt)
  elseif self.state == "play" then
    self:updatePlay(dt)
  else
    self.winT = self.winT + dt
  end
end

function Game:updateTitle(dt)
  if love.math.random() < dt * 8 then
    self.particles[#self.particles + 1] = {
      x = love.math.random(40, W - 40),
      y = H + 10,
      vx = (love.math.random() - 0.5) * 20,
      vy = -40 - love.math.random() * 50,
      life = 2.5,
      max = 2.5,
      r = 1.5,
      c = COL.gold,
    }
  end
end

function Game:updatePlay(dt)
  self.mapT = self.mapT + dt
  local m = self:map()
  self.player.walk = false
  -- Arrows walk only after CLEAR. While a blank is open the keyboard types.
  if self.solved then
    local left = love.keyboard.isDown("left")
    local right = love.keyboard.isDown("right")
    local speed = 300
    if left and not right then
      self.player.x = self.player.x - speed * dt
      self.player.facing = -1
      self.player.walk = true
    elseif right and not left then
      self.player.x = self.player.x + speed * dt
      self.player.facing = 1
      self.player.walk = true
    end
  end
  self.player.x = math.max(80, math.min(m.width - 80, self.player.x))

  local target = self.player.x - W * 0.32
  target = math.max(0, math.min(math.max(0, m.width - W), target))
  self.cam = E.smooth(self.cam, target, dt, 4.2)

  if self.solved then
    self.stamp = math.min(1, self.stamp + dt * 1.4)
    if self.player.x > m.width - 110 then
      self:advance()
    end
  else
    self.idle = self.idle + dt
    if self.hintLevel == 0 and not self.hintAuto and self.idle >= HINT_WAIT then
      self:setHint(1)
      self.hintAuto = true
      self:burst(W * 0.22, TERM_Y + 40, 16)
    end
  end
  self.hintK = E.smooth(self.hintK, self.hintOn and 1 or 0, dt, 10)
  self.enterK = math.min(1, self.mapT * 2.4)
end

-- ---------------------------------------------------------------- quiz

function Game:setHint(level)
  level = math.max(0, math.min(2, level))
  if level > 0 and self.hintLevel == 0 then
    self.hintK = 0
  end
  self.hintLevel = level
  self.hintOn = level > 0
end

-- HINT cycles: nudge -> answer -> hidden.
function Game:toggleHint()
  self:setHint((self.hintLevel + 1) % 3)
  SFX.play(self.hintLevel > 0 and "hint" or "back")
  self.idle = 0
end

-- self.msg holds an i18n key or a { en=, ko=, yue= } table so the feedback
-- line follows a language switch.
function Game:msgText()
  local m = self.msg
  if m == nil or m == "" then
    return ""
  end
  if type(m) == "table" then
    return P(m)
  end
  return T(m)
end

function Game:submit()
  if self.state ~= "play" or self.solved then
    return
  end
  local st = self:currentStage()
  local m = self:map()
  if accepts(self.input, st.accept) then
    self.msg = st.ok
    self.msgKind = "ok"
    self.hop = 0.55
    self.idle = 0
    self:burst(W * 0.5, TOP + SCENE_H * 0.45, 36)
    if self.stage < #m.stages then
      SFX.play(st.answer == "DENY" and "deny" or "ok")
      self.stage = self.stage + 1
      self.input = ""
      self:setHint(0)
      self.hintAuto = false
    else
      self.solved = true
      SFX.play("clear")
      self.input = ""
      self:setHint(0)
      self:markClear(self.step)
      self.flashKind = "good"
      self.flash = 0.45
    end
    self:save()
  else
    if self.input == "" then
      self.msg = "msg_empty"
    else
      self.msg = "msg_wrong"
      self:setHint(math.max(self.hintLevel, 1))
    end
    self.msgKind = "bad"
    SFX.play("bad")
    self.shake = 10
    self.flashKind = "bad"
    self.flash = 0.6
    self.idle = 0
  end
end

-- After CLEAR: the stamp once every street is clear, else the next street,
-- else (last street, some still open) the map.
function Game:advance()
  if self.state ~= "play" or not self.solved then
    return
  end
  if self:allCleared() then
    self:enterWin()
    return
  end
  if self.step >= #maps then
    self:enterMap("play")
    return
  end
  SFX.play("next")
  self:enterPlay(self.step + 1, nil, true)
end

-- ---------------------------------------------------------------- draw

function Game:pixBtn(x, y, w, h, label, lit)
  local hit = Layout.hit(x, y, w, h)
  local font = fontOf("button")
  UI.panel(x, y, w, h, (lit or hit) and Theme.coin or Theme.panel)
  love.graphics.setFont(font)
  love.graphics.setColor(Theme.ink)
  local fh = font:getHeight()
  love.graphics.printf(label, x, y + math.floor((h - fh) * 0.5) - 2, w, "center")
end

function Game:drawHud()
  local full = Layout.fullscreen and T("hud_full") or T("hud_wind")
  local ori = PORT and T("hud_port") or T("hud_land")
  local mapLabel = self.state == "map" and T("hud_back") or T("hud_map")
  self:pixBtn(HUD.lang[1], HUD.lang[2], HUD.lang[3], HUD.lang[4], I18n.NAMES[I18n.lang] or "EN")
  self:pixBtn(HUD.map[1], HUD.map[2], HUD.map[3], HUD.map[4], mapLabel, self.state == "map")
  self:pixBtn(HUD.full[1], HUD.full[2], HUD.full[3], HUD.full[4], full)
  self:pixBtn(HUD.ori[1], HUD.ori[2], HUD.ori[3], HUD.ori[4], ori)
end

function Game:draw()
  self:syncMetrics()
  local sx = (love.math.random() - 0.5) * self.shake
  local sy = (love.math.random() - 0.5) * self.shake * 0.4
  love.graphics.push()
  love.graphics.translate(sx, sy)

  if self.state == "title" then
    self:drawTitle()
  elseif self.state == "map" then
    self:drawMap()
  elseif self.state == "play" then
    self:drawPlay()
  else
    self:drawWin()
  end

  self:drawParticles()
  love.graphics.pop()
  love.graphics.setScissor()

  self:drawHud()

  if self.flash > 0 then
    if self.flashKind == "good" then
      love.graphics.setColor(0.15, 0.55, 0.28, self.flash * 0.28)
    else
      love.graphics.setColor(0.75, 0.12, 0.2, self.flash * 0.28)
    end
    love.graphics.rectangle("fill", 0, 0, W, H)
  end
  if self.fade > 0.01 then
    love.graphics.setColor(0, 0, 0, self.fade)
    love.graphics.rectangle("fill", 0, 0, W, H)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function Game:drawParticles()
  for i = 1, #self.particles do
    local p = self.particles[i]
    local a = ease.clamp(p.life / (p.max or 1), 0, 1)
    setC(p.c, a)
    love.graphics.circle("fill", p.x, p.y, p.r)
  end
  love.graphics.setColor(1, 1, 1, 1)
end

function Game:drawBg(name, x, y, w, h, kind)
  return World.draw(name, x, y, w, h, PORT, kind or "play")
end

function Game:drawTitle()
  local k = ease.expOut(self.intro)
  local cam = self:drawBg("title_bg", 0, 0, W, H, "title")
  local gy = cam.groundY
  local ch = cam.charH
  local gap = ch * 0.78
  local titleF = fontOf("title")
  local subF = fontOf("subtitle")
  local uiF = fontOf("ui")
  local smF = fontOf("small")
  local th, sh, uh, mh = titleF:getHeight(), subF:getHeight(), uiF:getHeight(), smF:getHeight()

  local ty = ease.lerp(PORT and 28 or 20, PORT and 56 or 36, k)
  -- dark band so the title reads over the neon signs
  love.graphics.setColor(0.02, 0.02, 0.10, 0.62 * k)
  love.graphics.rectangle("fill", 0, ty - 14, W, th + sh + mh + 40)
  neonPrint(titleF, "GATE 18", 0, ty, COL.neon, self.t, "center")
  love.graphics.setFont(subF)
  love.graphics.setColor(COL.gold[1], COL.gold[2], COL.gold[3], k)
  love.graphics.printf(T("subtitle"), 0, ty + th + 6, W, "center")
  love.graphics.setFont(smF)
  love.graphics.setColor(COL.cream[1], COL.cream[2], COL.cream[3], k * 0.95)
  love.graphics.printf(T("tagline"), 0, ty + th + sh + 12, W, "center")

  local hx = ease.lerp(-ch, W * 0.18, k)
  sprites.draw("hero", hx, gy, { t = self.t, walk = self.intro < 1, facing = 1, h = ch })
  sprites.draw("mei", hx + gap, gy, { t = self.t + 0.4, walk = self.intro < 1, facing = 1, h = ch })
  sprites.draw("ken", hx + gap * 1.9, gy, { t = self.t + 0.9, walk = self.intro < 1, facing = 1, h = ch })
  sprites.draw("clerk", W * 0.78, gy, { t = self.t, facing = -1, h = ch })
  sprites.item("item_beer", W * 0.88, gy - ch * 0.28, ch * 0.38, math.sin(self.t) * 0.1)

  local bar = 24 + uh + 6 + mh + 6 + mh + 12
  UI.panel(12, H - bar - 8, W - 24, bar, Theme.panel)
  local blink = 0.55 + 0.45 * (0.5 + 0.5 * math.cos(self.t * 3.2))
  love.graphics.setFont(uiF)
  love.graphics.setColor(Theme.ink[1], Theme.ink[2], Theme.ink[3], blink * k)
  love.graphics.printf(T("title_enter"), 12, H - bar + 10, W - 24, "center")
  love.graphics.setFont(smF)
  setC(Theme.brick, 0.95 * k)
  local target = self:continueTarget()
  if target then
    local m = maps[target]
    local n = #self:clearedIds()
    love.graphics.printf(T("title_continue", m.station, n, #maps), 12, H - bar + 12 + uh, W - 24, "center")
  else
    love.graphics.printf(T("title_fresh"), 12, H - bar + 12 + uh, W - 24, "center")
  end
  setC(Theme.ink, 0.8 * k)
  love.graphics.printf(T("title_help"), 12, H - 16 - mh, W - 24, "center")
end

function Game:drawStations(m)
  UI.bar(0, 0, W, TOP)
  local font = fontOf("station")
  local n = #maps
  local x0, x1 = 28, HUD.lang[1] - 16
  local span = (x1 - x0) / math.max(1, n - 1)
  local maxW = 0
  for i = 1, n do
    maxW = math.max(maxW, font:getWidth(maps[i].station))
  end
  if span < maxW + 8 then
    font = fontOf("stationSm") or font
    maxW = 0
    for i = 1, n do
      maxW = math.max(maxW, font:getWidth(maps[i].station))
    end
  end
  local showNames = span >= maxW + 4
  love.graphics.setFont(font)
  local labelH = showNames and font:getHeight() or 0
  local blockH = 16 + labelH
  local pipY = math.max(6, math.floor((TOP - blockH) * 0.5))
  local labelY = pipY + 16
  local boxW = math.max(maxW, 48)
  x0 = math.max(x0, math.floor(boxW * 0.5) + 12)
  x1 = math.min(x1, HUD.lang[1] - math.floor(boxW * 0.5) - 12)
  span = (x1 - x0) / math.max(1, n - 1)
  if showNames and span < maxW + 4 then
    showNames = false
  end
  self.stationHits = {}
  for i = 1, n do
    local x = ease.lerp(x0, x1, (i - 1) / math.max(1, n - 1))
    local cleared = self:isCleared(i)
    if i < n then
      local x2 = ease.lerp(x0, x1, i / (n - 1))
      love.graphics.setColor(cleared and Theme.coin or Theme.withAlpha(Theme.cream, 0.22))
      love.graphics.rectangle("fill", x + 8, pipY + 5, x2 - x - 16, 4)
    end
    local on = i == self.step
    local r = on and 8 or 6
    if cleared then
      setC(Theme.admit)
    elseif on then
      setC(Theme.red)
    else
      love.graphics.setColor(1, 1, 1, 0.28)
    end
    love.graphics.rectangle("fill", x - r, pipY, r * 2, r * 2)
    local hitX = x - boxW * 0.5
    self.stationHits[i] = { hitX, 0, boxW, TOP }
    if showNames then
      love.graphics.setColor(COL.cream[1], COL.cream[2], COL.cream[3], on and 1 or 0.7)
      love.graphics.printf(maps[i].station, hitX, labelY, boxW, "center")
    end
  end
  if not showNames then
    love.graphics.setFont(fontOf("station"))
    setC(Theme.cream)
    love.graphics.print(m.station, 16, math.floor((TOP - fontOf("station"):getHeight()) * 0.5))
  end
end

local function star(x, y, r, col)
  local pts = {}
  for i = 0, 9 do
    local a = -math.pi / 2 + i * math.pi / 5
    local rr = (i % 2 == 0) and r or r * 0.45
    pts[#pts + 1] = x + math.cos(a) * rr
    pts[#pts + 1] = y + math.sin(a) * rr
  end
  setC(Theme.ink)
  love.graphics.setLineWidth(3)
  love.graphics.polygon("line", pts)
  love.graphics.setLineWidth(1)
  setC(col)
  love.graphics.polygon("fill", pts)
end

-- Outlined pixel text, readable on any backdrop.
local function shadowText(font, text, x, y, w, align, col)
  love.graphics.setFont(font)
  setC(Theme.ink)
  for _, d in ipairs({ { 2, 2 }, { -2, 2 }, { 2, -2 }, { -2, -2 }, { 0, 2 }, { 2, 0 } }) do
    love.graphics.printf(text, x + d[1], y + d[2], w, align)
  end
  setC(col)
  love.graphics.printf(text, x, y, w, align)
end

-- Hand-drawn overworld when assets/map_bg*.png is missing.
function Game:drawOverworldFallback()
  setC(Theme.sky)
  love.graphics.rectangle("fill", 0, 0, W, H)
  -- far hills
  for i = 0, 6 do
    local hx = i * W / 5 - W * 0.1 + math.sin(i * 3.1) * 40
    love.graphics.setColor(0.16, 0.62, 0.30, 1)
    love.graphics.ellipse("fill", hx, H * 0.55, W * 0.22, H * 0.20)
  end
  setC(Theme.grass)
  love.graphics.rectangle("fill", 0, H * 0.52, W, H)
  love.graphics.setColor(0.10, 0.55, 0.22, 1)
  for i = 0, 8 do
    love.graphics.ellipse("fill", i * W / 7 + 40, H * 0.55 + (i % 3) * 30, 70, 26)
  end
  -- water at the bottom
  love.graphics.setColor(0.18, 0.36, 0.86, 1)
  love.graphics.rectangle("fill", 0, H * 0.92, W, H * 0.08)
end

function Game:drawOverworldBg()
  local img = assets.picture("map_bg", PORT)
  if not img then
    self:drawOverworldFallback()
    return
  end
  local iw, ih = img:getWidth(), img:getHeight()
  local sc = math.max(W / iw, H / ih)
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(img, (W - iw * sc) * 0.5, (H - ih * sc) * 0.5, 0, sc, sc)
  -- night haze so dots and labels pop
  love.graphics.setColor(0.02, 0.02, 0.10, 0.22)
  love.graphics.rectangle("fill", 0, 0, W, H)
end

-- The street picker as a 16-bit overworld: a dotted path across Causeway
-- Bay, one level dot per street, Alex standing on the current one.
function Game:drawMap()
  local k = ease.expOut(math.min(1, self.mapK))
  self:drawOverworldBg()
  -- clouds drifting behind everything
  for i = 1, 4 do
    local cx = ((self.t * (14 + i * 5) + i * 337) % (W + 240)) - 120
    local cy = TOP + 30 + (i * 53) % 120
    love.graphics.setColor(1, 1, 1, 0.85)
    love.graphics.ellipse("fill", cx, cy, 46, 16)
    love.graphics.ellipse("fill", cx - 22, cy + 6, 26, 12)
    love.graphics.ellipse("fill", cx + 26, cy + 6, 30, 13)
  end

  local nodes = self:mapNodes()
  local n = #maps
  local labelF = PORT and fontOf("stationSm") or fontOf("station")

  -- dotted path; the stretch after a cleared street lights up gold
  for i = 1, n - 1 do
    local a, b = nodes[i], nodes[i + 1]
    local dx, dy = b.x - a.x, b.y - a.y
    local len = math.sqrt(dx * dx + dy * dy)
    local steps = math.max(2, math.floor(len / 16))
    local lit = self:isCleared(i)
    for j = 1, steps - 1 do
      local f = j / steps
      local px, py = a.x + dx * f, a.y + dy * f
      setC(Theme.ink)
      love.graphics.circle("fill", px, py, 5)
      setC(lit and Theme.coin or Theme.panel, lit and 1 or 0.85)
      love.graphics.circle("fill", px, py, 3.5)
    end
  end

  -- level dots
  self.mapHits = {}
  for i = 1, n do
    local m = maps[i]
    local nd = nodes[i]
    local cleared = self:isCleared(i)
    local here = self.mapFrom == "play" and i == self.step
    -- landmarks
    if m.id == "office" then
      sprites.item("item_envelope", nd.x - 40, nd.y - 34, 44, -0.15)
    elseif m.id == "beer" then
      sprites.item("item_beer", nd.x - 42, nd.y - 36, 48, 0.1)
    end
    setC(Theme.ink)
    love.graphics.circle("fill", nd.x, nd.y, 17)
    setC(cleared and Theme.admit or Theme.red)
    love.graphics.circle("fill", nd.x, nd.y, 13)
    love.graphics.setColor(1, 1, 1, 0.55)
    love.graphics.circle("fill", nd.x - 4, nd.y - 5, 4)
    if cleared then
      star(nd.x + 16, nd.y - 16, 11, Theme.coin)
    end
    if here and not cleared then
      love.graphics.setColor(1, 1, 1, 0.6 + 0.4 * math.sin(self.t * 5))
      love.graphics.circle("line", nd.x, nd.y, 20)
    end
    local lw = 140
    shadowText(
      labelF,
      string.format("%d %s", i, m.station),
      nd.x - lw * 0.5,
      nd.y + 22,
      lw,
      "center",
      i == self.mapCursor and Theme.coin or Theme.cream
    )
    self.mapHits[i] = { nd.x - 36, nd.y - 40, 72, 84 }
  end

  -- Alex on the path
  if self.mapHeroX then
    local hh = PORT and 64 or 56
    sprites.draw("hero", self.mapHeroX, self.mapHeroY + 6, {
      t = self.t,
      facing = self.mapHeroFacing,
      walk = self.mapWalking,
      h = hh,
    })
    if not self.mapWalking then
      -- bouncing arrow over the chosen street
      local ay = self.mapHeroY - hh - 22 + math.sin(self.t * 6) * 5
      setC(Theme.ink)
      love.graphics.polygon("fill", self.mapHeroX - 12, ay - 14, self.mapHeroX + 12, ay - 14, self.mapHeroX, ay)
      setC(Theme.coin)
      love.graphics.polygon("fill", self.mapHeroX - 8, ay - 12, self.mapHeroX + 8, ay - 12, self.mapHeroX, ay - 3)
    end
  end

  -- level-name box
  local uiF, smF = fontOf("ui"), fontOf("small")
  local line, sub = uiF:getHeight(), smF:getHeight()
  local pad = PORT and 10 or 24
  local panelH = self:mapPanelH()
  local py = H - panelH - 8 + (1 - k) * 40
  UI.panel(pad, py, W - pad * 2, panelH, Theme.panel)
  local m = maps[self.mapCursor]
  local cleared = self:isCleared(self.mapCursor)
  local here = self.mapFrom == "play" and self.mapCursor == self.step
  love.graphics.setFont(uiF)
  setC(Theme.ink)
  love.graphics.print(string.format("%d  %s", self.mapCursor, m.station), pad + 18, py + 14)
  local tag = cleared and T("clear") or (here and T("here") or "")
  local nClear = #self:clearedIds()
  local right = T("clear_count", nClear, #maps)
  if tag ~= "" then
    right = tag .. "    " .. right
  end
  setC(cleared and Theme.admit or Theme.brick)
  love.graphics.printf(right, pad, py + 14, W - pad * 2 - 18, "right")
  love.graphics.setFont(smF)
  setC(Theme.navy)
  love.graphics.print(P(m.name) .. "  -  " .. P(m.title), pad + 18, py + 14 + line + 6)
  setC(Theme.ink, 0.85)
  love.graphics.printf(self:mapHelpText(), pad + 18, py + 14 + line + 6 + sub + 6, W - pad * 2 - 36, "center")
end

function Game:drawPlay()
  local m = self:map()
  self:drawStations(m)

  love.graphics.push()
  love.graphics.setScissor(0, TOP, W, SCENE_H)
  love.graphics.translate(0, TOP)
  local cam = self:drawBg(m.bg, 0, 0, W, SCENE_H, "play")

  love.graphics.push()
  love.graphics.translate(-self.cam, 0)
  self:drawViz(m)
  self:drawWorld(m, cam)
  love.graphics.pop()

  local labelF = fontOf("station")
  local label = T("map_label", self.step, #maps, P(m.title))
  love.graphics.setFont(labelF)
  local lw = math.min(W - 24, labelF:getWidth(label) + 32)
  local lh = labelF:getHeight() + 16
  UI.well(10, 8, lw, lh, { 0.08, 0.06, 0.16, 0.92 })
  setC(COL.gold)
  love.graphics.print(label, 22, 8 + 8)
  self.mapBtn = { 10, TOP + 8, lw, lh }

  if self.solved then
    local pulse = 0.5 + 0.5 * math.cos(self.t * 4)
    local uiF = assets.font.ui
    local text
    if self:allCleared() then
      text = T("clear_stamp")
    elseif self.step >= #maps then
      text = T("clear_map")
    else
      text = T("clear_next")
    end
    local tw = uiF:getWidth(text) + 32
    local th = uiF:getHeight() + 16
    UI.well(W - tw - 10, SCENE_H - th - 8, tw, th, { 0.08, 0.06, 0.16, 0.92 })
    love.graphics.setFont(uiF)
    love.graphics.setColor(COL.admit[1], COL.admit[2], COL.admit[3], 0.7 + 0.3 * pulse)
    love.graphics.print(text, W - tw + 6, SCENE_H - th)
  end

  love.graphics.pop()
  love.graphics.setScissor()

  self:drawTerminal(m)
end

function Game:drawWorld(m, cam)
  cam = cam or { groundY = SCENE_H * 0.88, charH = SCENE_H * 0.42 }
  local gy = cam.groundY
  local ch = cam.charH

  for i = 1, #m.npcs do
    local n = m.npcs[i]
    if n.kind ~= "hero" then
      sprites.draw(n.kind, n.x, gy, {
        t = self.t + i,
        facing = n.facing,
        h = ch,
      })
      local line = P(n.line)
      if math.abs(self.player.x - n.x) < ch * 1.15 and line ~= "" then
        self:bubble(n.x, gy - ch - 12, line)
      end
    end
  end

  local bounce = 0
  if self.hop > 0 then
    bounce = sprites.hop(1 - self.hop / 0.55, ch * 0.12)
  end
  sprites.draw("hero", self.player.x, gy, {
    t = self.t,
    facing = self.player.facing,
    walk = self.player.walk,
    bounce = bounce,
    h = ch,
  })

  if self.solved then
    local gx = m.width - 48
    local a = 0.4 + 0.6 * ease.cosine((math.sin(self.t * 3) + 1) * 0.5)
    love.graphics.setColor(Theme.admit[1], Theme.admit[2], Theme.admit[3], a)
    love.graphics.rectangle("fill", gx, gy - ch * 0.9, 10, ch * 0.9)
    star(gx + 5, gy - ch - 14, 16, Theme.coin)
  end
end

function Game:bubble(x, y, text)
  local font = fontOf("bubble")
  love.graphics.setFont(font)
  local padX, padY = 20, 16
  local maxW = math.min(640, math.floor(W * 0.70))
  local inner = maxW - padX * 2
  local _, lines = font:getWrap(text, inner)
  local textW = 0
  for i = 1, #lines do
    textW = math.max(textW, font:getWidth(lines[i]))
  end
  local w = math.min(maxW, textW + padX * 2)
  local lh = font:getHeight()
  local h = #lines * lh + padY * 2
  -- world coordinates; the camera shows [cam, cam + W)
  local bx = math.max(self.cam + 8, math.min(self.cam + W - w - 8, x - w * 0.5))
  local by = math.max(44, y - h)
  UI.panel(bx, by, w, h, Theme.cream)
  love.graphics.setColor(Theme.ink)
  love.graphics.printf(text, bx + padX, by + padY - 2, w - padX * 2, "center")
end

function Game:drawViz(m)
  local fn = self.viz[m.viz]
  if fn then
    fn(self, m)
  end
end

Game.viz = {}

function Game.viz.street(self, m)
  -- neon flicker shop signs
  for i = 1, 6 do
    local x = 240 + i * 180
    local a = 0.35 + 0.65 * (0.5 + 0.5 * math.cos(self.t * (2 + i * 0.37) + i))
    love.graphics.setColor(1, 0.2, 0.55, a * 0.45)
    roundrect("fill", x, 70, 70, 18, 3)
    love.graphics.setColor(0, 0.9, 1, a * 0.35)
    roundrect("fill", x + 8, 96, 50, 12, 3)
  end
end

function Game.viz.mart(self, m)
  -- locked fridge
  local lock = 0.5 + 0.5 * math.cos(self.t * 3)
  love.graphics.setColor(0.75, 0.18, 0.22, 0.35 + 0.3 * lock)
  roundrect("fill", 1180, 80, 90, 200, 6)
  love.graphics.setFont(assets.font.small)
  love.graphics.setColor(1, 1, 1, 0.8)
  love.graphics.printf("18+", 1180, 160, 90, "center")
  -- ID card flies away if not solved
  local p = ease.cosineOut(math.min(1, self.mapT * 0.6))
  local ix = 400 + p * 80
  local iy = 90 - p * 40
  love.graphics.setColor(0.89, 0.82, 0.68, 0.9)
  roundrect("fill", ix, iy, 70, 44, 4)
  love.graphics.setColor(0.11, 0.16, 0.29, 1)
  love.graphics.setFont(assets.font.small)
  love.graphics.print("ID", ix + 8, iy + 8)
  love.graphics.setColor(0.75, 0.18, 0.22, 1)
  love.graphics.print("NOPE", ix + 8, iy + 24)
end

function Game.viz.office(self, m)
  local img = assets.picture("item_envelope")
  local s = ease.expOut(math.min(1, self.mapT * 0.8))
  local y = 140 - (1 - s) * 80
  if img then
    local sc = 0.22 * s
    love.graphics.setColor(1, 1, 1, s)
    love.graphics.draw(img, 900, y, math.sin(self.t) * 0.05, sc, sc, img:getWidth() * 0.5, img:getHeight() * 0.5)
  end
  -- age number gets sucked in
  local hide = ease.cosineIn(math.min(1, self.mapT * 0.5))
  love.graphics.setFont(assets.font.subtitle)
  love.graphics.setColor(COL.stamp[1], COL.stamp[2], COL.stamp[3], 1 - hide)
  love.graphics.print("age = 25", 420, 90 + hide * 40)
  love.graphics.setFont(assets.font.ui)
  setC(COL.gold, 0.85)
  love.graphics.print("C = g^age * h^r", 420, 130)
end

function Game.viz.bits(self, m)
  local bits = { 1, 1, 1, 0, 0, 0, 0, 0 }
  local lit
  if self.stage >= 2 or self.solved then
    lit = 8
  elseif accepts(self.input, { "7" }) then
    lit = 8
  else
    lit = math.floor(ease.cosineOut(math.min(1, self.mapT * 0.35)) * 3)
  end
  for i = 1, 8 do
    local x = 280 + (i - 1) * 130
    local on = i <= lit and bits[i] == 1
    local rise = ease.expOut(ease.clamp((self.mapT - i * 0.08) / 0.4, 0, 1))
    local h = 40 + 90 * rise
    if on then
      love.graphics.setColor(0.79, 0.64, 0.36, 0.85)
    else
      love.graphics.setColor(0.15, 0.2, 0.35, 0.8)
    end
    love.graphics.rectangle("fill", x, 196 - h, 36, h, 4, 4)
    love.graphics.setFont(assets.font.ui)
    love.graphics.setColor(1, 1, 1, 0.9)
    love.graphics.printf(on and "1" or "0", x, 204, 36, "center")
    love.graphics.setFont(assets.font.small)
    love.graphics.setColor(COL.cyan[1], COL.cyan[2], COL.cyan[3], 0.7)
    love.graphics.printf("2^" .. (i - 1), x - 8, 224, 52, "center")
  end
end

function Game.viz.sigma(self, m)
  local labels = { "t", "c", "s" }
  local cols = { COL.cyan, COL.gold, COL.neon }
  for i = 1, 3 do
    local phase = (self.t * 0.55 + (i - 1) * 0.33) % 1
    local travel = ease.cosine(phase)
    local x1, x2 = 280, 980
    local x = (i == 2) and ease.lerp(x2, x1, travel) or ease.lerp(x1, x2, travel)
    local y = 120 + math.sin((phase + i) * math.pi * 2) * 18
    setC(cols[i], 0.9)
    love.graphics.circle("fill", x, y, 22)
    love.graphics.setColor(0.03, 0.04, 0.09, 1)
    love.graphics.setFont(assets.font.subtitle)
    love.graphics.printf(labels[i], x - 20, y - 16, 40, "center")
  end
  love.graphics.setFont(assets.font.small)
  setC(COL.cream, 0.7)
  love.graphics.print("announce", 260, 200)
  love.graphics.print("challenge", 600, 70)
  love.graphics.print("respond", 960, 200)
end

function Game.viz.hash(self, m)
  local spin = self.t * 1.6
  love.graphics.push()
  love.graphics.translate(900, 150)
  love.graphics.rotate(spin)
  love.graphics.setColor(COL.gold[1], COL.gold[2], COL.gold[3], 0.7)
  love.graphics.circle("line", 0, 0, 48)
  love.graphics.circle("line", 0, 0, 28)
  for i = 1, 8 do
    local a = i * math.pi / 4
    love.graphics.line(math.cos(a) * 20, math.sin(a) * 20, math.cos(a) * 48, math.sin(a) * 48)
  end
  love.graphics.pop()
  love.graphics.setFont(assets.font.ui)
  setC(COL.gold)
  love.graphics.print("SHA-256", 860, 210)
  -- nonce ticket
  local wave = math.sin(self.t * 2) * 8
  love.graphics.setColor(0.95, 0.90, 0.80, 0.95)
  roundrect("fill", 360, 90 + wave, 160, 70, 6)
  love.graphics.setColor(0.07, 0.09, 0.16, 1)
  love.graphics.setFont(assets.font.small)
  love.graphics.print("GATE TICKET", 372, 100 + wave)
  love.graphics.setFont(assets.font.code)
  love.graphics.print("one use", 372, 122 + wave)
end

function Game.viz.beer(self, m)
  local img = assets.picture("item_beer")
  local s = self.solved and ease.expOut(self.stamp) or 0.15
  if img then
    local sc = 0.28 * (0.7 + 0.3 * s)
    local y = 150 - s * 20 + math.sin(self.t * 2) * 6 * s
    love.graphics.setColor(1, 1, 1, 0.3 + 0.7 * s)
    love.graphics.draw(img, 1120, y, math.sin(self.t) * 0.04 * s, sc, sc, img:getWidth() * 0.5, img:getHeight() * 0.5)
  end
  if self.solved then
    love.graphics.setFont(assets.font.stamp)
    local k = ease.expOut(self.stamp)
    love.graphics.push()
    love.graphics.translate(640, 140)
    love.graphics.rotate(-0.18)
    love.graphics.scale(0.4 + 0.6 * k)
    love.graphics.setColor(0.22, 0.62, 0.38, k)
    roundrect("line", -90, -28, 180, 56, 6)
    love.graphics.printf("ADMIT", -90, -22, 180, "center")
    love.graphics.pop()
  end
end

-- The bottom half: story + question (left), code with the blank (right),
-- the input prompt, and HINT / OK / NEXT buttons.
function Game:drawTerminal(m)
  local y = TERM_Y
  local slide = (1 - ease.expOut(self.enterK)) * 28
  love.graphics.push()
  love.graphics.translate(0, slide)

  love.graphics.setColor(Theme.wood)
  love.graphics.rectangle("fill", 0, y, W, H - y)
  love.graphics.setColor(Theme.coin)
  love.graphics.rectangle("fill", 0, y, W, 4)

  local storyF = fontOf("small")
  local codeF = fontOf("code")
  local helpF = fontOf("help")
  local nameF = fontOf("small")
  local storyHgt = storyF:getHeight()
  local codeHgt = codeF:getHeight()
  local helpH = math.max(helpF:getHeight() + 12, fontOf("button"):getHeight() + 22)
  local promptH = codeHgt + 20
  local pad = PORT and 8 or 10

  local face = ({
    portrait_friends = "mei",
    portrait_clerk = "clerk",
    portrait_hero = "hero",
    portrait_officer = "officer",
  })[m.portrait] or "hero"

  local st = self:currentStage()
  local story = P(m.story)
  local question = T("q_prefix") .. P(st.q)
  local code = P(st.code)
  local shown
  if self.solved then
    shown = st.answer or st.accept[1]
  elseif self.input == "" then
    shown = "___"
  else
    shown = self.input
  end
  local orig = {}
  for line in (code .. "\n"):gmatch("(.-)\n") do
    orig[#orig + 1] = line
  end
  local rendered = fillBlank(code, shown)

  local promptY = H - helpH - promptH - 4
  -- the question sits in its own bar right above the input
  local qF = fontOf("small")
  local qW = W - pad * 2 - 28
  local _, qLines = qF:getWrap(question, qW)
  local qBarH = #qLines * qF:getHeight() + 14
  local qY = promptY - qBarH - 4
  local bodyY = y + 8
  local bodyH = qY - bodyY - 6
  local hintH = 0
  local hintText = self.hintLevel >= 2 and (T("answer") .. "  " .. tostring(st.answer or st.accept[1])) or T("hint")
  local hintWhy = P(st.hint)
  if self.hintOn then
    local guessW = PORT and (W - pad * 2 - 24) or math.floor(W * 0.42) - 32
    local _, hlines = nameF:getWrap(hintWhy, math.max(80, guessW))
    hintH = fontOf("ui"):getHeight() + 6 + #hlines * nameF:getHeight() + 18
  end

  local storyX, storyY, storyW, storyBoxH
  local codeX, codeY, codeW, codeBoxH
  local faceX, faceY, faceH, nameW

  if PORT then
    storyX, storyY = pad, bodyY
    storyW = W - pad * 2
    local textWGuess = storyW - 114
    local _, lines = storyF:getWrap(story, textWGuess)
    local msgLines = 0
    local msgText = self:msgText()
    if msgText ~= "" then
      local _, ml = storyF:getWrap(msgText, textWGuess)
      msgLines = #ml
    end
    local need = 20 + nameF:getHeight() + 8 + (#lines + msgLines) * storyHgt + 12
    faceH = math.min(88, math.floor(bodyH * 0.20))
    storyBoxH = math.max(faceH + 16, math.min(math.floor(bodyH * 0.45), need))
    local hintY = storyY + storyBoxH + 4
    codeX, codeY = pad, hintY + hintH + (hintH > 0 and 4 or 0)
    codeW, codeBoxH = W - pad * 2, math.max(80, promptY - codeY - 6)
    faceX, faceY, nameW = storyX + 48, storyY + faceH - 6, 96
  else
    storyX, storyY = pad, bodyY
    storyW = math.floor(W * 0.42)
    storyBoxH = bodyH
    codeX = storyX + storyW + 8
    codeY = bodyY
    codeW = W - codeX - pad
    codeBoxH = bodyH
    faceH = math.min(120, storyBoxH - 40)
    faceX, faceY, nameW = storyX + 56, storyY + faceH - 4, 108
  end

  UI.panel(storyX, storyY, storyW, storyBoxH, Theme.panel)
  sprites.draw(face, faceX, faceY, { t = self.t, h = faceH, facing = 1 })
  love.graphics.setFont(nameF)
  setC(Theme.brick)
  local textX = storyX + (PORT and 100 or 118)
  local textW = math.max(40, storyX + storyW - textX - 14)
  local nameY = PORT and (storyY + 10) or (storyY + faceH + 2)
  love.graphics.printf(
    P(m.speaker),
    PORT and textX or (storyX + 6),
    nameY,
    PORT and textW or nameW,
    PORT and "left" or "center"
  )
  local textY = PORT and (nameY + nameF:getHeight() + 4) or (storyY + 14)
  local innerY = textY
  local innerH = storyY + storyBoxH - innerY - 10 - (PORT and 0 or hintH)
  -- clip to whole text lines so nothing is cut in half
  innerH = math.max(storyHgt, math.floor(innerH / storyHgt) * storyHgt)
  local sx, sy, sw, sh = clip(textX, innerY, textW, math.max(8, innerH))
  -- feedback first (it is what just happened), then the street's story
  love.graphics.setFont(storyF)
  local usedH = 0
  local msg = self:msgText()
  if msg ~= "" then
    if self.msgKind == "ok" then
      setC(Theme.admit)
    elseif self.msgKind == "bad" then
      setC(Theme.red)
    else
      setC(Theme.ink)
    end
    love.graphics.printf(msg, textX, textY, textW, "left")
    local _, msgLines = storyF:getWrap(msg, textW)
    usedH = #msgLines * storyHgt + 8
  end
  setC(Theme.ink, msg ~= "" and 0.75 or 1)
  love.graphics.printf(story, textX, textY + usedH, textW, "left")
  unclip(sx, sy, sw, sh)

  if self.hintOn then
    local hk = ease.expOut(self.hintK)
    local hx, hy, hw
    if PORT then
      hx, hy, hw = pad, storyY + storyBoxH + 4, W - pad * 2
    else
      hx, hy, hw = storyX + 8, storyY + storyBoxH - hintH - 8, storyW - 16
    end
    love.graphics.push()
    love.graphics.translate((1 - hk) * 24, 0)
    UI.panel(hx, hy, hw, hintH, Theme.coin)
    local hsx, hsy, hsw, hsh = clip(hx + 8, hy + 4, hw - 16, hintH - 8)
    love.graphics.setFont(fontOf("ui"))
    setC(Theme.ink)
    love.graphics.print(hintText, hx + 14, hy + 10)
    love.graphics.setFont(nameF)
    setC(Theme.ink, 0.9)
    love.graphics.printf(hintWhy, hx + 14, hy + 10 + fontOf("ui"):getHeight() + 6, hw - 28, "left")
    unclip(hsx, hsy, hsw, hsh)
    love.graphics.pop()
  end

  UI.well(codeX, codeY, codeW, codeBoxH)
  love.graphics.setFont(fontOf("ui"))
  setC(Theme.coin)
  local nStages = #m.stages
  local head = st.topic or "CODE"
  if nStages > 1 then
    head = string.format("%s  %d/%d", head, math.min(self.stage, nStages), nStages)
  end
  love.graphics.print(head, codeX + 14, codeY + 8)
  local wrapW = codeW - 28
  local cy = codeY + 12 + fontOf("ui"):getHeight()
  local avail = codeY + codeBoxH - cy - 8
  local codeLines = {}
  for line in (rendered .. "\n"):gmatch("(.-)\n") do
    codeLines[#codeLines + 1] = line
  end
  -- translated comments can be wide: drop to the small code font when the
  -- block would not fit
  local function needed(f)
    local h = 0
    for _, line in ipairs(codeLines) do
      local _, wrapped = f:getWrap(line, wrapW)
      h = h + math.max(1, #wrapped) * (f:getHeight() + 2)
    end
    return h
  end
  if needed(codeF) > avail and fontOf("codeSm") ~= codeF then
    codeF = fontOf("codeSm")
  end
  local lh = codeF:getHeight() + 2
  love.graphics.setFont(codeF)
  local csx, csy, csw, csh = clip(codeX + 8, cy, codeW - 16, math.max(8, avail))
  local commentCol = { 0.50, 0.82, 0.42, 1 }
  for li, line in ipairs(codeLines) do
    local blankLine = orig[li] and orig[li]:find("___", 1, true)
    local codeCol
    if blankLine then
      if self.solved then
        codeCol = Theme.admit
      else
        local pulse = 0.65 + 0.35 * (0.5 + 0.5 * math.cos(self.t * 6))
        codeCol = { Theme.coin[1], Theme.coin[2], Theme.coin[3], pulse }
      end
    else
      codeCol = { 0.92, 0.96, 0.78, 1 }
    end
    local _, wrapped = codeF:getWrap(line, wrapW)
    if line:match("^%s*#") then
      setC(commentCol)
      love.graphics.printf(line, codeX + 14, cy, wrapW, "left")
    else
      -- trailing "# what this variable means" in comment green
      local head, tail = line:match("^(.-%S)(%s+#.*)$")
      if head and #wrapped == 1 then
        setC(codeCol)
        love.graphics.print(head, codeX + 14, cy)
        setC(commentCol)
        love.graphics.print(tail, codeX + 14 + codeF:getWidth(head), cy)
      else
        setC(codeCol)
        love.graphics.printf(line, codeX + 14, cy, wrapW, "left")
      end
    end
    cy = cy + math.max(1, #wrapped) * lh
    if cy > codeY + codeBoxH - 8 then
      break
    end
  end
  unclip(csx, csy, csw, csh)

  -- question bar
  UI.well(pad, qY, W - pad * 2, qBarH, { 0.10, 0.08, 0.20, 1 })
  love.graphics.setFont(qF)
  if self.solved then
    setC(Theme.admit)
  else
    setC(Theme.coin)
  end
  love.graphics.printf(question, pad + 14, qY + 7, qW, "left")

  UI.well(pad, promptY, W - pad * 2, promptH, { 0.08, 0.06, 0.14, 1 })
  love.graphics.setFont(codeF)
  setC(Theme.coin)
  local py = promptY + math.floor((promptH - codeHgt) * 0.5)
  love.graphics.print(">", pad + 14, py)
  local caret = (math.sin(self.t * 8) > 0) and "_" or " "
  local typed
  if self.solved then
    setC(Theme.admit)
    typed = T("clear_prompt")
  elseif self.input == "" then
    setC(Theme.cream, 0.55)
    typed = T("type_answer") .. caret
  else
    setC(Theme.cream)
    typed = self.input .. caret
  end
  local psx, psy, psw, psh = clip(pad + 42, promptY, W - pad * 2 - 140, promptH)
  love.graphics.print(typed, pad + 42, py)
  unclip(psx, psy, psw, psh)
  if not self.solved then
    setC(Theme.coin)
    love.graphics.printf("ENTER", pad, py, W - pad * 2 - 14, "right")
  end

  local btnH = math.max(36, fontOf("button"):getHeight() + 14)
  local btnY = H - helpH + math.floor((helpH - btnH) * 0.5)
  local btnW = math.max(110, fontOf("button"):getWidth("NEXT") + 28)
  self.actHint = { pad, btnY, btnW, btnH }
  self.actOk = { pad + btnW + 10, btnY, btnW, btnH }
  self.actNext = self.actOk
  local hintLabel = ({ [0] = T("hint"), T("answer"), T("hide") })[self.hintLevel] or T("hint")
  self:pixBtn(self.actHint[1], self.actHint[2], self.actHint[3], self.actHint[4], hintLabel, self.hintOn)
  if self.solved then
    self:pixBtn(self.actNext[1], self.actNext[2], self.actNext[3], self.actNext[4], T("next"), true)
  else
    self:pixBtn(self.actOk[1], self.actOk[2], self.actOk[3], self.actOk[4], T("ok"))
  end
  love.graphics.setFont(helpF)
  setC(Theme.cream)
  local helpX = pad + btnW * 2 + 24
  local help = T("help_play")
  if self.solved then
    help = T("help_walk")
  elseif self.hintLevel == 1 then
    help = T("help_answer")
  end
  love.graphics.print(help, helpX, H - helpH + 4)
  love.graphics.pop()
end

function Game:drawWin()
  local k = ease.expOut(math.min(1, self.winT * 0.7))
  local smF = fontOf("small")
  local uiF = fontOf("ui")
  local mh, uh = smF:getHeight(), uiF:getHeight()
  -- recap panel: one lesson per street
  local pad = PORT and 12 or 24
  local innerW = W - pad * 2 - 28
  local lines = 0
  for i = 1, #maps do
    local _, wrapped = smF:getWrap(P(maps[i].lesson), innerW - 140)
    lines = lines + math.max(1, #wrapped)
  end
  local recapH = uh + 16 + lines * mh + #maps * 4 + mh + 24
  local recapY = H - recapH - 8
  local sceneH = recapY - 4

  local cam = self:drawBg("bg_store", 0, 0, W, sceneH, "win")
  local gy = cam.groundY
  local ch = math.min(cam.charH, sceneH * 0.5)
  local gap = ch * 0.72

  love.graphics.push()
  love.graphics.translate(W * 0.5, PORT and 70 or 52)
  love.graphics.rotate(-0.08)
  love.graphics.scale(k)
  sprites.item("stamp_admit", 0, 0, 2.2, -0.1)
  love.graphics.setFont(assets.font.stamp)
  love.graphics.setColor(Theme.admit[1], Theme.admit[2], Theme.admit[3], k)
  love.graphics.printf("ADMIT", -80, 18, 160, "center")
  love.graphics.pop()

  local subY = PORT and 118 or 96
  love.graphics.setColor(0.02, 0.02, 0.10, 0.55 * k)
  love.graphics.rectangle("fill", 0, subY - 6, W, assets.font.subtitle:getHeight() + 12)
  love.graphics.setFont(assets.font.subtitle)
  setC(COL.cream, k)
  love.graphics.printf(T("win_title"), 0, subY, W, "center")

  sprites.draw("hero", W * 0.22, gy, { t = self.t, bounce = math.abs(math.sin(self.t * 4)) * 8 * k, h = ch })
  sprites.draw(
    "mei",
    W * 0.22 + gap,
    gy,
    { t = self.t + 0.3, bounce = math.abs(math.sin(self.t * 4 + 1)) * 10 * k, h = ch }
  )
  sprites.draw(
    "ken",
    W * 0.22 + gap * 1.9,
    gy,
    { t = self.t + 0.7, bounce = math.abs(math.sin(self.t * 4 + 2)) * 9 * k, h = ch }
  )
  sprites.draw("clerk", W * 0.78, gy, { t = self.t, facing = -1, h = ch })
  sprites.item("item_beer", W * 0.90, gy - ch * 0.28, ch * 0.40, math.sin(self.t * 2) * 0.08)

  UI.panel(pad, recapY, W - pad * 2, recapH, Theme.panel)
  love.graphics.setFont(uiF)
  setC(Theme.ink, k)
  love.graphics.print(T("win_head"), pad + 14, recapY + 12)
  local y = recapY + 12 + uh + 10
  love.graphics.setFont(smF)
  for i = 1, #maps do
    local m = maps[i]
    setC(Theme.brick, k)
    love.graphics.print(m.station, pad + 14, y)
    setC(Theme.ink, k)
    love.graphics.printf(P(m.lesson), pad + 140, y, innerW - 140, "left")
    local _, wrapped = smF:getWrap(P(m.lesson), innerW - 140)
    y = y + math.max(1, #wrapped) * mh + 4
  end
  local blink = 0.55 + 0.45 * (0.5 + 0.5 * math.cos(self.t * 3))
  love.graphics.setFont(smF)
  love.graphics.setColor(Theme.ink[1], Theme.ink[2], Theme.ink[3], blink * k)
  love.graphics.printf(T("win_help"), pad, recapY + recapH - mh - 10, W - pad * 2, "center")
end

-- ---------------------------------------------------------------- input

local function digitKey(key)
  local n = tonumber(key) or tonumber(key:match("^kp(%d)$") or "")
  if n and n >= 1 and n <= #maps then
    return n
  end
  return nil
end

function Game:keypressed(key)
  local st = self.state

  -- F2 / MAP: open the street picker, or close it again.
  if key == "f2" then
    if st == "map" then
      self:leaveMap()
    else
      self:enterMap(st)
    end
    return
  end

  if st == "title" then
    if key == "return" or key == "space" or key == "kpenter" then
      self:enterMap("title")
    elseif key == "c" then
      self:continue()
    elseif key == "m" then
      self:enterMap("title")
    elseif key == "escape" then
      love.event.quit()
    else
      local n = digitKey(key)
      if n then
        self:enterPlay(n)
      end
    end
    return
  end

  if st == "map" then
    if key == "escape" then
      self:leaveMap()
    elseif key == "left" or key == "up" or key == "a" or key == "w" or key == "h" or key == "k" then
      self.mapCursor = (self.mapCursor - 2) % #maps + 1
      SFX.play("move")
    elseif key == "right" or key == "down" or key == "d" or key == "s" or key == "l" or key == "j" then
      self.mapCursor = self.mapCursor % #maps + 1
      SFX.play("move")
    elseif key == "return" or key == "space" or key == "kpenter" then
      self:enterPlay(self.mapCursor)
    else
      local n = digitKey(key)
      if n then
        self:enterPlay(n)
      end
    end
    return
  end

  if st == "win" then
    if key == "return" or key == "space" or key == "kpenter" then
      self:enterMap("win")
    elseif key == "escape" then
      self:enterTitle()
    end
    return
  end

  -- play
  if key == "escape" then
    self:enterMap("play")
  elseif key == "backspace" then
    if #self.input > 0 then
      self.input = self.input:sub(1, -2)
      SFX.play("type")
    end
    self.idle = 0
  elseif key == "return" or key == "kpenter" then
    if self.solved then
      self:advance()
    else
      self:submit()
    end
  elseif key == "tab" then
    self:toggleHint()
  elseif self.solved and (key == "n" or key == "space") then
    self:advance()
  end
end

function Game:textinput(text)
  -- The key that moved us into play (a digit, ENTER, "c") also arrives here
  -- as text in the same event batch. Do not type it into the blank.
  if self.frame == self.swallowFrame then
    return
  end
  if self.state ~= "play" or self.solved then
    return
  end
  if text == "\t" or text == "\n" or text == "\r" then
    return
  end
  if #self.input < MAX_INPUT then
    self.input = self.input .. text
    self.idle = 0
    SFX.play("type")
  end
end

function Game:mousepressed(x, y, button)
  if button ~= 1 then
    return
  end
  local vx, vy = Layout.toVirtual(x, y)
  if not vx then
    return
  end
  if inRect(vx, vy, HUD.lang) then
    Layout.cycleLanguage()
    return
  end
  if inRect(vx, vy, HUD.map) then
    if self.state == "map" then
      self:leaveMap()
    else
      self:enterMap(self.state)
    end
    return
  end
  if inRect(vx, vy, HUD.full) then
    Layout.toggleFullscreen()
    return
  end
  if inRect(vx, vy, HUD.ori) then
    Layout.toggleOrientation()
    return
  end

  local st = self.state
  if st == "map" then
    for i, r in ipairs(self.mapHits) do
      if inRect(vx, vy, r) then
        self.mapCursor = i
        self:enterPlay(i)
        return
      end
    end
    return
  end

  if st == "title" then
    self:enterMap("title")
    return
  end

  if st == "win" then
    self:enterMap("win")
    return
  end

  -- play
  if inRect(vx, vy, self.actHint) then
    self:toggleHint()
    return
  end
  if self.solved and inRect(vx, vy, self.actNext) then
    self:advance()
    return
  end
  if (not self.solved) and inRect(vx, vy, self.actOk) then
    self:submit()
    return
  end
  for i, r in ipairs(self.stationHits) do
    if inRect(vx, vy, r) then
      if i ~= self.step then
        self:enterPlay(i)
      end
      return
    end
  end
  if inRect(vx, vy, self.mapBtn) then
    self:enterMap("play")
    return
  end
end

return Game
