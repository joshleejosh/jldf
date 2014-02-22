-- List unowned bedrooms.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

rooms = {}

for bid,building in pairs(df.global.world.buildings.all) do
    tk = getmetatable(building)
    if tk == 'building_bedst' then
        if building.owner then
            --s = dfhack.TranslateName(building.owner.name)
        else
            rooms[#rooms+1] = {
                x = building.centerx,
                y = building.centery,
                z = building.z - 29,
            }
        end
    end
end

roomCounts = {}

for i,room in ipairs(rooms) do
    if roomCounts[room.z] == nil then
        roomCounts[room.z] = 1
    else
        roomCounts[room.z] = roomCounts[room.z] + 1
    end
end

-- Generate an iterator that sorts the table's keys.
function pairsByFloor(tb)
    local a = {}
    for i,v in pairs(tb) do
        table.insert(a, i)
    end
    table.sort(a)
    local i = 0
    local iterator = function()
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], tb[a[i]]
        end
    end
    return iterator
end

for i,rc in pairsByFloor(roomCounts) do
    dfhack.println(string.format('%d free on floor %d', rc, i))
end

