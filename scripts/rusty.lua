-- Check whether dwarves are rusty in any important labors.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local citizens = {}
local numAdults = 0
local numLegends = 0

for uid,unit in pairs(df.global.world.units.all) do
    if dfhack.units.isCitizen(unit) and dfhack.units.isAlive(unit) then
        citizens[uid] = unit
    end
end

labors = {
    [0]="Mining",
    [1]="Wood Cutting",
    [2]="Carpentry",
    [3]="Engraving",
    [4]="Masonry",
    --[5]="Animal Training",
    --[6]="Animal Caretaking",
    --[7]="Fish Dissection",
    --[8]="Animal Dissection",
    [9]="Fish Cleaning",
    [10]="Butchery",
    [11]="Trapping",
    [12]="Tanning",
    [13]="Weaving",
    [14]="Brewing",
    --[15]="Alchemy",
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
    --[38]="Axe",
    --[39]="Sword",
    --[40]="Knife",
    --[41]="Mace",
    --[42]="Hammer",
    --[43]="Spear",
    [44]="Crossbow",
    --[45]="Shield",
    --[46]="Armor",
    --[47]="Siege Engineering",
    --[48]="Siege Operation",
    [49]="Bowmaking",
    --[50]="Pike",
    --[51]="Lash",
    --[52]="Bow",
    --[53]="Blowgun",
    --[54]="Throwing",
    [55]="Machinery",
    --[56]="Nature",
    --[57]="Ambush",
    [58]="Building Design",
    [59]="Wound Dressing",
    [60]="Diagnostics",
    [61]="Surgery",
    [62]="Bone Setting",
    [63]="Suturing",
    --[64]="Crutch-walking",
    [65]="Wood Burning",
    [66]="Lye Making",
    [67]="Soap Making",
    [68]="Potash Making",
    [69]="Dyeing",
    --[70]="Pump Operation",
    --[71]="Swimming",
    --[72]="Persuasion",
    --[73]="Negotiation",
    --[74]="Judging Intent",
    --[75]="Appraisal",
    --[76]="Organization",
    --[77]="Record Keeping",
    --[78]="Lying",
    --[79]="Intimidation",
    --[80]="Conversation",
    --[81]="Comedy",
    --[82]="Flattery",
    --[83]="Consoling",
    --[84]="Pacification",
    --[85]="Tracking",
    --[86]="Studying",
    --[87]="Concentration",
    --[88]="Discipline",
    --[89]="Observation",
    --[90]="Writing",
    --[91]="Prose",
    --[92]="Poetry",
    --[93]="Reading",
    --[94]="Speaking",
    --[95]="Coordination",
    --[96]="Balance",
    --[97]="Leadership",
    --[98]="Teaching",
    --[99]="Fighting",
    --[100]="Archery",
    --[101]="Wrestling",
    --[102]="Biting",
    --[103]="Striking",
    --[104]="Kicking",
    --[105]="Dodging",
    --[106]="Misc. Object",
    --[107]="Knapping",
    --[108]="Military Tactics",
    [109]="Shearing",
    [110]="Spinning",
    [111]="Pottery",
    [112]="Glazing",
    [113]="Pressing",
    [114]="Beekeeping",
    [115]="Wax Working",
}

legends={}
losers={}

for uid,unit in pairs(citizens) do
    local doit = false
    local lskills = {}
    local age = dfhack.units.getAge(unit)

    if age >= 12 then
        dfhack.println(string.format("%03s %-20s %-20s", uid, 
            dfhack.TranslateName(unit.name),
            dfhack.units.getProfessionName(unit)))
        for vid,vitem in pairs(unit.status.current_soul.skills) do
            if labors[vitem.id] then
                -- Rusty:   (0 < rating < 4) && (rating * 0.5 < rusty)
                -- V Rusty: (rating >= 4) && (rating * 0.75 < rusty)
                local effectiveRating = math.max(vitem.rating - vitem.rusty, 0)

                local tag = ' '
                if (vitem.rating > 1 and vitem.demotion_counter > 13) then
                    tag = '!'
                elseif (vitem.rating > 6 and effectiveRating == 0) then
                    tag = '?'
                end

                if delta ~= 0 and vitem.rating > 0 and vitem.rusty > 0 then
                    local str = string.format("   %3s %-17s: %02d - %02d = %02d [%02d %02d %02d] %s"
                            ,vitem.id
                            ,df.job_skill.attrs[vitem.id].caption
                            ,vitem.rating
                            ,vitem.rusty
                            ,effectiveRating
                            ,vitem.unused_counter
                            ,vitem.rust_counter
                            ,vitem.demotion_counter
                            ,tag
                            )
                    dfhack.println(str)
                end
            end
        end
    end
end


