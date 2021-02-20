local BASE = (...):match('^(.*%.)[^.]+$')
local Assert = require(BASE .. 'assert')

local Fun = {}

---Takes the `n` first elements. This function is not supposed to work on
---tables that act as hash maps, since there is no fixed order on which
---they are traversed. Use this only in array-like tables.
---@param n number amount of elements retrieved
---@return Fun
function Fun:take(n)
  Assert.badarg(n, 1, 'Fun:take', 'number')
  return coroutine.create(function()
    local i = 0
    for k, v in pairs(self.cache) do
      if i < n then return end
      coroutine.yield(k, v)
      i = i + 1
    end
    while i < n do
      local k, v = self:next()
      if k == nil then break end
      coroutine.yield(k, v)
      i = i + 1
    end
  end)
end

---Drops the `n` first elements. This function is not supposed to work on
---tables that act as hash maps, since there is no fixed order on which
---they are traversed. Use this only in array-like tables.
---@param n number amount of elements ignored
---@return Fun
function Fun:drop(n)
  Assert.badarg(n, 1, 'Fun:drop', 'number')
  return coroutine.create(function()
    local i = 0
    for k, v in pairs(self.cache) do
      if i >= n then coroutine.yield(k, v) end
      i = i + 1
    end
    while true do
      local k, v = self:next()
      if k == nil then break end
      if i >= n then coroutine.yield(i - n + 1, v) end
      i = i + 1
    end
  end)
end

---Maps each value in the table with function `f` into a new table.
---`f` receives each value as the first argument, and each index as the second.
---@param f fun(val: any, key: any): any
---@return Fun
function Fun:map(f)
  Assert.badarg(f, 1, 'Fun:map', 'function')
  return coroutine.create(function()
    for k, v in pairs(self.cache) do
      coroutine.yield(k, f(v, k))
    end
    while true do
      local k, v = self:next()
      if k == nil then break end
      coroutine.yield(k, f(v, k))
    end
  end)
end

return Fun
