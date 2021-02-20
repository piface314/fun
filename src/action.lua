local BASE = (...):match('^(.*%.)[^.]+$')
local Assert = require(BASE .. 'assert')

local Fun = {}

---Same as tostring, but if `v` is a string, uses quote format.
---@param v any value to be turned into a string
---@return string
local function str(v) return (type(v) == 'string' and '%q' or '%s'):format(v) end

---Returns a string representation of the bound table in a Fun object.
---@return string
function Fun:__tostring()
  while self:next() do end
  local ta, th = {}, {}
  for i, v in ipairs(self.cache) do ta[i] = str(v) end
  for k, v in pairs(self.cache) do
    if not ta[k] then th[#th + 1] = tostring(k) .. ' = ' .. str(v) end
  end
  local sa = #ta > 0 and table.concat(ta, ', ')
  local sh = #th > 0 and table.concat(th, ', ')
  return ('{%s%s%s}'):format(sa or '', sa and sh and '; ' or '', sh or  '')
end

---Returns in a table every element contained in the object.
---@return table
function Fun:get()
  local out = {}
  for k, v in pairs(self.cache) do out[k] = v end
  while true do
    local k, v = self:next()
    if k == nil then return out end
    out[k] = v
  end
end

---Reduces the bound table to a single value, according to a starting value `st` and a function `f`.
---That function receives an accumulator in the first parameter and the current value as the second.
---@generic A
---@param st A starting value
---@param f fun(acc: A, val: any): A function that process each value into a single one
---@return A
function Fun:reduce(st, f)
  Assert.badarg(f, 2, 'Fun:reduce', 'function')
  for _, v in pairs(self.cache) do st = f(st, v) end
  while true do
    local k, v = self:next()
    if k == nil then return st end
    st = f(st, v)
  end
end

---Runs function `f` over each element of the bound table.
---@param f fun(val: any, key: any)
function Fun:foreach(f)
  Assert.badarg(f, 1, 'Fun:foreach', 'function')
  for k, v in pairs(self.cache) do f(v, k) end
  while true do
    local k, v = self:next()
    if k == nil then return end
    f(v, k)
  end
end

---Returns the first element that makes `f` return `true`, along with its key.
---If none is found, returns `nil`.
---@param f function tester function
---@return any value
---@return any key
function Fun:find(f)
  Assert.badarg(f, 1, 'Fun:find', 'function')
  for k, v in pairs(self.cache) do if f(v, k) then return v, k end end
  while true do
    local k, v = self:next()
    if k == nil then return nil end
    if f(v, k) then return v, k end
  end
end

---Returns the bound table length/size, as if it was a normal table and `#t` was used.
---A shortcut to `#self:get()`.
---@return number
function Fun:len() return #self:get() end

---Returns the total amount of elements in the bound table, including the ones in
---non-numeric keys.
---@return number
function Fun:size()
  local n = 0
  self:foreach(function() n = n + 1 end)
  return n
end

Fun.__len = Fun.len
Fun.__pairs = Fun.foreach

return Fun
