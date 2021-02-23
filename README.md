# fun - functional support for Lua tables

It's fun(ctional?)!

> NOTE: I just found out about [luafun](https://github.com/luafun/luafun), it does all this library was intended to do, and more. So this repository is now archived, as it is redundant.

## Example usage

```lua
local fun = require 'fun'

local words = fun {'roses', 'are', 'red', 'violets', 'are', 'blue'}
print('Words with "r":', words:filter(fun 'w -> w:match("r")'))
print('Total amount of letters:', words:reduce(0, fun 'c, w -> c + #w'))
print('Reversed words:', words:map(fun 'w -> string.reverse(w)'))
```
