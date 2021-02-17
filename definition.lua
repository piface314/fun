local function define(files, out)
  local o<close> = io.open(out .. '.d.lua', 'w')
  local rep = {}
  for _, fp in ipairs(files) do
    local lines, buffer = {}, {}
    local file<close> = io.open('src/' .. fp .. '.lua')
    for line in file:lines() do
      if line:match '^local%s+[%w_][%w_%d]*%s*=%s*{' then
        if not rep[line] then
          for _, l in ipairs(buffer) do lines[#lines + 1] = l end
          lines[#lines + 1] = line .. '\n\n'
          rep[line] = true
        end
        buffer = {}
      elseif line:match '^function%s+[%w_][%w_%d]*[.:][%w_][%w_%d]*%s*%(.-%)' then
        for _, l in ipairs(buffer) do lines[#lines + 1] = l end
        local st = line:match '^(function%s+[%w_][%w_%d]*[.:][%w_][%w_%d]*%s*%(.-%))%s.*end$'
        lines[#lines + 1] = (st or line) .. ' end\n\n'
        buffer = {}
      elseif line:match '^%-%-%-%s*@alias' then
        lines[#lines + 1] = line .. '\n\n'
        buffer = {}
      elseif line:match '^%-%-%-%s*' then
        buffer[#buffer + 1] = line .. '\n'
      else
        buffer = {}
      end
    end
    o:write(table.unpack(lines))
  end
end

define({'core', 'action', 'trans'}, 'def/fun')
define({'utils'}, 'def/utils')
