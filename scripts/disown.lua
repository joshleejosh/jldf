-- Remove the owner from the selected item

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local foc = dfhack.gui.getCurFocus()
local item = dfhack.gui.getSelectedItem(true)

if not item then
    qerror("Item not selected")
end

dfhack.println(item.id .. ' ' .. getmetatable(item))
owner = dfhack.items.getOwner(item)
if not owner then
    qerror("Item has no owner")
end
dfhack.println('Owner: ' ..  dfhack.TranslateName(owner.name))

dfhack.items.setOwner(item, nil)

owner = dfhack.items.getOwner(item)
if owner then
    dfhack.println('Disown failed, owner is still ' ..  dfhack.TranslateName(owner.name))
else
    dfhack.println('Disowned.')
end

