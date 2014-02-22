-- Dig a 5x5 square around the cursor.

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local utils = require 'utils'
local guidm = require 'gui.dwarfmode'
local jldf = require 'jldf'
local args = {...}

if not string.match(dfhack.gui.getCurFocus(), 'DesignateMine') then
    qerror('Go to Designations->Mine mode before running this script')
end

local cpos = guidm.getCursorPos()
local cx,cy,cz = pos2xyz(cpos)

for y=cy-2,cy+2 do
    for x=cx-2,cx+2 do
        designation,occupancy = dfhack.maps.getTileFlags(x,y,cz)
        if dfhack.maps.isValidTilePos(x,y,cz) and designation.hidden then
            designation.dig=1
        end
    end
end

