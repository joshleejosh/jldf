-- Inventory clothing by wear level.
-- Give a wear level ('x', 'X', 'XX') to dump all clothes at that level or above.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local threshold = 99
local arg = args[1]
if arg == 'XX' then
    threshold = 3
elseif arg == 'X' then
    threshold = 2
elseif arg == 'x' then
    threshold = 1
end


local dumped = 0
local itemTypes = {
    item_armorst  = {},
    item_helmst   = {},
    item_pantsst  = {},
    item_glovesst = {},
    item_shoesst  = {},
}
local itemTypeLabels = {
    item_armorst  = 'ARMOR',
    item_helmst   = 'HEAD',
    item_pantsst  = 'LEG',
    item_glovesst = 'HAND',
    item_shoesst  = 'FOOT',
}
local ininv = 0
local notininv = 0

for k,v in pairs(df.global.world.items.all) do
    mt = getmetatable(v)
    for tk,tv in pairs(itemTypes) do
        if mt == tk and not v.flags.forbid then
            desc = dfhack.items.getDescription(v, 0)
            lastword = desc:gsub('^.* ', '')
            if itemTypes[tk][lastword] == nil then
                itemTypes[tk][lastword] = {0,0,0,0}
            end
            itemTypes[tk][lastword][v.wear+1] = itemTypes[tk][lastword][v.wear+1] + 1

            if v.wear >= threshold then
                v.flags.dump = true
                dumped = dumped + 1
            end
        end
    end

    if mt == 'item_helmst' then
        if v.flags.in_inventory then
            ininv = ininv + 1
        else
            notininv = notininv + 1
        end
    end
end

dfhack.println('               _   x   X  XX')
for itemType,it in pairs(itemTypes) do
    local s = string.format('%11s', itemTypeLabels[itemType])
    s = s:gsub(' ', '-')
    dfhack.println(string.format('%11s----------------------', s))
    for item,i in pairs(it) do
        dfhack.println(string.format('%11s: %3d %3d %3d %3d',
                    item, i[1], i[2], i[3], i[4]
                    ))
    end
end

if dumped > 0 then
    dfhack.println('Marked ' .. dumped .. ' for dumping')
end

