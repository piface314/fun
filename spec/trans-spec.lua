describe('Fun', function()
  local fun

  setup(function()
    fun = require '.init'
  end)

  describe(':take', function()
    it('should accept only numbers', function()
      local t = fun {1, 2, 3}
      assert.has.error(function() t:take('aa') end)
      assert.has_no.error(function() t:take(0) end)
    end)
    it('should take only the n first elements', function()
      assert.is.same({1, 2, 3}, fun(1):take(3):get())
      assert.is.same({1, 2, 3}, fun(1, 3):take(10):get())
      assert.is.same({}, fun(1, 3):take(0):get())
    end)
  end)

  describe(':drop', function()
    it('should accept only numbers', function()
      local t = fun {1, 2, 3}
      assert.has.error(function() t:drop('aa') end)
      assert.has_no.error(function() t:drop(0) end)
    end)
    it('should drop the n first elements', function()
      local dropped = fun(1, 9):drop(6)
      assert.is.same({7, 8, 9}, dropped:get())
      assert.is.same({7, 8, 9}, dropped:get())
      assert.is.same({7, 8, 9}, dropped:get())
      assert.is.same({1, 2, 3}, fun(1, 3):drop(0):get())
      assert.is.same({}, fun(1, 3):drop(10):get())
    end)
  end)

  describe(':map', function()
    it('should accept only functions', function()
      local t = fun {1, 2, 3}
      assert.has.error(function() t:map('aa') end)
      assert.has_no.error(function() t:map(tostring) end)
    end)
    it('should transform values', function()
      local input, output = fun {1, 2, 3}, {2, 4, 6}
      assert.is.same(output, input:map(fun 'v -> v * 2'):get())
    end)
    it('should be able to use each key as well', function()
      local input, output = fun {'a', 'b', 'c'}, {'a1', 'b2', 'c3'}
      assert.is.same(output, input:map(fun 'v, k -> v .. k'):get())
    end)
    it('should transform values only once and cache them', function()
      local input, output, count = fun {1, 2, 3}, {2, 4, 6}, 0
      local mapped = input:map(function(v)
        count = count + 1
        return v * 2
      end)
      mapped:get()
      mapped:get()
      mapped:get()
      assert.is.same(output, mapped:get())
      assert.is.equal(1, count / #output)
    end)
  end)
end)
