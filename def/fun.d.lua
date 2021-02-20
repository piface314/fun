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

---Parses a string into a one line function returning the given expression.
---The string must use this format: `params -> expression`, e.g. `x, y -> x + y`.
---A single "upvalue" can be passed an additional argument, and is referenced in
---the string with `_`. If the generated function contains an error, it will be thrown.
---@param s string defines the function
---@param upval? any arbitrary value that can be accessed inside the new function
---@return any
function Fun.strfn(s, upval) end

---Saves return values of a function on a Fun object, like a generic for construct.
---@param f function function whose return values are stored
---@param o any object used in iteration
---@param v any starting value
---@return Fun
function Fun.gen(f, o, v) end

---Creates a list of numbers in the range `[a,b]`, using `step` as the difference
---between each consecutive term. `step` defaults to 1. If `b` is `nil`, the range
---becomes infinite.
---@param a number starting value
---@param b? number ending value
---@param step? number difference between consecutive terms
function Fun.range(a, b, step) end

---Computes the next element in the table, according to the applied transformation.
---If no more elements are left to be computed, returns `nil`.
---@return any key
---@return any value
function Fun:next() end

---Returns a string representation of the bound table in a Fun object.
---@return string
function Fun:__tostring() end

---Returns in a table every element contained in the object.
---@return table
function Fun:get() end

---Reduces the bound table to a single value, according to a starting value `st` and a function `f`.
---That function receives an accumulator in the first parameter and the current value as the second.
---@generic A
---@param st A starting value
---@param f fun(acc: A, val: any): A function that process each value into a single one
---@return A
function Fun:reduce(st, f) end

---Runs function `f` over each element of the bound table.
---@param f fun(val: any, key: any)
function Fun:foreach(f) end

---Returns the first element that makes `f` return `true`, along with its key.
---If none is found, returns `nil`.
---@param f function tester function
---@return any value
---@return any key
function Fun:find(f) end

---Returns the bound table length/size, as if it was a normal table and `#t` was used.
---A shortcut to `#self:get()`.
---@return number
function Fun:len() end

---Returns the total amount of elements in the bound table, including the ones in
---non-numeric keys.
---@return number
function Fun:size() end

---Takes the `n` first elements. This function is not supposed to work on
---tables that act as hash maps, since there is no fixed order on which
---they are traversed. Use this only in array-like tables.
---@param n number amount of elements retrieved
---@return Fun
function Fun:take(n) end

---Drops the `n` first elements. This function is not supposed to work on
---tables that act as hash maps, since there is no fixed order on which
---they are traversed. Use this only in array-like tables.
---@param n number amount of elements ignored
---@return Fun
function Fun:drop(n) end

---Maps each value in the table with function `f` into a new table.
---`f` receives each value as the first argument, and each index as the second.
---@param f fun(val: any, key: any): any
---@return Fun
function Fun:map(f) end

