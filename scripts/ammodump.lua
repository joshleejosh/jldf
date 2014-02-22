-- Mark stray ammo (forbidden and stack size of 1) for dumping.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local hits = 0

for uid,item in pairs(df.global.world.items.all) do
    local itemtype = getmetatable(item)
    if itemtype == 'item_ammost' then
        dfhack.println('ammo ' .. item.stack_size .. ' ' .. dfhack.matinfo.getToken(item.mat_type, item.mat_index))
        if item.stack_size == 1 and not item.flags.dump and item.flags.forbid then
            hits = hits + 1
            item.flags.forbid = false
            item.flags.dump = true
        end
    end
end

dfhack.println('' .. hits .. ' items dumped')


