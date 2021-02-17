local Fun = {}

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

return Fun
