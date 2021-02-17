describe('fun', function()
  local fun

  setup(function() fun = require '.init' end)

  describe('infer', function()
    it('should accept tables, strings, numbers or functions', function()
      assert.has_no.errors(function() fun {} end)
      assert.has_no.errors(function() fun 'x -> x' end)
      assert.has_no.errors(function() fun(1, 2) end)
      assert.has_no.errors(function() fun(function() end) end)
      assert.has.error(function() fun(nil) end)
      assert.has.error(function() fun(true) end)
    end)
  end)
end)
