-- list the ages of pets. Can filter by name or race.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local searchpat = ''
for i,arg in ipairs(args) do
    searchpat = arg:upper()
end

function cmpage(a,b)
    local agea = dfhack.units.getAge(a)
    local ageb = dfhack.units.getAge(b)
    return agea > ageb
end

local dwarf_race = df.global.ui.race_id
local dwarf_civ = df.global.ui.civ_id

local pets = {}
for uid,unit in pairs(df.global.world.units.all) do
    if dfhack.units.isAlive(unit)
            and unit.civ_id == dwarf_civ
            and unit.race ~= dwarf_race
            and unit.flags1.tame
            and not unit.flags1.forest then
        table.insert(pets, unit)
    end
end

local census = {}
table.sort(pets, cmpage)
for uid,unit in ipairs(pets) do
    local name = dfhack.TranslateName(dfhack.units.getVisibleName(unit))
    local age = dfhack.units.getAge(unit)
    local race = df.creature_raw.find(unit.race).name[0]
    local profession = dfhack.units.getProfessionName(unit)
    if (searchpat
            and (profession:upper():find(searchpat)
                 or race:upper():find(searchpat)
                 or name:upper():find(searchpat)
                 ))
            or not searchpat then
        if not census[race] then
            census[race] = {0, 0}
            dfhack.println(race .. ' ' .. census[race][1])
        end
        census[race][unit.sex+1] = census[race][unit.sex+1] + 1
        dfhack.println(string.format('%-20s %-14s %02.2f %2s %s',
                    (name ~= '') and name or 'stray',
                    profession,
                    age,
                    (unit.sex==0) and 'F' or 'M',
                    (unit.flags2.slaughter) and 'S' or ' '))
    end
end

dfhack.println()
dfhack.println(string.format('%-12s  %2s %2s', '', 'F', 'M'))
for rid,rec in pairs(census) do
    dfhack.println(string.format('%-12s: %2d %2d', rid, rec[1], rec[2]))
end

