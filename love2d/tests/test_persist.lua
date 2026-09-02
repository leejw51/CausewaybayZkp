local Store = require "src.store"
local Persist = require "src.persist"

return function(t)
  t.describe("persist jsonl")

  local scratch = (os.getenv("TMPDIR") or "/tmp"):gsub("/+$", "") .. "/gate18-persist-test"

  t.it("writes event=setup once", function()
    os.execute(string.format('rm -rf "%s"', scratch))
    Store.use(scratch)
    local first, created = Persist.ensureSetup({ mode = "landscape", fullscreen = false })
    t.eq(created, true)
    t.eq(first.event, "setup")
    t.eq(first.app, "gate18")
    local again, created2 = Persist.ensureSetup()
    t.eq(created2, false)
    t.eq(again.event, "setup")
  end)

  t.it("display toggle is the last readable line", function()
    Store.use(scratch)
    Persist.saveDisplay({ mode = "portrait", fullscreen = true })
    local rec = Persist.loadDisplay()
    t.eq(rec.mode, "portrait")
    t.eq(rec.fullscreen, true)
  end)

  t.it("progress jsonl round-trips", function()
    Store.use(scratch)
    Persist.saveProgress({ state = "play", step = 3, stage = 2, solved = false })
    local rec = Persist.loadProgress()
    t.eq(rec.event, "progress")
    t.eq(rec.step, 3)
    t.eq(rec.stage, 2)
    t.eq(rec.solved, false)
  end)

  t.it("cleared map ids persist as a jsonl array", function()
    Store.use(scratch)
    Persist.saveProgress({
      state = "play",
      step = 4,
      stage = 1,
      solved = false,
      cleared = { "street", "mart", "office" },
    })
    local rec = Persist.loadProgress()
    t.eq(rec.cleared[1], "street")
    t.eq(rec.cleared[3], "office")
    local set = Persist.parseCleared(rec)
    t.eq(set.street, true)
    t.eq(set.mart, true)
    t.eq(set.office, true)
    t.eq(set.bits, nil)
  end)

  t.it("cleared set table is saved as a sorted id list", function()
    Store.use(scratch)
    Persist.saveProgress({
      state = "play",
      step = 2,
      stage = 1,
      solved = true,
      cleared = { mart = true, street = true },
    })
    local rec = Persist.loadProgress()
    t.eq(rec.cleared[1], "mart")
    t.eq(rec.cleared[2], "street")
  end)
end
