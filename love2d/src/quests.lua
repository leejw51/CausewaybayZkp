-- The two quests. Each is one kind of zero-knowledge proof, told as seven
-- streets of Causeway Bay:
--
--   1  sigma   GATE 18   "age >= 18" with a hand-made Sigma protocol
--                        (python/zkp: Pedersen + Schnorr + Fiat-Shamir)
--   2  snark   PUZZLE    "I solved the 4x4 puzzle" with a real zk-SNARK
--                        (rust/: Groth16 on BN254 via arkworks, reached
--                        from the game over ffi)
--
-- A quest is { id, tag, station, name, goal, maps, win }. `name` and `goal`
-- are shown on the title and in the map's level box, so a player always
-- sees which kind of proof the open quest is about. `maps` is the
-- street list (src/data.lua, src/data_snark.lua) and `win` says how the
-- stamp screen looks once every street of that quest is CLEAR.

-- Argument order matches I18n.LANGS; tests/test_flow.lua fails if a language
-- is missing.
local function L(en, ko, yue, zh, ja, cs, es)
  return { en = en, ko = ko, yue = yue, zh = zh, ja = ja, cs = cs, es = es }
end

local Quests = {
  {
    id = "sigma",
    tag = "Q1",
    station = "GATE 18",
    name = L(
      "GATE 18  -  Sigma protocol",
      "GATE 18  -  시그마 프로토콜",
      "GATE 18  -  Sigma 協議",
      "GATE 18  -  Sigma 协议",
      "GATE 18  -  シグマ・プロトコル",
      "GATE 18  -  Sigma protokol",
      "GATE 18  -  protocolo Sigma"
    ),
    goal = L(
      "Buy beer without showing your age. One ZKP built by hand, step by step.",
      "나이를 보여주지 않고 맥주 사기. 손으로 한 단계씩 만든 ZKP.",
      "唔使畀人睇年齡都買到啤酒。一步一步親手砌出嚟嘅 ZKP。",
      "不出示年龄就买到啤酒。一步一步亲手搭出来的 ZKP。",
      "年齢を見せずにビールを買う。手作りの ZKP を一歩ずつ。",
      "Kup pivo, aniž bys ukázal věk. Jedno ZKP postavené ručně, krok za krokem.",
      "Compra cerveza sin mostrar tu edad. Una ZKP hecha a mano, paso a paso."
    ),
    maps = require "src.data",
    win = { stamp = "ADMIT", bg = "bg_store", title = "win_title", head = "win_head" },
  },
  {
    id = "snark",
    tag = "Q2",
    station = "PUZZLE",
    name = L(
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK",
      "PUZZLE  -  zk-SNARK"
    ),
    goal = L(
      "Win the puzzle prize without showing the answer. A real Groth16 SNARK, running in Rust.",
      "답을 보여주지 않고 퍼즐 상품 타기. 러스트로 돌아가는 진짜 Groth16 SNARK.",
      "唔使畀人睇答案都攞到謎題獎品。用 Rust 行緊嘅真正 Groth16 SNARK。",
      "不出示答案就拿到谜题奖品。用 Rust 跑起来的真正 Groth16 SNARK。",
      "答えを見せずにパズルの賞品を取る。Rust で動く本物の Groth16 SNARK。",
      "Získej cenu za hlavolam, aniž bys ukázal řešení. Skutečný Groth16 SNARK, běžící v Rustu.",
      "Gana el premio del rompecabezas sin mostrar la respuesta. Un Groth16 SNARK real, corriendo en Rust."
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
