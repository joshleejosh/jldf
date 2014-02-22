-- List skill levels for active laborers.

--
-- Arguments:
--     '<N' List unit/labor pairs with level less than N.
--     '>N' List unit/labor pairs with level greater than N.
--     '!N' List units with demotion counters greater than N.
--     Any other string is a search pattern.
--
-- Example:
--     labors >11 <15 carp
--     List units active in carpentry with skill level from 12 to 14.
--

local utils = require 'utils'
local jldf = require 'jldf'
local args = {...}

local skillcap = 10000
local skillfloor = -1
local demotionfloor = -1
local searchpat = ''

for i,arg in ipairs(args) do
    if string.sub(arg, 1, 1) == '<' then
        skillcap = tonumber(string.sub(arg, 2, string.len(arg)))
    elseif string.sub(arg, 1, 1) == '>' then
        skillfloor = tonumber(string.sub(arg, 2, string.len(arg)))
    elseif string.sub(arg, 1, 1) == '!' then
        demotionfloor = tonumber(string.sub(arg, 2, string.len(arg)))
    else
        searchpat = arg:upper()
    end
end

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end


-- Map labors to skills.
labors = {
  { 'MINE'            , 0   } ,
  { 'CARPENTER'       , 2   } ,
  { 'BOWYER'          , 49  } ,
  { 'CUTWOOD'         , 1   } ,
  { 'MASON'           , 4   } ,
  { 'DETAIL'          , 3   } ,
  --{ 'ANIMALTRAIN'     , 5   } ,
  --{ 'ANIMALCARE'      , 6   } ,
  --{ 'HUNT'            , 57  } ,
  --{ 'TRAPPER'         , 11  } ,
  --{ 'DISSECT_VERMIN'  , 8   } ,
  --{ 'DIAGNOSE'        , 60  } ,
  --{ 'SURGERY'         , 61  } ,
  --{ 'BONE_SETTING'    , 62  } ,
  --{ 'SUTURING'        , 63  } ,
  --{ 'DRESSING_WOUNDS' , 59  } ,
  { 'BUTCHER'         , 10  } ,
  { 'TANNER'          , 12  } ,
  { 'PLANT'           , 22  } ,
  { 'DYER'            , 69  } ,
  { 'SOAP_MAKER'      , 67  } ,
  { 'BURN_WOOD'       , 65  } ,
  { 'POTASH_MAKING'   , 68  } ,
  { 'LYE_MAKING'      , 66  } ,
  { 'MILLER'          , 17  } ,
  { 'BREWER'          , 14  } ,
  { 'HERBALIST'       , 23  } ,
  { 'PROCESS_PLANT'   , 18  } ,
  { 'MAKE_CHEESE'     , 19  } ,
  { 'MILK'            , 20  } ,
  { 'SHEARER'         , 109 } ,
  { 'SPINNER'         , 110 } ,
  { 'COOK'            , 21  } ,
  { 'PRESSING'        , 113 } ,
  { 'BEEKEEPING'      , 114 } ,
  --{ 'FISH'            , 24  } ,
  --{ 'CLEAN_FISH'      , 9   } ,
  --{ 'DISSECT_FISH'    , 7   } ,
  { 'SMELT'           , 25  } ,
  { 'FORGE_WEAPON'    , 27  } ,
  { 'FORGE_ARMOR'     , 28  } ,
  { 'FORGE_FURNITURE' , 29  } ,
  { 'METAL_CRAFT'     , 34  } ,
  { 'CUT_GEM'         , 30  } ,
  { 'ENCRUST_GEM'     , 31  } ,
  { 'LEATHER'         , 36  } ,
  { 'WOOD_CRAFT'      , 32  } ,
  { 'STONE_CRAFT'     , 33  } ,
  { 'BONE_CARVE'      , 37  } ,
  { 'GLASSMAKER'      , 35  } ,
  { 'WEAVER'          , 13  } ,
  { 'CLOTHESMAKER'    , 16  } ,
  { 'EXTRACT_STRAND'  , 26  } ,
  { 'POTTERY'         , 111 } ,
  { 'GLAZING'         , 112 } ,
  { 'WAX_WORKING'     , 115 } ,
  --{ 'SIEGECRAFT'      , 47  } ,
  --{ 'SIEGEOPERATE'    , 48  } ,
  { 'MECHANIC'        , 55  } ,
  --{ 'OPERATE_PUMP'    , 70  } ,
  { 'ARCHITECT'       , 58  } ,
  --{ 'ALCHEMIST'       , 15  } ,

  --{ 'HAUL_STONE'           , 0 } ,
  --{ 'HAUL_WOOD'            , 0 } ,
  --{ 'HAUL_BODY'            , 0 } ,
  --{ 'HAUL_FOOD'            , 0 } ,
  --{ 'HAUL_REFUSE'          , 0 } ,
  --{ 'HAUL_ITEM'            , 0 } ,
  --{ 'HAUL_FURNITURE'       , 0 } ,
  --{ 'HAUL_ANIMAL'          , 0 } ,
  --{ 'CLEAN'                , 0 } ,
  --{ 'FEED_WATER_CIVILIANS' , 0 } ,
  --{ 'RECOVER_WOUNDED'      , 0 } ,
  --{ 'PUSH_HAUL_VEHICLE'    , 0 } ,

  --{ '74'                   , 0 } ,
  --{ '75'                   , 0 } ,
  --{ '76'                   , 0 } ,
  --{ '77'                   , 0 } ,
  --{ '78'                   , 0 } ,
  --{ '79'                   , 0 } ,
  --{ '80'                   , 0 } ,
  --{ '81'                   , 0 } ,
  --{ '82'                   , 0 } ,
  --{ '83'                   , 0 } ,
  --{ '84'                   , 0 } ,
  --{ '85'                   , 0 } ,
  --{ '86'                   , 0 } ,
  --{ '87'                   , 0 } ,
  --{ '88'                   , 0 } ,
  --{ '89'                   , 0 } ,
  --{ '90'                   , 0 } ,
  --{ '91'                   , 0 } ,
  --{ '92'                   , 0 } ,
  --{ '93'                   , 0 } ,
}

function cmpAss(a,b)
    if a.skill == b.skill then
        return (a.xp > b.xp)
    else
        return (a.skill > b.skill)
    end
end

local citizens = {}
jldf.findCitizens(citizens)

function getem(labor)
    local assignees = {}
    for uid,unit in ipairs(citizens) do
        for k,v in pairs(unit.status.labors) do
            if k==labor[1] and v then
                u = jldf.getSkillInfo(unit, labor[2])
                u.age = dfhack.units.getAge(unit)
                table.insert(assignees, u)
            end
        end
    end

    if next(assignees) == nil then
        dfhack.println(string.format('%-17s: -', df.job_skill.attrs[labor[2]].caption_noun:upper()))
    else
        local first = true;
        table.sort(assignees, cmpAss)
        for i,ass in pairs(assignees) do
            if ass.skill < skillcap
                    and ass.skill > skillfloor
                    and ass.demotion_counter > demotionfloor
                    then
                dfhack.println(string.format('%-17s: %-20s %3d   %5d/%5d    %2s     %3d',
                    first and df.job_skill.attrs[labor[2]].caption_noun:upper() or ' ',
                    dfhack.TranslateName(ass.name),
                    ass.skill,
                    ass.xp,
                    jldf.skillXpCap(ass.skill),
                    --[[
                    (ass.demotion_counter > 0) and string.format('(%3d: %2d %2d %2d)',
                        ass.eskill,
                        ass.unused_counter,
                        ass.rust_counter,
                        ass.demotion_counter) or '',
                    ]]--
                    (ass.demotion_counter>0) and string.format('%2d', ass.demotion_counter) or '',
                    ass.age
                    ))

                if first then
                    first = false
                end
            end
        end
    end

end

--dfhack.println(string.format('%-17s: %-20s %5s   %5s     %8s   %3s', '', '', 'skill', 'xp', 'demotion', 'age'))
for lid,labor in pairs(labors) do
    s = df.job_skill.attrs[labor[2]].caption_noun:upper()
    if searchpat == '' or s:find(searchpat) then
        getem(labor)
    end
end

