describe('fun.', function()
  local fun

  setup(function()
    fun = require '.init'
  end)

  describe('map', function()
    it('should transform values', function()
      local input, output = fun {1, 2, 3}, {2, 4, 6}
      assert.is.same(input:map(function(v) return v * 2 end):get(), output)
    end)
    it('should be able to use each key as well', function()
      local input, output = fun {'a', 'b', 'c'}, {'a1', 'b2', 'c3'}
      assert.is.same(input:map(function(v, k) return v .. k end):get(), output)
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
      assert.is.same(mapped:get(), output)
      assert.is.equal(count / 3, 1)
    end)
  end)
end)
