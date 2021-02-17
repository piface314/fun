---Adds functional style support to tables
---@class Fun
---@field bound table
---@field cache table
---@field trans thread
local Fun = {}

---Checks if a value is an instance of Fun
---@param v any
---@return boolean
function Fun.is(v) end

---Creates a new Fun object by binding a table to it.
---@param t table the table to be bound
---@param copy? CopyMode if and how the table should be copied
---@return Fun
function Fun.bind(t, copy) end

---Computes the next element in the table, according to the applied transformation.
---If no more elements are left to be computed, returns `nil`.
---@return any key
---@return any value
function Fun:next() end

---Returns in a table every element contained in the object.
---@return table
function Fun:get() end

---Maps each value in the table with function `f` into a new table.
---`f` receives each value as the first argument, and each index as the second.
---@param f fun(val: any, key: any): any
---@return Fun
function Fun:map(f) end

