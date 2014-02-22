-- Count items that are marked to be dumped.
-- Give any argument to break down by type.

local utils = require 'utils'
local args = {...}
if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local level = args[1] and 1 or 0

local totalDumpers = 0
local itemTypes = {}
local descriptionsByType = {}
local cc=0
for k,v in pairs(df.global.world.items.all) do
    if v.flags['dump'] and not v.flags['in_building'] then
--[[
        dfhack.println('Dump: ' .. v.id .. ' ' .. getmetatable(v))
        for flagk,flagv in pairs(v.flags) do
          dfhack.println('    ' .. flagk)
        end
]]--
        totalDumpers = totalDumpers + 1
        tk = getmetatable(v)
        if itemTypes[tk] ~= nil then
            itemTypes[tk] = itemTypes[tk] + 1
        else
            itemTypes[tk] = 1
            if level > 0 then
                descriptionsByType[tk] = {}
            end
        end

        if level > 0 then
            desc = dfhack.items.getDescription(v, 0)
            desc = desc:gsub('.* ', '')
            if descriptionsByType[tk][desc] ~= nil then
                descriptionsByType[tk][desc] = descriptionsByType[tk][desc] + 1
            else
                descriptionsByType[tk][desc] = 1
            end
        end
    end
end

dfhack.println('Total to dump: ' .. totalDumpers)
for k,v in pairs(itemTypes) do
    dfhack.println('    ' .. k .. ': ' .. v)
    if level > 0 then
        for dk,dv in pairs(descriptionsByType[k]) do
            dfhack.println('        ' .. dv .. '\t' .. dk)
        end
    end
end


