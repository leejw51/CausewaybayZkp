local Assets = { img = {}, font = {}, box = {} }

local SPRITE = {
  sprite_hero = true,
  sprite_clerk = true,
  sprite_mei = true,
  sprite_officer = true,
  sprite_ken = true,
  item_beer = true,
  item_envelope = true,
  ui_coin = true,
  ui_star = true,
  ui_panel = true,
  ui_buttons = true,
  stamp_admit = true,
}

-- People share one logical grid so Mei/officer dots match Alex/Uncle Wing.
local CHAR = {
  sprite_hero = true,
  sprite_clerk = true,
  sprite_mei = true,
  sprite_officer = true,
  sprite_ken = true,
}
local CHAR_W, CHAR_H = 32, 48

-- UI chips stay small. Character sheets are packed, not blindly squashed.
local SIZE = {
  item_beer = { 128, 128 },
  item_envelope = { 128, 128 },
  ui_coin = { 48, 48 },
  ui_star = { 48, 48 },
  ui_panel = { 128, 96 },
  ui_buttons = { 128, 48 },
  stamp_admit = { 96, 96 },
}

local function knockout(data)
  local w, h = data:getWidth(), data:getHeight()
  local function isBg(x, y)
    if x < 0 or y < 0 or x >= w or y >= h then
      return false
    end
    local r, g, b, a = data:getPixel(x, y)
    if a < 0.12 then
      return true
    end
    -- magenta screen
    if r > 0.55 and b > 0.55 and g < 0.45 then
      return true
    end
    -- leftover lime
    if g > 0.62 and r < 0.50 and b < 0.50 then
      return true
    end
    return false
  end
  local seen, qx, qy, n, i = {}, {}, {}, 0, 1
  local function push(x, y)
    if x < 0 or y < 0 or x >= w or y >= h then
      return
    end
    local k = y * w + x
    if seen[k] or not isBg(x, y) then
      return
    end
    seen[k] = true
    n = n + 1
    qx[n], qy[n] = x, y
  end
  for x = 0, w - 1, 2 do
    push(x, 0)
    push(x, h - 1)
  end
  for y = 0, h - 1, 2 do
    push(0, y)
    push(w - 1, y)
  end
  while i <= n do
    local x, y = qx[i], qy[i]
    i = i + 1
    data:setPixel(x, y, 0, 0, 0, 0)
    push(x + 1, y)
    push(x - 1, y)
    push(x, y + 1)
    push(x, y - 1)
  end
end

local function measureBox(data)
  local w, h = data:getWidth(), data:getHeight()
  local minx, miny, maxx, maxy = w, h, 0, 0
  local found = false
  for y = 0, h - 1 do
    for x = 0, w - 1 do
      local _, _, _, a = data:getPixel(x, y)
      if a > 0.12 then
        found = true
        if x < minx then
          minx = x
        end
        if y < miny then
          miny = y
        end
        if x > maxx then
          maxx = x
        end
        if y > maxy then
          maxy = y
        end
      end
    end
  end
  if not found then
    return { cx = w * 0.5, feet = h, h = h }
  end
  return {
    cx = (minx + maxx) * 0.5,
    feet = maxy + 1,
    h = math.max(8, maxy - miny + 1),
    minx = minx,
    miny = miny,
    maxx = maxx,
    maxy = maxy,
  }
end

local function nearestScale(data, tw, th)
  tw, th = math.max(1, math.floor(tw)), math.max(1, math.floor(th))
  local sw, sh = data:getWidth(), data:getHeight()
  local out = love.image.newImageData(tw, th)
  out:mapPixel(function(x, y)
    local sx = math.min(sw - 1, math.floor(x * sw / tw))
    local sy = math.min(sh - 1, math.floor(y * sh / th))
    return data:getPixel(sx, sy)
  end)
  return out
end

local function cropOpaque(data, box)
  local w = math.max(1, math.floor(box.maxx - box.minx + 1))
  local h = math.max(1, math.floor(box.maxy - box.miny + 1))
  local x = math.max(0, math.floor(box.minx))
  local y = math.max(0, math.floor(box.miny))
  if x + w > data:getWidth() then
    w = data:getWidth() - x
  end
  if y + h > data:getHeight() then
    h = data:getHeight() - y
  end
  local out = love.image.newImageData(w, h)
  out:paste(data, 0, 0, x, y, w, h)
  return out
end

-- Fit every person onto the same 32x48 cell, feet on the bottom.
-- Screen dots then match because every sheet is the same logical size.
local function packCharacter(data)
  knockout(data)
  local box = measureBox(data)
  if not box.minx then
    return nearestScale(data, CHAR_W, CHAR_H), {
      cx = CHAR_W * 0.5,
      feet = CHAR_H,
      h = CHAR_H,
    }
  end
  local cropped = cropOpaque(data, box)
  local sw, sh = cropped:getWidth(), cropped:getHeight()
  local nh = CHAR_H
  local nw = math.max(1, math.floor(sw * nh / sh + 0.5))
  if nw > CHAR_W then
    nw = CHAR_W
    nh = math.max(1, math.floor(sh * nw / sw + 0.5))
    if nh > CHAR_H then
      nh = CHAR_H
    end
  end
  local fitted = nearestScale(cropped, nw, nh)
  local cell = love.image.newImageData(CHAR_W, CHAR_H)
  local ox = math.floor((CHAR_W - nw) * 0.5)
  local oy = CHAR_H - nh
  cell:paste(fitted, ox, oy, 0, 0, nw, nh)
  return cell, {
    cx = ox + nw * 0.5,
    feet = CHAR_H,
    h = CHAR_H,
  }
end

local PIXEL = {
  "assets/fonts/PressStart2P-Regular.ttf",
  "/System/Library/Fonts/Supplemental/Courier New Bold.ttf",
  "/Library/Fonts/Courier New Bold.ttf",
  "/System/Library/Fonts/Supplemental/Courier New.ttf",
}

local BODY = {
  "assets/fonts/VT323-Regular.ttf",
  "/System/Library/Fonts/Supplemental/Courier New Bold.ttf",
  "/Library/Fonts/Courier New Bold.ttf",
  "/System/Library/Fonts/Supplemental/Courier New.ttf",
}

local fontScaleKey = nil

local function tryFont(size, paths)
  size = math.max(8, math.floor(size + 0.5))
  local font
  for i = 1, #paths do
    local ok, f = pcall(love.graphics.newFont, paths[i], size)
    if ok and f then
      font = f
      break
    end
  end
  font = font or love.graphics.newFont(size)
  if font.setFilter then
    font:setFilter("nearest", "nearest")
  end
  return font
end

-- Press Start 2P is an 8px grid font; other sizes go blurry.
local function snap8(n)
  return math.max(8, math.floor(n / 8 + 0.5) * 8)
end

function Assets.ensureFonts(scale)
  scale = math.max(1, scale or 1)
  local key = math.floor(scale * 100 + 0.5)
  if fontScaleKey == key and Assets.font.ui then
    return
  end
  fontScaleKey = key
  local seen = {}
  for _, f in pairs(Assets.font) do
    if type(f) == "userdata" and f.release and not seen[f] then
      seen[f] = true
      f:release()
    end
  end
  local s = scale
  Assets.font.title = tryFont(snap8(40 * s), PIXEL)
  Assets.font.subtitle = tryFont(40 * s, BODY)
  Assets.font.ui = tryFont(snap8(16 * s), PIXEL)
  Assets.font.story = Assets.font.ui
  Assets.font.small = tryFont(30 * s, BODY)
  Assets.font.code = tryFont(28 * s, BODY)
  Assets.font.codeSm = Assets.font.code
  Assets.font.bubble = tryFont(30 * s, BODY)
  Assets.font.station = tryFont(snap8(16 * s), PIXEL)
  Assets.font.stationSm = tryFont(snap8(8 * s), PIXEL)
  Assets.font.button = tryFont(snap8(16 * s), PIXEL)
  Assets.font.stamp = tryFont(snap8(24 * s), PIXEL)
  Assets.font.help = tryFont(32 * s, BODY)
end

function Assets.load()
  love.graphics.setDefaultFilter("nearest", "nearest")
  local names = {
    "title_bg",
    "title_bg_p",
    "bg_street",
    "bg_store",
    "bg_store_p",
    "bg_office",
    "bg_bits",
    "bg_sigma",
    "bg_hash",
    "sprite_hero",
    "sprite_clerk",
    "sprite_mei",
    "sprite_officer",
    "item_beer",
    "item_envelope",
    "ui_coin",
    "ui_star",
    "ui_panel",
    "ui_buttons",
    "stamp_admit",
  }
  for i = 1, #names do
    local name = names[i]
    local path = "assets/" .. name .. ".png"
    if love.filesystem.getInfo(path) then
      local data = love.image.newImageData(path)
      local packed = false
      if CHAR[name] then
        data, Assets.box[name] = packCharacter(data)
        packed = true
      else
        local sz = SIZE[name]
        if sz then
          data = nearestScale(data, sz[1], sz[2])
        end
        if SPRITE[name] then
          knockout(data)
        end
        if SPRITE[name] then
          Assets.box[name] = measureBox(data)
        end
      end
      local img = love.graphics.newImage(data)
      if SPRITE[name] or packed then
        img:setFilter("nearest", "nearest")
      else
        img:setFilter("linear", "linear")
      end
      Assets.img[name] = img
    end
  end

  Assets.ensureFonts(1)
end

function Assets.picture(name, portrait)
  if portrait then
    local p = Assets.img[name .. "_p"]
    if p then
      return p
    end
  end
  return Assets.img[name]
end

return Assets
