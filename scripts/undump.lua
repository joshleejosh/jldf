-- UNmark for dumping all items of the given type. '*' to undump all types.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local itemtype = args[1]
if itemtype == nil then
    qerror('USAGE: undump <item type>')
end

local bytype = {}

local tot=0
for k,v in pairs(df.global.world.items.all) do
    t = getmetatable(v)
    if v.flags['dump'] and (itemtype=='*' or t==itemtype) then
        v.flags['dump'] = false
        tot = tot + 1

        if bytype[t] ~= nil then
            bytype[t] = bytype[t] + 1
        else
            bytype[t] = 1
        end
    end
end

for k,v in pairs(bytype) do
    dfhack.println(k .. ': ' .. v)
end
dfhack.println('Total undumped: ' .. tot)

