--- Predefined assert messages
local Assert = {}

---Asserts if an argument was not of an expected type.
---@param v any value passed as argument
---@param i number argument index number
---@param fn string function name
---@param exp string expected type
function Assert.badarg(v, i, fn, exp)
  local type_v = type(v)
  for t in exp:gmatch '%w+' do if type_v == t then return end end
  local msg = 'fun: bad argument #%d to %s (expected %s, got %s)'
  error(msg:format(i, fn, exp, type_v))
end

return Assert
