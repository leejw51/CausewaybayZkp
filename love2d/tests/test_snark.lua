-- The Rust SNARK over ffi. Two halves:
--   * without the library the game must keep working (status, nil returns)
--   * with it (cargo build --release in ../rust) a real prove + verify runs

local Snark = require "src.snark"

-- the puzzle rules in plain Lua, so the demo board is checked without Rust
local function lines()
  local out = {}
  for r = 0, 3 do
    out[#out + 1] = { r * 4 + 1, r * 4 + 2, r * 4 + 3, r * 4 + 4 }
  end
  for c = 1, 4 do
    out[#out + 1] = { c, c + 4, c + 8, c + 12 }
  end
  for br = 0, 1 do
    for bc = 0, 1 do
      local o = br * 8 + bc * 2 + 1
      out[#out + 1] = { o, o + 1, o + 4, o + 5 }
    end
  end
  return out
end

return function(t)
  t.describe("snark ffi")

  t.it("the demo board is a solved 4x4 sudoku that matches its clues", function()
    local d = Snark.DEMO
    t.eq(#d.clues, 16)
    t.eq(#d.solution, 16)
    for i = 1, 16 do
      t.ok(d.solution[i] >= 1 and d.solution[i] <= 4, "cell " .. i .. " in 1..4")
      t.ok(d.clues[i] == 0 or d.clues[i] == d.solution[i], "clue " .. i .. " matches")
    end
    for _, line in ipairs(lines()) do
      local sum, prod = 0, 1
      for _, i in ipairs(line) do
        sum = sum + d.solution[i]
        prod = prod * d.solution[i]
      end
      t.eq(sum, 10)
      t.eq(prod, 24)
    end
    t.eq(d.constraints, 16 + 16 * 3 + 12 * 4)
  end)

  t.it("without the library nothing throws and everything says why", function()
    local real = Snark.candidates
    Snark.candidates = function()
      return { "/nonexistent/libgate18_snark.so" }
    end
    Snark.reset()
    t.eq(Snark.available(), false)
    t.eq(Snark.status(), "missing")
    local r, err = Snark.prove(Snark.DEMO.clues, Snark.DEMO.solution)
    t.eq(r, nil)
    t.eq(err, "missing")
    t.eq(Snark.demo(), nil)
    Snark.candidates = real
    Snark.reset()
  end)

  t.it("bad boards are refused before the ffi call", function()
    local _, err = Snark.prove({ 1, 2, 3 }, Snark.DEMO.solution)
    t.has(err, "16 numbers")
  end)

  if not Snark.available() then
    print("        (library not built: cd rust && cargo build --release; live checks skipped)")
    return
  end

  t.it("the Rust demo board is the Lua one", function()
    local d = Snark.demo()
    t.ok(d, "demo")
    for i = 1, 16 do
      t.eq(d.clues[i], Snark.DEMO.clues[i], "clue " .. i)
      t.eq(d.solution[i], Snark.DEMO.solution[i], "solution " .. i)
    end
    t.eq(d.constraints, Snark.DEMO.constraints)
  end)

  t.it("prove then verify: 3 points, 128 bytes, ACCEPT", function()
    local r = Snark.prove(Snark.DEMO.clues, Snark.DEMO.solution)
    t.ok(r, "report")
    t.eq(r.ok, true, r.reason)
    t.eq(r.verdict, "ACCEPT")
    t.eq(r.proof.bytes, 128)
    t.eq(#r.proof.a, 64, "A is 32 bytes of hex")
    t.eq(#r.proof.b, 128, "B is 64 bytes of hex")
    t.eq(#r.proof.c, 64, "C is 32 bytes of hex")
    t.eq(r.constraints, 112)
    t.eq(r.public_inputs, 16)
    t.eq(r.pairings, 4)
    local v = Snark.verify(Snark.DEMO.clues, r.proof)
    t.eq(v.ok, true, "the verifier alone, from clues + proof")
  end)

  t.it("a wrong solution or other clues are rejected", function()
    local bad = { unpack(Snark.DEMO.solution) }
    bad[6] = 2
    local r = Snark.prove(Snark.DEMO.clues, bad)
    t.eq(r.ok, false)
    t.eq(r.verdict, "REJECT")
    local good = Snark.prove(Snark.DEMO.clues, Snark.DEMO.solution)
    local other = { unpack(Snark.DEMO.clues) }
    other[2] = 3
    local v = Snark.verify(other, good.proof)
    t.eq(v.ok, false, "a proof is bound to its clues")
  end)
end
