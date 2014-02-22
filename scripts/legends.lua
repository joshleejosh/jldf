-- List legendary units.

local utils = require 'utils'
local jldf = require 'jldf'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local citizens = {}
local numAdults = 0
local numLegends = 0

for uid,unit in pairs(df.global.world.units.active) do
    if dfhack.units.isCitizen(unit) and dfhack.units.isAlive(unit) then
        citizens[uid] = unit
    end
end

legends={}
losers={}

for uid,unit in pairs(citizens) do
    local doit = false
    local lskills = {}
    local age = dfhack.units.getAge(unit)
    local maxsk = -1
    local bestsk = 0
    local bestxp = 0

    for vid,vitem in pairs(unit.status.current_soul.skills) do
        local sk = dfhack.units.getNominalSkill(unit, vitem.id, false)
        local xp = dfhack.units.getExperience(unit, vitem.id)
        if sk > maxsk and xp ~= 0 then
            maxsk = sk
            bestsk = vitem.id
            bestxp = xp
        end
        if sk > 14 then
            doit = true
            lskills[vitem.id] = sk
        end
    end

    if age >= 12 then
        numAdults = numAdults + 1
        if doit then
            numLegends = numLegends + 1
            legends[unit.name] = {
                name=dfhack.TranslateName(unit.name),
                profession=dfhack.units.getProfessionName(unit),
                skills=lskills
            }
        else
            losers[#losers+1] = {
                name=dfhack.TranslateName(unit.name),
                profession=dfhack.units.getProfessionName(unit),
                skill=df.job_skill.attrs[bestsk].caption,
                level=maxsk,
                experience=bestxp
            }
        end
    end
end

if not args[1] then
    dfhack.println("\nLEGENDS:")
    for i,legend in pairs(legends) do
        local did = false
        for sk,sv in pairs(legend.skills) do
            dfhack.println(string.format('%-20s %-20s %-20s %d',
                        did and ' ' or legend.name:sub(1,20),
                        did and ' ' or legend.profession,
                        df.job_skill.attrs[sk].caption, sv))
            if not did then
                did = true
            end
        end
    end
end

dfhack.println("\nPRE-LEGENDS:")
table.sort(losers, function(a,b)
    if a.level == b.level then
        return a.experience > b.experience
    else
        return a.level > b.level
    end
end)
for i,loser in ipairs(losers) do
    dfhack.println(string.format('%-20s %-20s %-20s %2d (%d/%d)',
                loser.name:sub(1,20),
                loser.profession,
                loser.skill,
                loser.level,
                loser.experience,
                jldf.skillXpCap(loser.level)
                ))
end

dfhack.println('total legends = ' .. numLegends .. ' out of ' .. numAdults .. ' adult citizens')

