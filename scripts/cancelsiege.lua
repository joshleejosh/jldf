-- Cancel active invasions
-- Useful in a rare situation when all invaders leave, but the siege flag won't clear

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end
local utils = require 'utils'
local jldf = require 'jldf'
local args = {...}


for ik,invasion in pairs(df.global.ui.invasions.list) do
    if invasion.flags.active and invasion.flags.siege then
        dfhack.println('invasion: ' .. ik)
        civ = df.historical_entity.find(invasion.civ_id)
        dfhack.println('    ' .. dfhack.TranslateName(civ.name))
        dfhack.println('    ' .. invasion.active_size1 .. ' / ' .. invasion.active_size2 .. ' / ' .. invasion.size)
        dfhack.println('    ' .. invasion.duration_counter)
        --jldf.dump(invasion, 0)
        invasion.flags.active = false
    end
end

