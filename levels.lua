-- FILE: levels.lua


----------------------------------------------------------
-- level globals
----------------------------------------------------------
levels = {}

----------------------------------------------------------
-- level_init()
----------------------------------------------------------
-- This function initialized level building stuff. After
-- initializing 
----------------------------------------------------------
function level_init()
    
    --[[
        Initialize level 1. Subsequent levels will be generated on the fly
        based on fixed incremets and some randomization of paramaters..

        Each level is addedd to levels table.insert(levels, _level)
        game.level can be used as an index to table levels[game.level]
        setting game.level can be done by game.level=#levels
    ]]

    -- level:               1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25
    levels.scouts =       {20,12,10, 6, 4, 0, 0, 0, 0,10, 6, 6, 6, 2, 0, 0, 0, 4, 0, 0, 0, 0, 0,30,10}
    levels.fighters =     { 0, 8,10,16,16, 0, 0, 0, 0,10, 6, 6, 6, 2, 0, 0, 0, 4, 0, 0, 0, 0, 0,30,10}
    levels.bombers =      { 0, 0, 0, 4, 8, 0, 0, 0, 0, 0, 6, 6, 6, 2, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0}
    levels.commanders =   { 0, 0, 0, 0, 4, 0, 0, 0, 0, 0, 6, 6, 6, 2, 0, 0, 0, 4, 0, 0, 0, 0, 0, 0, 0}
    levels.megablasters = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
    
    levels.enemies = levels.scouts[game.level] + levels.fighters[game.level] + levels.bombers[game.level] + levels.commanders[game.level] + levels.megablasters[game.level]

end


----------------------------------------------------------
-- level_udate()
----------------------------------------------------------
-- This function will check status and decide if it is time
-- for a game level progression. If so, 
----------------------------------------------------------
function level_update()

    -- check if all enemies of the level has been destroyed

end

----------------------------------------------------------
-- level_next()
----------------------------------------------------------
-- This function plays level change animation, keeps track
-- of level progression and finally sets flag done = true.
-- When level change animation completes it will start the
-- next level.
----------------------------------------------------------
function level_next()

    -- time for next level, create new level and push onto
    -- levels table and set game.level to #levels

end

