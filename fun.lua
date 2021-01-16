--- Adds functional style support for tables
--- @class Fun
local Fun = {}
Fun.__index = Fun

--- Binds a table to a Fun object
--- @param t table
--- @return Fun
local function bind(t) return setmetatable(t, Fun) end

--- Returns an empty Fun
--- @return Fun
local function new() return bind({}) end

--- Parses a string into a function. If the generated function contains an error, that
--- error will be thrown.
--- @param s string
--- @return function
local function strfn(s)
  local params, ret = s:match('%s*%(?(.-)%)?%s*%->%s*(.+)')
  local fs = ('return function(%s) return %s end'):format(params, ret)
  local f, err = load(fs)
  assert(f, err)
  return f()
end

--- Returns a shallow copy of the table
--- @return Fun
function Fun:copy()
  local out = new()
  for i, v in pairs(self) do out[i] = v end
  return out
end

--- Returns a deep copy of the table
--- @return Fun
function Fun:deepcopy()
  local function copy(t)
    if type(t) ~= 'table' then
      return t
    end
    local nt = setmetatable({}, getmetatable(t))
    for k, v in pairs(t) do
      nt[k] = copy(v)
    end
    return nt
  end
  return copy(self)
end

--- Maps each value in the table with function `f` into a new table.
--- `f` receives each value as the first argument, and each index as the second.
--- @param f function
--- @return Fun
function Fun:map(f)
  local out = new()
  for i, v in pairs(self) do
    out[i] = f(v, i)
  end
  return out
end

--- Filters and table into a new one containing only values that make `f` return `true`.
--- `f` receives each value as the first argument, and each index as the second.
--- If parameter `as_array` is provided, the table will be treated as an array if `true`,
--- or treated as a hash if `false`. If not provided, the table will be inferred as an
--- array if it contains an element at index `1`.
--- @param f function
--- @param as_array boolean
--- @return Fun
function Fun:filter(f, as_array)
  local out = new()
  if as_array == nil then as_array = self[1] ~= nil end
  for i, v in pairs(self) do
    if f(v, i) then
      out[as_array and (#out + 1) or i] = v
    end
  end
  return out
end

--- Reduces an table to a single value, according to a starting value `st`, and to a function `f`,
--- that receives an accumulator value and the first parameter and the current value as the second
--- @param st any
--- @param f function
--- @return any
function Fun:reduce(st, f)
  for _, v in pairs(self) do
    st = f(st, v)
  end
  return st
end

--- Executes function `fn` on each element of the table
--- @param fn function
function Fun:foreach(fn)
  for i, v in pairs(self) do
    fn(v, i)
  end
end

--- Inserts element `v` at the end of the table/array
--- @param v any
function Fun:push(v)
  self[#self+1] = v
end

--- Merges current table with any number of tables.
--- Latest tables take precedence
--- @return Fun
function Fun:merge(...)
  local function merge(dst, src)
    for k, v in pairs(src) do
      if type(v) == 'table' then
        dst[k] = type(dst[k]) == 'table' and dst[k] or {}
        merge(dst[k], v)
      else
        dst[k] = v
      end
    end
  end
  return bind({self, ...}):reduce({}, merge)
end

--- Sorts the table/array.
--- @return Fun
function Fun:sort()
  local a = self:copy()
  table.sort(a)
  return a
end

--- Returns an array with the table keys.
--- @return Fun
function Fun:keys()
  return self:map(strfn '_, k -> k')
end

--- Returns a string representation of the table, inferring if it's an array or hash
--- @return string
function Fun:__tostring()
  return self[1] == nil and self:hash_tostring() or self:array_tostring()
end

--- Returns a string representation of the table as an array
--- @return string
function Fun:array_tostring()
  local function str(v)
    return type(v) == 'string' and '"' .. v .. '"' or tostring(v)
  end
  return '[' .. table.concat(self:map(str), ', ') .. ']'
end

--- Returns a string representation of the table as a hash
--- @return string
function Fun:hash_tostring()
  local function str(v, k)
    return k .. ' = ' .. (type(v) == 'string' and '"' .. v .. '"' or tostring(v))
  end
  local s = self:map(str):reduce('', strfn 'a,b -> a..", "..b'):sub(3, -2)
  return '{' .. s .. '}'
end

--- Concatenates two arrays into a new one (Values can be either plain tables or `Fun` objects).
--- Only works on arrays.
--- @param a Fun|table
--- @param b Fun|table
--- @return Fun
function Fun.__concat(a, b)
  local a_t, b_t = type(a), type(b)
  assert(a_t == 'table' and a_t == b_t,
         'attempt to concat a `Fun` value with a non-table value')
  local t = {}
  for _, v in ipairs(a) do t[#t + 1] = v end
  for _, v in ipairs(b) do t[#t + 1] = v end
  return bind(t)
end

--- If `p` is a string, parses that string into a function defined by that string.
--- If `p` is a table, makes `p` an instance of `Fun`
---@param p string|table
---@return Fun
return function(p)
  if type(p) == 'string' then
    return strfn(p)
  else
    return bind(p)
  end
end
