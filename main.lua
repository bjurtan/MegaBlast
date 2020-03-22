-- FILE: main.lua

--[[
In order for Love2d to compile on my old version of Xcode I had to comment out
parts of common/ios.mm at the very end of the file.
The if (@available.. block right at the end..
--]]

debug = true

local moonshine = require 'moonshine'

require "starfield"     -- starfield animation used on both menu and game
require "menu"          -- menu code, start the game, high score etc
require "game"          -- game logic, score, level etc
require "player"        -- player object, state variables and functions
require "enemy"         -- enemy object, state variables and functions

buffer = love.graphics.newCanvas(screenWidth, screenHeight)

-------------------------------------------------------------------
-- callback keypressed
-------------------------------------------------------------------
function love.keypressed(key)
    if key == 'escape' then
        if game.menu then
            love.event.push('quit')
        else
            game.menu = true
        end
    elseif key == 'return' then
        if game.over then
            game.menu=true
            -- re-initialize the game
            game_init()
            player_init()
            enemy_init()
        else
            game.menu = false
        end
    end
end

-------------------------------------------------------------------
-- callback mousepressed
-------------------------------------------------------------------
function love.mousepressed(x, y, button, istouch)
    if game.menu then
        game.menu = false
        player_init()
    elseif game.over then
        game.over = false
        game_init()
        enemy_init()
        player_init()
    end
end

-------------------------------------------------------------------
-- callback touchpressed
-------------------------------------------------------------------
function love.touchpressed(id, x, y, dx, dy, pressure)
    if game.menu then
        game.menu = false
        player_init()
    elseif game.over then
        game.over = false
        game_init()
        enemy_init()
        player_init()
    end
end

-------------------------------------------------------------------
-- Load
-------------------------------------------------------------------
function love.load(arg)

	--effect = moonshine(moonshine.effects.filmgrain).chain(moonshine.effects.vignette)
	effect = moonshine(moonshine.effects.fastgaussianblur)


    --screenRatio = love.graphics.getHeight() / love.graphics.getWidth()
    --screenWidth = 1024
    --screenHeight = screenWidth * screenRatio
    screenRatio = love.graphics.getPixelWidth() / love.graphics.getPixelHeight()
    screenHeight = 600
    screenWidth = screenHeight * screenRatio

    --scale = love.graphics.getWidth() / screenWidth
    --scale = love.graphics.getPixelHeight() / screenHeight
    screenScale = love.graphics.getHeight() / screenHeight

    starfield_init()
    menu_init()
    game_init()
    enemy_init()
    player_init()
    --highscore_init()

end

-------------------------------------------------------------------
-- Update
-------------------------------------------------------------------
function love.update(dt)
    -- takes dt (delta time = time since last update).
    starfield_update(dt)
    if game.menu then
       menu_update(dt) 
    else
        game_update(dt) -- update game states.
        player_update(dt)
        enemy_update(dt)
    end
end


-------------------------------------------------------------------
-- Draw
-------------------------------------------------------------------
function love.draw(dt)

    -- This function activates the off-screen canvas for drawing and
    -- then clears it. This will cause all subsequent calls to the draw
    -- function of love2d to draw to the canvas avoiding screen memory
    -- access until all game objects are rendered to the canvas. Then
    -- the canvas screen is set to active canvas and the off-screen
    -- buffer is drawn to the screen.
    
    love.graphics.setCanvas(buffer)
    love.graphics.clear()

    love.mouse.setVisible(false) -- hide mouse cursor


    effect(function() -- Applies shader effect to all things drawn within
    
        love.graphics.push()
    	love.graphics.scale(screenScale, screenScale)
    	
    	starfield_draw(dt)
    	if game.menu then
        	menu_draw(dt)
    	else
        	player_draw()
        	enemy_draw()
        	game_draw()
    	end
    	
    	love.graphics.pop() -- Restor graphics after scaling

    end)

    -- draw screen resolution and fps
    --love.graphics.print("Resolution: " .. love.graphics.getPixelWidth() .. "*" .. love.graphics.getPixelHeight() .. " | Scale: " .. scale, 10, 20)


    love.graphics.setCanvas()
    love.graphics.draw(buffer)

end
