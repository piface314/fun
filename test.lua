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
end

function test.copy()
  local function t(a)
    local b = a:copy()
    assert(a ~= b, 'copy is the same as source')
    for i = 1, #a do assert(a[i] == b[i], 'different elems') end
  end
  t(fun {1,2,3})
  t(fun {{1}, {2}, {3}})
end

for k, f in pairs(test) do
  local s, msg = pcall(f)
  if s then okay(k) else fail(k, ': ', msg) end
end
