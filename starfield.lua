-- FILE: starfield.lua

--[[
    This file implements the starfield animation of the game. love.update/draw etc
    from main.lua calls this files update/draw functions andf then used in bot
    the menu and the game itself.
]]


function starfield_init()
    -- load up star images
    star1 = love.graphics.newImage("assets/star1.png")
    star2 = love.graphics.newImage("assets/star2.png")
    star3 = love.graphics.newImage("assets/star3.png")  

    -- Set star field star count
    nStars1 = 60
    nStars2 = 40
    nStars3 = 20
    offsetLayer1 = 0
    offsetLayer2 = 0
    offsetLayer3 = 0

    -- generate star fields
    starsLayer1 = {}
    for i = 1,nStars1 do
        starsLayer1[i] = {}
        starsLayer1[i].x = math.random()*screenWidth
        starsLayer1[i].y = math.random()*screenHeight
    end
    starsLayer2 = {}
    for i = 1,nStars2 do
        starsLayer2[i] = {}
        starsLayer2[i].x = math.random()*screenWidth
        starsLayer2[i].y = math.random()*screenHeight
    end
    starsLayer3 = {}
    for i = 1,nStars3 do
        starsLayer3[i] = {}
        starsLayer3[i].x = math.random()*screenWidth
        starsLayer3[i].y = math.random()*screenHeight
    end
end


function starfield_update(dt)
    offsetLayer1 = (offsetLayer1 + 50 * dt) % screenWidth
    offsetLayer2 = (offsetLayer2 + 100 * dt) % screenWidth
    offsetLayer3 = (offsetLayer3 + 150 * dt) % screenWidth
end

function starfield_draw(dt)
    for i = 1,nStars1 do
        local thisY = (starsLayer1[i].y + offsetLayer1) % screenWidth
        local thisX = starsLayer1[i].x
        love.graphics.draw(star3,thisX,thisY)
    end
    for i = 1,nStars2 do
        local thisY = (starsLayer2[i].y + offsetLayer2) % screenWidth
        local thisX = starsLayer2[i].x
        love.graphics.draw(star2,thisX,thisY)
    end
    for i = 1,nStars3 do
        local thisY = (starsLayer3[i].y + offsetLayer3) % screenWidth
        local thisX = starsLayer3[i].x
        love.graphics.draw(star1,thisX,thisY)
    end
end
