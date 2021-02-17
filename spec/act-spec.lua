describe('fun.', function()
  local fun

  setup(function()
    fun = require '.init'
  end)

  describe('get', function()
    it('should copy the original table when no operation is done', function()
      local t = {1, 2, 3}
      local f = fun(t)
      assert.is_not.equal(t, f:get())
      assert.is.same(t, f:get())
    end)
  end)
end)
