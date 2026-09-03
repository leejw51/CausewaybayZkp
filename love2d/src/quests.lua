-- The two quests. Each is one kind of zero-knowledge proof, told as seven
-- streets of Causeway Bay:
--
--   1  sigma   GATE 18   "age >= 18" with a hand-made Sigma protocol
--                        (python/zkp: Pedersen + Schnorr + Fiat-Shamir)
--   2  snark   PUZZLE    "I solved the 4x4 puzzle" with a real zk-SNARK
--                        (rust/: Groth16 on BN254 via arkworks, reached
--                        from the game over ffi)
--
-- A quest is { id, tag, station, name, goal, maps, win }. `maps` is the
-- street list (src/data.lua, src/data_snark.lua) and `win` says how the
-- stamp screen looks once every street of that quest is CLEAR.

local function L(en, ko, yue)
  return { en = en, ko = ko, yue = yue }
end

local Quests = {
  {
    id = "sigma",
    tag = "Q1",
    station = "GATE 18",
    name = L("GATE 18  -  Sigma protocol", "GATE 18  -  시그마 프로토콜", "GATE 18  -  Sigma 協議"),
    goal = L(
      "Buy beer without showing your age. One ZKP built by hand, step by step.",
      "나이를 보여주지 않고 맥주 사기. 손으로 한 단계씩 만든 ZKP.",
      "唔使畀人睇年齡都買到啤酒。一步一步親手砌出嚟嘅 ZKP。"
    ),
    maps = require "src.data",
    win = { stamp = "ADMIT", bg = "bg_store", title = "win_title", head = "win_head" },
  },
  {
    id = "snark",
    tag = "Q2",
    station = "PUZZLE",
    name = L("PUZZLE  -  zk-SNARK", "PUZZLE  -  zk-SNARK", "PUZZLE  -  zk-SNARK"),
    goal = L(
      "Win the puzzle prize without showing the answer. A real Groth16 SNARK, running in Rust.",
      "답을 보여주지 않고 퍼즐 상품 타기. 러스트로 돌아가는 진짜 Groth16 SNARK.",
      "唔使畀人睇答案都攞到謎題獎品。用 Rust 行緊嘅真正 Groth16 SNARK。"
    ),
    maps = require "src.data_snark",
    win = { stamp = "SOLVED", bg = "bg_store", title = "win2_title", head = "win2_head" },
  },
}

-- Quest index of a street id, for progress records that only name the street.
function Quests.questOf(mapId)
  for q, quest in ipairs(Quests) do
    for _, m in ipairs(quest.maps) do
      if m.id == mapId then
        return q
      end
    end
  end
  return nil
end

return Quests
