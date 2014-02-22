-- list contents of a stockpile.

local utils = require 'utils'
local gui = require 'gui'
local guidm = require 'gui.dwarfmode'
local args = {...}

local stockpile = dfhack.gui.getSelectedBuilding(true)
if not stockpile then
    qerror('Select a stockpile in Q mode.')
end
if getmetatable(stockpile) ~= 'building_stockpilest' then
    qerror('Select a stockpile in Q mode.')
end

local contents = {}
local i=1
for uid,item in pairs(df.global.world.items.all) do
    if item.pos.z == stockpile.z
            and item.pos.x >= stockpile.x1
            and item.pos.x <= stockpile.x2
            and item.pos.y >= stockpile.y1
            and item.pos.y <= stockpile.y2
            and not item.flags.in_inventory then
        local b = dfhack.buildings.findAtTile(item.pos)
        if b == stockpile then
            contents[i] = item
            i = i + 1
        end
    end
end

if #contents == 0 then
    qerror('Empty stockpile, nothing to do.')
end

ItemList = defclass(ItemList, guidm.MenuOverlay)
ItemList.focus_path = 'item-list'
ItemList.ATTRS{ }

function ItemList:init(info)
    self.scrollTop = 1
    self.curItem = 1
    self.old_viewport = self:getViewport()
    self.old_cursor = guidm.getCursorPos()
end

function ItemList:getListSize()
    local w,h = self:getWindowSize()
    return h - 5
end

function ItemList:onRenderBody(dc)
    local ls = self:getListSize()

    dc:clear():seek(1,1)
    dc:pen(COLOR_WHITE)
    local n = utils.getBuildingName(stockpile)
    dc:string(n)
    dc:newline():newline(1)

    for i,item in pairs(contents) do
        if i >= self.scrollTop and i < self.scrollTop+ls then
            dc:pen(COLOR_MAGENTA):char(item.flags.forbid and 'F' or ' ')
            dc:pen(COLOR_GREEN):char(item.flags.dump and 'D' or ' ')
            dc:pen(COLOR_RED):char(item.flags.melt and 'M' or ' ')
            dc:advance(1)
            dc:pen{ fg=COLOR_GREY, bold=(i==self.curItem) }
            dc:string(dfhack.items.getDescription(item, 0, true))
            dc:newline(1)
        end
    end
end

function ItemList:checkScroll()
    if self.curItem < 1 then
        self.curItem = 1
    end
    if self.curItem < self.scrollTop then
        self.scrollTop = self.curItem
    end
    if self.curItem > #contents then
        self.curItem = #contents
    end
    if self.curItem >= self.scrollTop + self:getListSize() then
        self.scrollTop = self.curItem - self:getListSize() + 1
    end
end

function ItemList:onInput(keys)
    if keys.SECONDSCROLL_UP then
        self.curItem = self.curItem - 1
        self:checkScroll()
    elseif keys.SECONDSCROLL_DOWN then
        self.curItem = self.curItem + 1
        self:checkScroll()
    elseif keys.SECONDSCROLL_PAGEUP then
        self.curItem = self.curItem - 10
        self:checkScroll()
    elseif keys.SECONDSCROLL_PAGEDOWN then
        self.curItem = self.curItem + 10
        self:checkScroll()

    elseif keys.ITEM_FORBID then
        dfhack.println('Toggle forbid on ' .. dfhack.items.getDescription(contents[self.curItem], 0))
        contents[self.curItem].flags.forbid = not contents[self.curItem].flags.forbid

    elseif keys.ITEM_DUMP then
        dfhack.println('Toggle dump on ' .. dfhack.items.getDescription(contents[self.curItem], 0))
        contents[self.curItem].flags.dump = not contents[self.curItem].flags.dump

    elseif keys.ITEM_MELT then
        dfhack.println('Toggle melt on ' .. dfhack.items.getDescription(contents[self.curItem], 0))
        contents[self.curItem].flags.melt = not contents[self.curItem].flags.melt

    elseif keys.SELECT then
        dfhack.println(dfhack.items.getDescription(contents[self.curItem], 0))
        --[[
        for k,v in pairs(contents[self.curItem].flags) do
            dfhack.println(string.format('%15s: %s', k, (v and 'Y' or 'N')))
        end
        ]]--

    elseif keys.LEAVESCREEN then
        self:dismiss()
    elseif self:simulateViewScroll(keys) then
        return
    end

    --[[
    for k,v in pairs(keys) do
        dfhack.println(k)
    end
    ]]--
end

ItemList{}:show()

--expandtab autoindent sw=4 ts=4
