local Fun = {}

---Maps each value in the table with function `f` into a new table.
---`f` receives each value as the first argument, and each index as the second.
---@param f fun(val: any, key: any): any
---@return Fun
function Fun:map(f)
  local trans = coroutine.create(function(self, f)
    coroutine.yield()
    for k, v in pairs(self.cache) do
      coroutine.yield(k, f(v, k))
    end
    while true do
      local k, v = self:next()
      if k == nil then break end
      coroutine.yield(k, f(v, k))
    end
  end)
  coroutine.resume(trans, self, f)
  return trans
end

return Fun
