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

---Checks if a value is an instance of Fun
---@param v any
---@return boolean
function Fun.is(v) return type(v) == 'table' and getmetatable(v) == Fun end

---Transformation specific for the creation of a Fun object.
---Acts as the identity function (`function(x) return x end`).
---@param t table table whose values are returned
---@return thread
local function identity(t)
  local id = coroutine.create(function(t)
    coroutine.yield()
    for k, v in pairs(t) do coroutine.yield(k, v) end
  end)
  coroutine.resume(id, t)
  return id
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
