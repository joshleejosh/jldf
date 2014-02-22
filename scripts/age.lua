-- List dwarves by age. Can filter by name or profession.

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local utils = require 'utils'
local jldf = require 'jldf'
local args = {...}

local agecap = 1000
local agefloor = -1
local searchpat = ''

for i,arg in ipairs(args) do
    if string.sub(arg, 1, 1) == '<' then
        agecap = tonumber(string.sub(arg, 2, string.len(arg)))
    elseif string.sub(arg, 1, 1) == '>' then
        agefloor = tonumber(string.sub(arg, 2, string.len(arg)))
    else
        searchpat = arg:upper()
    end
end

function cmpage(a,b)
    local agea = dfhack.units.getAge(a)
    local ageb = dfhack.units.getAge(b)
    return agea > ageb
end

local citizens = {}
jldf.findCitizens(citizens)
table.sort(citizens, cmpage)

for cid,unit in ipairs(citizens) do
    local name = dfhack.TranslateName(unit.name)
    local age = dfhack.units.getAge(unit)
    profession=dfhack.units.getProfessionName(unit)
    if age < agecap and age > agefloor then
        if (searchpat
                and (name:upper():find(searchpat)
                     or profession:upper():find(searchpat)))
            or not searchpat then
            dfhack.println(string.format('%-20s is %.2f %s', name:sub(1,20), age, profession))
        end
    end
end

