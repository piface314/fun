local BASE = (...):match('^(.*%.)[^.]+$') or (...) .. '.'
local Fun = require(BASE .. 'core')
local Assert = require(BASE .. 'assert')

local constructors = {
  ['table'] = Fun.bind,
  ['string'] = Fun.strfn,
  ['function'] = Fun.gen,
  ['number'] = Fun.range
}

---Infers how a Fun object (or function) should be created.
---If `v` is a table, binds `v` in a `Fun` object.
---If `v` is a string, parses that string into a function defined by that string.
---If `v` is a function, that function is treated as a generator.
---If `v` is a number, uses that number and its following argument(s) to form a range of numbers.
---@param v table|string|function|number
---@return Fun
local function fun(v, ...)
  Assert.badarg(v, 1, 'fun', 'table|string|function|number')
  local cons = constructors[type(v)]
  return cons(v, ...)
end

return fun
