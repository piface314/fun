---Utility functions
local Utils = {}

---@alias CopyMode "'shallow'"|"'deep'"

---Returns a shallow or deep copy of a table. Internal metatables are preserved.
---@param t table table to be copied
---@param mode CopyMode copy mode
---@return table
function Utils.copy(t, mode) end

---Merges any number of tables. Latest tables take precedence.
---Internal metatables are not preserved. The resulting table and any subtables
---are all new tables, so they can be mutated freely without interfering with their
---original counterparts.
---@vararg table
---@return table
function Utils.merge(...) end

