-- Quest 2's real zk-SNARK, reached over LuaJIT's ffi.
--
-- The Rust crate in ../rust builds libgate18_snark (dylib / so / dll) with a
-- C ABI: JSON strings in, JSON strings out (see rust/src/ffi.rs). This
-- module finds the library, decodes the JSON, and never throws: when the
-- library is not built the game still runs, the PROOF street just says so.
--
--   Snark.available()          true when the library loaded
--   Snark.status()             "ok" | "missing" | "error: ..."
--   Snark.demo()               { clues = {16}, solution = {16}, constraints }
--   Snark.info()               circuit + key facts (runs the setup once)
--   Snark.prove(clues, sol)    Mei's side: returns the Report (proof + verdict)
--   Snark.verify(clues, proof) Uncle Wing's side: Report with ok / reason
--
-- A Report is the Rust `api::Report` as a Lua table: ok, verdict, reason,
-- constraints, public_inputs, variables, proof = { a, b, c, bytes },
-- vk_bytes, pk_bytes, vk_id, pairings, ms = { setup, prove, verify }.

local Json = require "src.json"

local Snark = {}

-- The demo board, duplicated from rust/src/sudoku.rs so the streets can draw
-- it without the library. tests/test_snark.lua checks the two agree.
Snark.DEMO = {
  clues = { 1, 0, 0, 4, 0, 4, 1, 0, 0, 1, 4, 0, 4, 0, 0, 1 },
  solution = { 1, 2, 3, 4, 3, 4, 1, 2, 2, 1, 4, 3, 4, 3, 2, 1 },
  constraints = 112,
}

local CDEF = [[
const char* gate18_snark_version(void);
char* gate18_snark_demo(void);
char* gate18_snark_info(void);
char* gate18_snark_prove(const char* clues, const char* solution);
char* gate18_snark_verify(const char* clues, const char* proof);
void gate18_snark_free(char* p);
]]

local ffi -- LuaJIT ffi module, nil when unavailable
local lib -- the loaded library, nil until loaded
local status = "unloaded"
local libPath

local function sourceDir()
  if love and love.filesystem and love.filesystem.getSource then
    local src = love.filesystem.getSource()
    if src and src ~= "" then
      return src
    end
  end
  return "."
end

-- The directory holding the running executable, asked of the operating system.
--
-- A double-clicked .app inherits no environment and its source is a .love
-- archive inside the bundle, so neither GATE18_SNARK_LIB nor sourceDir() can
-- reach Contents/Frameworks — where a signed bundle has to keep the library,
-- because that is the only place codesign will accept a nested Mach-O. This is
-- how the packaged game finds its own library rather than a stale build.
local function executableDir()
  local ok, mod = pcall(require, "ffi")
  if not ok then
    return nil
  end
  local okDecl = pcall(
    mod.cdef,
    [[int _NSGetExecutablePath(char* buf, unsigned int* bufsize);]]
  )
  if not okDecl then
    return nil
  end
  local okCall, dir = pcall(function()
    local size = mod.new("unsigned int[1]", 4096)
    local buf = mod.new("char[?]", 4096)
    if mod.C._NSGetExecutablePath(buf, size) ~= 0 then
      return nil
    end
    return mod.string(buf):match("^(.*)/[^/]*$")
  end)
  if okCall then
    return dir
  end
  return nil
end

-- Where to look, in order. The env var wins so a packaged build can point
-- anywhere; then the bundle the game is running from, then the cargo output
-- next to a checkout. Tests replace this.
function Snark.candidates()
  local list = {}
  local env = os.getenv("GATE18_SNARK_LIB")
  if env and env ~= "" then
    list[#list + 1] = env
  end
  local names = { "libgate18_snark.dylib", "libgate18_snark.so", "gate18_snark.dll" }
  local dirs = {}
  local exe = executableDir()
  if exe then
    -- Contents/MacOS/love -> Contents/Frameworks, and beside the executable
    -- for a plain directory layout.
    dirs[#dirs + 1] = exe .. "/../Frameworks"
    dirs[#dirs + 1] = exe
  end
  local base = sourceDir()
  dirs[#dirs + 1] = base .. "/lib"
  dirs[#dirs + 1] = base .. "/Contents/Frameworks"
  dirs[#dirs + 1] = base .. "/../rust/target/release"
  dirs[#dirs + 1] = base .. "/../rust/target/debug"
  for _, dir in ipairs(dirs) do
    for _, n in ipairs(names) do
      list[#list + 1] = dir .. "/" .. n
    end
  end
  return list
end

local function load()
  if status ~= "unloaded" then
    return lib ~= nil
  end
  local ok, mod = pcall(require, "ffi")
  if not ok then
    status = "error: no ffi (not LuaJIT)"
    return false
  end
  ffi = mod
  local okDef, err = pcall(ffi.cdef, CDEF)
  if not okDef then
    status = "error: cdef " .. tostring(err)
    return false
  end
  local lastErr
  for _, path in ipairs(Snark.candidates()) do
    local okLoad, handle = pcall(ffi.load, path)
    if okLoad then
      lib = handle
      libPath = path
      status = "ok"
      return true
    end
    lastErr = handle
  end
  status = "missing"
  Snark.lastError = lastErr
  return false
end

-- Take a string the library allocated, free it, decode the JSON.
local function take(ptr)
  if ptr == nil then
    return nil, "library returned NULL"
  end
  local s = ffi.string(ptr)
  lib.gate18_snark_free(ptr)
  local ok, value = pcall(Json.decode, s)
  if not ok or type(value) ~= "table" then
    return nil, "bad JSON from library: " .. s:sub(1, 80)
  end
  return value
end

local function board(t)
  if type(t) ~= "table" or #t ~= 16 then
    return nil, "a board is a list of 16 numbers"
  end
  return Json.encode(t)
end

function Snark.available()
  return load()
end

function Snark.status()
  load()
  return status
end

function Snark.libPath()
  load()
  return libPath
end

function Snark.version()
  if not load() then
    return nil
  end
  return ffi.string(lib.gate18_snark_version())
end

function Snark.demo()
  if not load() then
    return nil, status
  end
  return take(lib.gate18_snark_demo())
end

function Snark.info()
  if not load() then
    return nil, status
  end
  return take(lib.gate18_snark_info())
end

function Snark.prove(clues, solution)
  if not load() then
    return nil, status
  end
  local c, errC = board(clues)
  if not c then
    return nil, errC
  end
  local s, errS = board(solution)
  if not s then
    return nil, errS
  end
  return take(lib.gate18_snark_prove(c, s))
end

-- proof: the { a, b, c } table from a prove() Report
function Snark.verify(clues, proof)
  if not load() then
    return nil, status
  end
  local c, errC = board(clues)
  if not c then
    return nil, errC
  end
  if type(proof) ~= "table" or not (proof.a and proof.b and proof.c) then
    return nil, "a proof is { a, b, c } hex"
  end
  return take(lib.gate18_snark_verify(c, Json.encode({ a = proof.a, b = proof.b, c = proof.c })))
end

-- Tests: forget the loaded library so the search runs again.
function Snark.reset()
  lib, libPath, status = nil, nil, "unloaded"
end

return Snark
