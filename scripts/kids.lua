-- List family trees.
local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local dwarves = {}
for uid,unit in pairs(df.global.world.units.all) do
    if dfhack.units.isDwarf(unit) then
        dwarves[uid] = unit
    end
end

for uid,unit in pairs(dwarves) do
    local children = {}
    local nc = 0
    for cid,child in pairs(dwarves) do
        local mom = child.relations.mother_id
        local dad = child.relations.father_id
        if mom == unit.id or dad == unit.id then
            children[cid] = child
            nc = nc + 1
        end
    end
    if nc > 0 then
        dfhack.println(string.format('%4d: %s: %d kids', unit.id, dfhack.TranslateName(unit.name), nc))
        for cid,child in pairs(children) do
            local tag = ''
            if dfhack.units.getAge(child) < 12.00 then
                tag = '(!)'
            end
            dfhack.println(string.format('    %4d: %s %.2f %s', child.id, dfhack.TranslateName(child.name), dfhack.units.getAge(unit), tag))
        end
    end
end

