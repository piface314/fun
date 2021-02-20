local BASE = (...):match('^(.*%.)[^.]+$')
local trans = require(BASE .. 'trans')
local act = require(BASE .. 'action')
local Assert = require(BASE .. 'assert')
local Utils = require(BASE .. 'utils')

---Adds functional style support to tables
---@class Fun
---@field bound table
---@field cache table
---@field trans thread
local Fun = {}
Fun.__index = Fun

local loads = loadstring or load

---Checks if a value is an instance of Fun
---@param v any
---@return boolean
function Fun.is(v) return type(v) == 'table' and getmetatable(v) == Fun end

---Transformation specific for the creation of a Fun object.
---Acts as the identity function (`function(x) return x end`).
---@param t table table whose values are returned
---@return thread
local function identity(t)
  return coroutine.create(function()
    for k, v in pairs(t) do coroutine.yield(k, v) end
  end)
end

---Creates a new Fun object by binding a table to it, optionally applying a transformation.
---@param t table the table to be bound
---@param transform? thread transformation to be applied
---@param copy? CopyMode if and how the table should be copied
---@return Fun
local function bind(t, transform, copy)
  Assert.badarg(t, 1, 'Fun.bind', 'table')
  t = copy and Utils.copy(t, copy) or t
  transform = transform or identity(t)
  return setmetatable({bound = t, trans = transform, cache = {}}, Fun)
end

---Creates a new Fun object by binding a table to it.
---@param t table the table to be bound
---@param copy? CopyMode if and how the table should be copied
---@return Fun
function Fun.bind(t, copy) return bind(t, nil, copy) end

---Parses a string into a one line function returning the given expression.
---The string must use this format: `params -> expression`, e.g. `x, y -> x + y`.
---A single "upvalue" can be passed an additional argument, and is referenced in
---the string with `_`. If the generated function contains an error, it will be thrown.
---@param s string defines the function
---@param upval? any arbitrary value that can be accessed inside the new function
---@return any
function Fun.strfn(s, upval)
  Assert.badarg(s, 1, 'Fun.strfn', 'string')
  local params, ret = s:match('^%s*(.-)%s*%->%s*(.*)$')
  assert(params, 'fun: malformed string function')
  local template = 'local _ = (...) return function(%s) return %s end'
  local fs = template:format(params, ret)
  local f, err = loads(fs)
  assert(f, 'fun: ' .. (err or ''))
  return f(upval)
end

---Saves return values of a function on a Fun object, like a generic for construct.
---@param f function function whose return values are stored
---@param o any object used in iteration
---@param v any starting value
---@return Fun
function Fun.gen(f, o, v)
  Assert.badarg(f, 1, 'Fun.gen', 'function')
  local gen = coroutine.create(function(f, o, v)
    coroutine.yield()
    local i = 0
    while true do
      local r = {f(o, v)}
      if r[1] == nil then break end
      i, v = i + 1, r[1]
      coroutine.yield(i, #r > 1 and r or r[1])
    end
  end)
  coroutine.resume(gen, f, o, st)
  return setmetatable({bound = nil, trans = gen, cache = {}}, Fun)
end

---Creates a list of numbers in the range `[a,b]`, using `step` as the difference
---between each consecutive term. `step` defaults to 1. If `b` is `nil`, the range
---becomes infinite.
---@param a number starting value
---@param b? number ending value
---@param step? number difference between consecutive terms
function Fun.range(a, b, step)
  Assert.badarg(a, 1, 'Fun.range', 'number')
  Assert.badarg(b, 2, 'Fun.range', 'number|nil')
  Assert.badarg(step, 3, 'Fun.range', 'number|nil')
  local range = coroutine.create(function(a, b, step)
    coroutine.yield()
    local i, n = 1, a
    if (b and b < a) or (step and step < 0) then
      a, b, step = b, a, step or -1
      while not a or a <= n do
        coroutine.yield(i, n)
        i, n = i + 1, n + step
      end
    else
      step = step or 1
      while not b or n <= b do
        coroutine.yield(i, n)
        i, n = i + 1, n + step
      end
    end
  end)
  coroutine.resume(range, a, b, step)
  return setmetatable({bound = nil, trans = range, cache = {}}, Fun)
end

---Computes the next element in the table, according to the applied transformation.
---If no more elements are left to be computed, returns `nil`.
---@return any key
---@return any value
function Fun:next()
  if coroutine.status(self.trans) == 'dead' then return nil end
  local ok, k, v = coroutine.resume(self.trans)
  assert(ok, 'fun: error in transformation: ' .. (k or ''))
  if k ~= nil then self.cache[k] = v end
  return k, v
end

for k, v in pairs(act) do Fun[k] = v end
for k, v in pairs(trans) do
  Fun[k] = function(self, ...) return bind(self, v(self, ...)) end
end

return Fun
