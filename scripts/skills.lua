-- List dwarves with the given skill.

local utils = require 'utils'
local jldf = require 'jldf'
local args = {...}

if not args[1] then
    qerror('USAGE: skills pattern')
end

local skillcap = 10000
local skillfloor = 0
local searchpat = ''

for i,arg in ipairs(args) do
    if string.sub(arg, 1, 1) == '<' then
        skillcap = tonumber(string.sub(arg, 2, string.len(arg)))
        dfhack.println('skill cap is ' .. skillcap)
    elseif string.sub(arg, 1, 1) == '>' then
        skillfloor = tonumber(string.sub(arg, 2, string.len(arg)))
        dfhack.println('skill floor is ' .. skillfloor)
    else
        searchpat = arg:upper()
    end
end

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

skills = {
    [0]="Mining",
    [1]="Wood Cutting",
    [2]="Carpentry",
    [3]="Engraving",
    [4]="Masonry",
    [5]="Animal Training",
    [6]="Animal Caretaking",
    [7]="Fish Dissection",
    [8]="Animal Dissection",
    [9]="Fish Cleaning",
    [10]="Butchery",
    [11]="Trapping",
    [12]="Tanning",
    [13]="Weaving",
    [14]="Brewing",
    [15]="Alchemy",
    [16]="Clothes Making",
    [17]="Milling",
    [18]="Threshing",
    [19]="Cheese Making",
    [20]="Milking",
    [21]="Cooking",
    [22]="Growing",
    [23]="Herbalism",
    [24]="Fishing",
    [25]="Furnace Operation",
    [26]="Strand Extraction",
    [27]="Weaponsmithing",
    [28]="Armorsmithing",
    [29]="Metalsmithing",
    [30]="Gem Cutting",
    [31]="Gem Setting",
    [32]="Wood Crafting",
    [33]="Stone Crafting",
    [34]="Metal Crafting",
    [35]="Glassmaking",
    [36]="Leatherworkering",
    [37]="Bone Carving",
    [38]="Axe",
    [39]="Sword",
    [40]="Knife",
    [41]="Mace",
    [42]="Hammer",
    [43]="Spear",
    [44]="Crossbow",
    [45]="Shield",
    [46]="Armor",
    [47]="Siege Engineering",
    [48]="Siege Operation",
    [49]="Bowmaking",
    [50]="Pike",
    [51]="Lash",
    [52]="Bow",
    [53]="Blowgun",
    [54]="Throwing",
    [55]="Machinery",
    [56]="Nature",
    [57]="Ambush",
    [58]="Building Design",
    [59]="Wound Dressing",
    [60]="Diagnostics",
    [61]="Surgery",
    [62]="Bone Setting",
    [63]="Suturing",
    [64]="Crutch-walking",
    [65]="Wood Burning",
    [66]="Lye Making",
    [67]="Soap Making",
    [68]="Potash Making",
    [69]="Dyeing",
    [70]="Pump Operation",
    [71]="Swimming",
    [72]="Persuasion",
    [73]="Negotiation",
    [74]="Judging Intent",
    [75]="Appraisal",
    [76]="Organization",
    [77]="Record Keeping",
    [78]="Lying",
    [79]="Intimidation",
    [80]="Conversation",
    [81]="Comedy",
    [82]="Flattery",
    [83]="Consoling",
    [84]="Pacification",
    [85]="Tracking",
    [86]="Studying",
    [87]="Concentration",
    [88]="Discipline",
    [89]="Observation",
    [90]="Writing",
    [91]="Prose",
    [92]="Poetry",
    [93]="Reading",
    [94]="Speaking",
    [95]="Coordination",
    [96]="Balance",
    [97]="Leadership",
    [98]="Teaching",
    [99]="Fighting",
    [100]="Archery",
    [101]="Wrestling",
    [102]="Biting",
    [103]="Striking",
    [104]="Kicking",
    [105]="Dodging",
    [106]="Misc. Object",
    [107]="Knapping",
    [108]="Military Tactics",
    [109]="Shearing",
    [110]="Spinning",
    [111]="Pottery",
    [112]="Glazing",
    [113]="Pressing",
    [114]="Beekeeping",
    [115]="Wax Working",
}


local citizens = {}
local filtered = {}
jldf.findCitizens(citizens)

function getem(skillid, skillname)
    local assignees = {}
    for uid,unit in pairs(citizens) do
        assignees[uid] = jldf.getSkillInfo(unit, skillid)
    end

    if next(assignees) == nil then
        dfhack.println(string.format('%-17s: -', skillname:upper()))
    else
        local first = true;
        for aid,ass in pairs(assignees) do
            if ass.skill < skillcap and ass.skill > skillfloor then --not onlyRusty or ass.demotion_counter > 0 then
                filtered[#filtered+1] = {
                    ['skillname'] = skillname:upper(),
                    ['name'] = dfhack.TranslateName(ass.name),
                    ['level'] = ass.skill,
                    ['xp'] = ass.xp,
                    ['xpcap'] = (500 + 100 * ass.skill),
                    ['eskill'] = ass.eskill,
                    ['unused_counter'] = ass.unused_counter,
                    ['rust_counter'] = ass.rust_counter,
                    ['demotion_counter'] = ass.demotion_counter,
                }

                if first then
                    first = false
                end
            end
        end
    end

end

function dumpem()
    table.sort(filtered, function(a,b)
        if a.level == b.level then
            return a.xp > b.xp
        else
            return a.level > b.level
        end
    end)

    local skname = ''
    for fid,fitem in pairs(filtered) do
        dfhack.println(string.format('%-20s: %-20s %2d   %4d/%4d %s',
            (fitem.skillname ~= skname) and fitem.skillname or ' ',
            string.sub(fitem.name, 1, 20),
            fitem.level,
            fitem.xp,
            fitem.xpcap,
            (fitem.demotion_counter > 0) and string.format('(%2d: %2d %2d %2d)',
                fitem.eskill,
                fitem.unused_counter,
                fitem.rust_counter,
                fitem.demotion_counter) or ''
            ))
        skname = fitem.skillname
    end
end


for skid,skill in pairs(skills) do
    if searchpat == '' or skill:upper():find(searchpat:upper()) then
        getem(skid, skill)
        dumpem()
        for k,v in pairs(filtered) do
            filtered[k] = nil
        end
    end
end

