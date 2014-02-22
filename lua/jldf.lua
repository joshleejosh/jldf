-- Module containing misc. helper functions

local _ENV = mkmodule('jl')

QUALITY_MARKERS = { ' ', '-', '+', '*', '=', '☼', 'A', '<' }

function findCitizens(dest)
    for uid,unit in pairs(df.global.world.units.all) do
        if dfhack.units.isCitizen(unit) and dfhack.units.isAlive(unit) then
            table.insert(dest, unit)
        end
    end
end

function getSkillInfo(unit, skillid)
    out = {
        id=unit.id,
        name=unit.name,
        skill=0,
        eskill=0,
        unused_counter=0,
        rust_counter=0,
        demotion_counter=0,
        xp=0,
    }
    for skid,skitem in pairs(unit.status.current_soul.skills) do
        if skitem.id == skillid then
            out.skill = dfhack.units.getNominalSkill(unit, skillid, false)
            out.eskill = dfhack.units.getEffectiveSkill(unit, skillid, false)
            out.xp = dfhack.units.getExperience(unit, skitem.id)
            out.unused_counter = skitem.unused_counter
            out.rust_counter = skitem.rust_counter
            out.demotion_counter = skitem.demotion_counter
            out.legend=(out.skill > 14)
        end
    end
    return out
end

function skillXpCap(level)
    return (500 + 100 * level)
end

function printKeys(t)
    if (not t) then
        error('No value given for printKeys')
        return
    end
    for k,v in pairs(t) do
        dfhack.println(k)
    end
end

function __dump_sub(t, level, maxdepth)
    if (not t) then
        dfhack.println('nil object')
        return
    end
    if not maxdepth then
        maxdepth=0
    end
    local prefix = ''
    for i=1,level do
        prefix = prefix..'  '
    end
    for k,v in pairs(t) do
        --if (getmetatable(v) and type(v) ~= 'string') then
        if (type(v) == 'table') then
            dfhack.println(string.format('%s%s: <%s>', prefix, k, getmetatable(v)))
            if (level < maxdepth) then
                __dump_sub(v, level+1, maxdepth)
            end
        elseif (not v) then
            dfhack.println(prefix..k..': nil')
        else
            dfhack.println(string.format('%s%s: %s', prefix, k, v))
        end
    end
end

-- Walk through a tree of tables, printing scalar values out.
function dump(t, maxdepth)
    __dump_sub(t, 0, maxdepth)
end

return _ENV

