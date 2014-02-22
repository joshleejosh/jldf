-- Inventory agriculture and derived products.

local utils = require 'utils'
local args = {...}

if not dfhack.isMapLoaded() then
    qerror('Map is not loaded.')
end

local plants = {
    ['BERRIES_PRICKLE']={},
    ['BERRIES_STRAW_WILD']={},
    ['BERRIES_FISHER']={},
    ['BUSH_QUARRY']={},
    ['GRASS_LONGLAND']={},
    ['GRASS_TAIL_PIG']={},
    ['GRASS_WHEAT_CAVE']={},
    ['MUSHROOM_CUP_DIMPLE']={},
    ['MUSHROOM_HELMET_PLUMP']={},
    ['POD_SWEET']={},
    ['REED_ROPE']={},
    ['ROOT_HIDE']={},
    ['WEED_BLADE']={},
    ['WEED_RAT']={},
}

function guessPlant(item)
    local mattok = dfhack.matinfo.getToken(item.mat_type, item.mat_index)
    local subtok = string.gsub(mattok, 'PLANT:([^:]*):.*$', '%1')
    return subtok
end

function addProduct(item, productLabel)
    local pname = guessPlant(item)
    if plants[pname] then
        if not plants[pname][productLabel] then
            plants[pname][productLabel] = 0
        end
        plants[pname][productLabel] = plants[pname][productLabel] + item.stack_size
    end
end

for uid,item in pairs(df.global.world.items.all) do
    local mt = getmetatable(item)

    if mt == 'item_plantst' then
        local desc = string.lower(dfhack.items.getDescription(item, 1))
        local pname = guessPlant(item)
        if not plants[pname] then
            dfhack.println('oops, unsupported plant type: ' .. pname)
        else
            if not plants[pname].description then
                plants[pname].description = desc
            end
            if not plants[pname].quantity then
                plants[pname].quantity = 0
            end
            plants[pname].quantity = plants[pname].quantity + item.stack_size
        end

    elseif mt == 'item_leavesst' then
        addProduct(item, 'leaves')

    elseif mt == 'item_powder_miscst' then
        addProduct(item, 'dyes')

    elseif mt == 'item_drinkst' then
        addProduct(item, 'drinks')

    elseif mt == 'item_threadst' and not item.flags.forbid and not item.flags.spider_web then
        addProduct(item, 'thread')

    elseif mt == 'item_clothst' then
        addProduct(item, 'cloth')

    elseif mt == 'item_seedsst' then
        addProduct(item, 'seeds')


    end
end

--[[
for pid,p in pairs(plants) do
    dfhack.println(string.format('%4d %s', p.quantity or 0, p.description))
    for rid,r in pairs(p) do
        if rid ~= 'quantity' and rid ~= 'description' then
            dfhack.println(string.format('         %d %s', r, rid))
        end
    end
end
]]--

function fmtChain(q1, d1, q2, d2, q3, d3, q4, d4)
    fs = '%4d %-16s'
    s = ''
    if d1 ~= nil then
        if d1 == ' ' then
            s = '                     '
        else
            s = string.format(fs, q1 or 0, d1)
        end
    end
    if d2 ~= nil then
        if d2 == ' ' then
            s = s .. '                         '
        else
            s = s .. string.format(' -> ' .. fs, q2 or 0, d2)
        end
    end
    if d3 ~= nil then
        if d3 == ' ' then
            s = s .. '                         '
        else
            s = s .. string.format(' -> ' .. fs, q3 or 0, d3)
        end
    end
    if d4 ~= nil then
        if d4 == ' ' then
            s = s .. '                         '
        else
            s = s .. string.format(' -> ' .. fs, q4 or 0, d4)
        end
    end
    dfhack.println(s)
end

fmtChain(plants.BUSH_QUARRY.seeds           , 'rock nuts'  , plants.BUSH_QUARRY.quantity           , 'quarry bush'     , plants.BUSH_QUARRY.leaves           , 'leaves')

fmtChain(plants.MUSHROOM_HELMET_PLUMP.seeds , 'p.h. spawn' , plants.MUSHROOM_HELMET_PLUMP.quantity , 'plump helmet'    , plants.MUSHROOM_HELMET_PLUMP.drinks , 'dwarven wine')
fmtChain(plants.GRASS_WHEAT_CAVE.seeds      , 'c.w. seeds' , plants.GRASS_WHEAT_CAVE.quantity      , 'cave wheat'      , plants.GRASS_WHEAT_CAVE.drinks      , 'dwarven beer')
fmtChain(nil                                , ' '          , nil                                   , ' '               , plants.GRASS_WHEAT_CAVE.dyes        , 'cave wheat flour')
fmtChain(plants.POD_SWEET.seeds             , 's.p. seeds' , plants.POD_SWEET.quantity             , 'sweet pod'       , plants.POD_SWEET.drinks             , 'dwarven rum')
fmtChain(nil                                , ' '          , nil                                   , ' '               , plants.POD_SWEET.dyes               , 'dwarven sugar')
fmtChain(plants.BERRIES_STRAW_WILD.seeds    , 'w.s. seeds' , plants.BERRIES_STRAW_WILD.quantity    , 'wild s\'berries' , plants.BERRIES_STRAW_WILD.drinks    , 'strawberry wine')
fmtChain(plants.BERRIES_PRICKLE.seeds       , 'p.b. seeds' , plants.BERRIES_PRICKLE.quantity       , 'prickle berries' , plants.BERRIES_PRICKLE.drinks       , 'prickle berry wine')
fmtChain(plants.BERRIES_FISHER.seeds        , 'f.b. seeds' , plants.BERRIES_FISHER.quantity        , 'fisher berries'  , plants.BERRIES_FISHER.drinks        , 'fisher berry wine')
fmtChain(plants.WEED_RAT.seeds              , 'r.w. seeds' , plants.WEED_RAT.quantity              , 'rat weed'        , plants.WEED_RAT.drinks              , 'sewer brew')
fmtChain(plants.GRASS_LONGLAND.seeds        , 'l.g. seeds' , plants.GRASS_LONGLAND.quantity        , 'longland grass'  , plants.GRASS_LONGLAND.drinks        , 'longland beer')
fmtChain(nil                                , ' '          , nil                                   , ' '               , plants.GRASS_LONGLAND.dyes          , 'longland flour')

fmtChain(plants.GRASS_TAIL_PIG.seeds        , 'p.t. seeds' , plants.GRASS_TAIL_PIG.quantity        , 'pig tail'        , plants.GRASS_TAIL_PIG.drinks        , 'dwarven ale')
fmtChain(nil                                , ' '          , nil                                   , ' '               , plants.GRASS_TAIL_PIG.thread        , 'p.t. thread'           , plants.GRASS_TAIL_PIG.cloth , 'cloth')
fmtChain(plants.REED_ROPE.seeds             , 'r.r. seeds' , plants.REED_ROPE.quantity             , 'rope reed'       , plants.REED_ROPE.drinks             , 'river spirits')
fmtChain(nil                                , ' '          , nil                                   ,' '                , plants.REED_ROPE.thread             , 'r.r. thread'           , plants.REED_ROPE.cloth      , 'cloth')

fmtChain(plants.MUSHROOM_CUP_DIMPLE.seeds   , 'd.c. spawn' , plants.MUSHROOM_CUP_DIMPLE.quantity   , 'dimple cup'      , plants.MUSHROOM_CUP_DIMPLE.dyes     , 'dimple dye')
fmtChain(plants.ROOT_HIDE.seeds             , 'h.r. seeds' , plants.ROOT_HIDE.quantity             , 'hide root'       , plants.ROOT_HIDE.dyes               , 'redroot dye')
fmtChain(plants.WEED_BLADE.seeds            , 'b.w. seeds' , plants.WEED_BLADE.quantity            , 'blade weed'      , plants.WEED_BLADE.dyes              , 'emerald dye')

