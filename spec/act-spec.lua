describe('fun.', function()
  local fun

  setup(function()
    fun = require '.init'
  end)

  describe(':__tostring', function()
    it('should convert Fun objects to strings', function()
      assert.is.same(tostring(fun {1, 2, 3}), '{1, 2, 3}')
      local sh = tostring(fun {a = 1, b = 2})
      assert.is.True(sh == '{a = 1, b = 2}' or sh == '{b = 2, a = 1}')
      sh = tostring(fun {1, 2, 3, a = 1, b = 2})
      assert.is.True(sh == '{1, 2, 3; a = 1, b = 2}' or sh == '{1, 2, 3; b = 2, a = 1}')
    end)
  end)

  describe(':get', function()
    it('should copy the original table when no operation is done', function()
      local t = {1, 2, 3}
      local f = fun(t)
      assert.is_not.equal(t, f:get())
      assert.is.same(t, f:get())
      t = {a = 1, b = 2, c = 3}
      f = fun(t)
      assert.is_not.equal(t, f:get())
      assert.is.same(t, f:get())
    end)
  end)

  describe(':reduce', function()
    it('should accept only functions as its second argument', function()
      assert.has.error(function() fun {1, 2, 3}:reduce(0, 0) end)
      assert.has_no.error(function() fun {1, 2, 3}:reduce(0, tostring) end)
    end)
    it('should reduce elements into a single value', function()
      local sum = function(a, b) return a + b end
      assert.is.same(6, fun {1, 2, 3}:reduce(0, sum))
      assert.is.same(6, fun {a = 1, b = 2, c = 3}:reduce(0, sum))
    end)
  end)

  describe(':foreach', function()
    it('should accept only functions', function()
      local t = fun {1, 2, 3}
      assert.has.error(function() t:foreach(0) end)
      assert.has_no.error(function() t:foreach(fun '->') end)
    end)
    it('should traverse each <value, key>', function()
      local s = 0
      local function mulsum(v, k) s = s + v * k end
      fun {1, 2, 3}:foreach(mulsum)
      assert.is.same(14, s)
      s = 0
      fun {[10] = 1, [100] = 2, [1000] = 3}:foreach(mulsum)
      assert.is.same(3210, s)
    end)
  end)

  describe(':find', function()
    it('should accept only functions', function()
      local t = fun {1, 2, 3}
      assert.has.error(function() t:find(0) end)
      assert.has_no.error(function() t:find(fun '->') end)
    end)
    it('should find a matching <value, key> pair', function()
      local even = fun 'n, k -> n % 2 == 0 and type(k) == "string"'
      local v, k = fun {a = 3, b = 1, c = 4}:find(even)
      assert.is.same(4, v)
      assert.is.same('c', k)
      v, k = fun {3, 1, 4}:find(even)
      assert.is.same(nil, v)
      assert.is.same(nil, k)
    end)
  end)

  describe(':len', function()
    it('should return array length', function()
      assert.is.same(3, fun {1, 2, 3}:len())
      assert.is.same(0, fun {a = 1, b = 2, c = 3}:len())
    end)
  end)

  describe(':size', function()
    it('should return table size (total amount of entries)', function()
      assert.is.same(3, fun {1, 2, 3}:size())
      assert.is.same(3, fun {a = 1, b = 2, c = 3}:size())
    end)
  end)
end)
