local BASE = (...):match('^(.*%.)[^.]+$')
local Assert = require(BASE .. 'assert')

---Utility functions
local Utils = {}

---@alias CopyMode "'shallow'"|"'deep'"

---Performs a shallow copy on a table.
---@param t table table to be copied
---@return table
local function shallow_copy(t)
  local copy = {}
  for k, v in pairs(t) do copy[k] = v end
  return copy
end

---Performs a deep copy on a table.
---@param t table table to be copied
---@return table
local function deep_copy(t)
  if type(t) ~= 'table' then return t end
  local copy = setmetatable({}, getmetatable(t))
  for k, v in pairs(t) do copy[k] = deep_copy(v) end
  return copy
end

---Returns a shallow or deep copy of a table. Internal metatables are preserved.
---@param t table table to be copied
---@param mode CopyMode copy mode
---@return table
function Utils.copy(t, mode)
  Assert.badarg(t, 1, 'Utils.copy', 'table')
  return mode == 'deep' and deep_copy(t) or shallow_copy(t)
end

---Merges table `src` into `dst`, creating new tables as necessary.
---@param dst table destination table
---@param src table source table
---@return table
local function merge(dst, src)
  for k, v in pairs(src) do
    if type(v) == 'table' then
      dst[k] = type(dst[k]) == 'table' and dst[k] or {}
      merge(dst[k], v)
    else
      dst[k] = v
    end
  end
  return dst
end

---Merges any number of tables. Latest tables take precedence.
---Internal metatables are not preserved. The resulting table and any subtables
---are all new tables, so they can be mutated freely without interfering with their
---original counterparts.
---@vararg table
---@return table
function Utils.merge(...)
  local merged = {}
  for i, t in ipairs({...}) do
    Assert.badarg(t, i, 'Utils.merge', 'table')
    merged = merge(merged, t)
  end
  return merged
end

return Utils
