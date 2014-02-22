-- Inventory items that are marked to be melted.

local utils = require 'utils'
local args = {...}
if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local totalMelters = 0
local itemTypes = {}
local itemMats = {}
for k,v in pairs(df.global.world.items.all) do
    if v.flags.melt then
        totalMelters = totalMelters + 1
        tk = getmetatable(v)
        if itemTypes[tk] ~= nil then
            itemTypes[tk] = itemTypes[tk] + 1
        else
            itemTypes[tk] = 1
        end
        local mattok = dfhack.matinfo.getToken(v.mat_type, v.mat_index)
        local subtok = string.gsub(mattok, '^[^:]*:', ''):lower()
        if itemMats[subtok] ~= nil then
            itemMats[subtok] = itemMats[subtok] + 1
        else
            itemMats[subtok] = 1
        end
    end
end
dfhack.println('Total to melt: ' .. totalMelters)
for k,v in pairs(itemTypes) do
    dfhack.println('    ' .. k .. ': ' .. v)
end
dfhack.println('by material:')
for k,v in pairs(itemMats) do
    dfhack.println('    ' .. k .. ': ' .. v)
end

