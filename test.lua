local fun = require 'fun'

local function okay(...)
  io.write('\x1b[92m\x1b[1m[OK]\x1b[0m ', ...)
  io.write('\n')
end

local function fail(...)
  io.write('\x1b[91m\x1b[1m[X]\x1b[0m ', ...)
  io.write('\n')
end

local test = {}

function test.strfn()
  assert(fun '... -> ...', 'rest parameters')
  assert(fun 'a -> a + 2', 'single parameter')
  assert(fun 'a, b, c -> a, b, c', 'multi parameters')
  assert(fun 'a, b, ... -> a + b, ...', 'multi and rest params')
  assert((fun 'a, b -> a + b')(1, 1) == 2, 'operation')
  assert((fun('x -> x + $1', 2))(1) == 3, 'upvalues 1')
  assert(fun('s -> string.char($1 + ($2(s) - $1 + 13) % 26)', string.byte('a'),
             string.byte)('a') == 'n', 'upvalues 2')
end

function test.gen()
  local t = {3, 1, 4, 1, 5, 9}
  assert(fun(ipairs(t))[3][2] == 4)
end

function test.range()
  assert(fun(1, 5, 2)[2] == 3)
  assert(fun(1, 5)[2] == 2)
end

function test.copy()
  local function t(a)
    local b = a:copy()
    assert(a ~= b, 'copy is the same object')
    for i = 1, #a do assert(a[i] == b[i], 'different elems') end
  end
  t(fun {1, 2, 3})
  t(fun {{1}, {2}, {3}})
end

function test.deepcopy()
  local function t(a, b)
    assert(a ~= b, 'copy is the same object')
    for k, v in pairs(a) do
      if type(v) == 'table' then
        t(v, b[k])
      else
        assert(v == b[k], 'different elems')
        assert(getmetatable(v) == getmetatable(b[k]), 'different metatables')
      end
    end
  end
  local a = fun {keys = fun {'a', 'b', 'c'}, vals = fun {1, 2, 3}}
  local b = a:deepcopy()
  t(a, b)
end

function test.map()
  local function t(a, fn)
    local mapped = a:map(fn)
    for k, v in pairs(a) do
      assert(fn(v, k) == mapped[k], 'not mapped')
    end
    assert(a ~= mapped, 'same object')
  end
  t(fun {1, 2, 3}, fun 'x -> x + 2')
  t(fun {a = 1, b = 2, c = 3}, fun 'v, k -> k .. v')
end

function test.filter()
  local nums = fun {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
  local even = nums:filter(fun 'x -> x % 2 == 0')
  for _, v in pairs(even) do assert(v%2==0, 'not filtered') end
  local sparse = fun {[1] = 'a', [4] = 'd', [8] = 'h'}
  local filtered = sparse:filter(fun '_, i -> i > 1')
  assert(filtered[1] == 'd' and filtered[2] == 'h', 'not inferred as array')
  filtered = sparse:filter(fun '_, i -> i > 1', false)
  assert(filtered[4] == 'd' and filtered[8] == 'h', 'not treated as hash')
end

function test.reduce()
  assert(fun {1, 2, 3}:reduce(0, fun 's, x -> s + x') == 6, 'sum failed')
  assert(fun {1, 2, 3}:reduce(1, fun 's, x -> s * x') == 6, 'product failed')
end

function test.foreach()
  local sum = 0
  fun {1, 2, 3}:foreach(function(v) sum = sum + v end)
  assert(sum == 6, 'sum failed')
end

function test.push()
  local a = fun {}
  local b = a:push(1)
  assert(a == b, 'not the same object')
  assert(a[1] == 1, 'not inserted 1')
end

function test.merge()
  local a = fun {keys = fun {'a', 'b', 'c'}, vals = fun {1, 2, 3}}
  local b = {keys = 3, vals = fun {[4] = 4, [5] = 5}}
  local c = {keys = 5, vals = fun {2, 4}}
  local m = a:merge(b, c)
  assert(m.keys == 5)
  for i, v in ipairs({2, 4, 3, 4, 5}) do
    assert(v == m.vals[i], ('%d ~= %d'):format(m.vals[i], v))
  end
  assert(getmetatable(m.vals) == nil, 'metatable was preserved')
end

function test.sort()
  local a = fun {3, 1, 4, 1, 5, 9}
  local s = a:sort()
  assert(a ~= s, 'same object')
  for i, v in ipairs({1, 1, 3, 4, 5, 9}) do
    assert(v == s[i], 'not sorted')
  end
end

function test.keys()
  local function t(a, tkeys)
    local keys = a:keys():sort()
    assert(keys[1], 'not array')
    for i, k in ipairs(keys) do
      assert(k == tkeys[i])
    end
  end
  t(fun {3, 1, 4, 1, 5, 9}, {1, 2, 3, 4, 5, 6})
  t(fun {a = true, b = true, c = true}, {'a', 'b', 'c'})
end

function test.vals()
  local function t(a, tvals)
    local vals = a:vals():sort()
    assert(vals[1], 'not array')
    for i, v in ipairs(vals) do
      assert(v == tvals[i])
    end
  end
  t(fun {a = 'ai', b = 'bo', c = 'ce'}, {'ai', 'bo', 'ce'})
end

function test.hashmap()
  local function t(a, fn)
    local mapped = a:hashmap(fn)
    for k, v in pairs(a) do
      local nk, nv = fn(v, k)
      assert(nv == mapped[nk], 'not mapped')
    end
    assert(a ~= mapped, 'same object')
  end
  t(fun {a = 5, b = 7, c = 0}, fun 'v, k -> v, k')
end

function test.concat()
  local a, b = fun {1, 2}, fun {3, 4}
  local c = a .. b
  assert(a ~= c and b ~= c, 'same object')
  assert(c[3] == 3)
  assert(c[4] == 4)
end

for k, f in pairs(test) do
  local s, msg = pcall(f)
  if s then
    okay(k)
  else
    fail(k, ': ', msg)
  end
end
