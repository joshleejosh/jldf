-- Inventory the textile industry (plants, thread, dye, cloth)

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local qualities = { ' ', '-', '+', '*', '=', '☼', 'A', '<' }
local dyed = 0
local undyed = 0
local plants = {}
local dyes = {}
local threads = {}
local cloths = {}
local clothCategories = {}
local hides = 0

for uid,item in pairs(df.global.world.items.all) do
    local mt = getmetatable(item)
    if mt == 'item_plantst' then
        local desc = dfhack.items.getDescription(item, 1)
        if plants[desc] == nil then
            plants[desc] = 0
        end
        plants[desc] = plants[desc] + item.stack_size

    elseif mt == 'item_powder_miscst' then
        local desc = dfhack.items.getDescription(item, 1)
        local mattok = dfhack.matinfo.getToken(item.mat_type, item.mat_index)
        local subtok = string.gsub(mattok, ':.*$', '')
        if subtok == 'PLANT' then
            if dyes[desc] == nil then
                dyes[desc] = 0
            end
            dyes[desc] = dyes[desc] + item.stack_size
        end

    elseif mt == 'item_threadst' and not item.flags.forbid and not item.flags.spider_web then
        local desc = dfhack.items.getDescription(item, 1)
        if threads[desc] == nil then
            threads[desc] = 0
        end
        threads[desc] = threads[desc] + item.stack_size

        if item.dye_mat_type ~= -1 then
            --[[
            local mattok = dfhack.matinfo.getToken(item.mat_type, item.mat_index)
            local dyetok = dfhack.matinfo.getToken(item.dye_mat_type, item.dye_mat_index)
            dfhack.println('thread '
                    .. ' ' .. mattok
                    .. '\t' .. dyetok
                    .. ' ' .. qualities[item.dye_quality+1]
                    )
            ]]--
            dyed = dyed + item.stack_size
        else
            undyed = undyed + item.stack_size
            --dfhack.println('thread ' .. ' ' ..  mattok)
        end

    elseif mt == 'item_clothst' then
        local desc = dfhack.items.getDescription(item, 1)
        if cloths[desc] == nil then
            cloths[desc] = 0
        end
        cloths[desc] = cloths[desc] + item.stack_size

        local mattok = dfhack.matinfo.getToken(item.mat_type, item.mat_index)
        local subtok = string.gsub(mattok, '^.*:', '')
        if clothCategories[subtok] == nil then
            clothCategories[subtok] = 0
        end
        clothCategories[subtok] = clothCategories[subtok] + item.stack_size

    elseif mt == 'item_skin_tannedst' then
        hides = hides + item.stack_size

    end
end

dfhack.println('          PT  RR  DC  HR  BW')
dfhack.println(string.format('PLANTS:  %3d %3d %3d %3d %3d',
            plants['pig tail'] or 0,
            plants['rope reed'] or 0,
            plants['dimple cup'] or 0,
            plants['hide root'] or 0,
            plants['blade weed'] or 0
            ))

dfhack.println(string.format('THREADS: %3d %3d',
            threads['pig tail fiber thread'] or 0,
            threads['rope reed fiber thread'] or 0))
dfhack.println(string.format('DYES:            %3d %3d %3d',
            dyes['dimple dye'] or 0,
            dyes['redroot dye'] or 0,
            dyes['emerald dye'] or 0
            ))
dfhack.println(string.format('CLOTHS:  %3d %3d',
            cloths['pig tail fiber cloth'] or 0,
            cloths['rope reed fiber cloth'] or 0))
dfhack.println('')

--dfhack.println(string.format('\nDyed vs Undyed thread: %d / %d\n', dyed, undyed))

dfhack.println('Threads:')
for cid,ccount in pairs(threads) do
    dfhack.println(string.format('  %-16s: %d', string.gsub(cid, ' thread', ''), ccount))
end

dfhack.println('Dyes:')
for did,dcount in pairs(dyes) do
    if string.match(did, 'dye') then
        dfhack.println(string.format('  %-16s: %d', string.lower(string.gsub(did, ' dye', '')), dcount))
    end
end

dfhack.println('Cloths:')
for cid,ccount in pairs(clothCategories) do
    dfhack.println(string.format('  %-16s: %d', string.lower(string.gsub(cid, ' cloth', '')), ccount))
end
dfhack.println(string.format('  %-16s: %d', 'hide', hides))

