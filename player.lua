-- FILE: player.lua

-------------------------------------------------------------------
-- init player
-------------------------------------------------------------------
function player_init()
        
    player = {} -- new table/dict to hold player data and assign it tot variable player

    player.dead = false
    player.explosion = 0
    player.next_explosion = 0
    player.image = love.graphics.newImage("assets/player2.png")
    player.pos_x = screenWidth / 2
    player.pos_y = screenHeight / 1.2
    player.width = player.image:getWidth()   -- for collition detection etc
    player.height = player.image:getHeight()
    player.speed = 200 -- pixels per second
    player.speed_booster_powerup_expiration=0
    player.rate_of_fire = 0.2 -- 0.2 = 5 blasts /second. Upgrades available later in game?
    player.rapid_fire_powerup_expiration=0
    player.shield = false
    player.shield_image = love.graphics.newImage("assets/player_shield.png")
    player.last_shot = love.timer.getTime()
    player.collision_box = { {22,22,6,4}, {0,0,36,6} }
    player.blasts = {}

    blast_image = love.graphics.newImage("assets/player_blast.png")
    blast_sound = love.audio.newSource("assets/Laser_Shoot3.wav", "static")
    player_hit_sound = love.audio.newSource("assets/player_hit.wav", "static")

    -- uses explosion1-4 from enemy.lua
    
end



-------------------------------------------------------------------
-- shoot player blast
-------------------------------------------------------------------
function player_shoot()
    local _shot = love.timer.getTime()
    if _shot > (player.last_shot + player.rate_of_fire) then
        player.last_shot = _shot
        local blast = {}
        blast.pos_x = player.pos_x + 23 -- player width / 2 - blast width / 2
        blast.pos_y = player.pos_y
        blast.width = 8
        blast.height = 10
        blast.velocity = (math.random()*50)+300
        table.insert(player.blasts, blast)
        blast_sound:stop()
        blast_sound:play()
    end
end



-------------------------------------------------------------------
-- update player blast
-------------------------------------------------------------------
function player_update_blasts(dt)

    local _remove_blasts = {} -- local variable initialized (empty) each time

    if #player.blasts > 0 then
        for i=1,#player.blasts do

            -- subtract from blast y position until lt 0 then remote blast from array
            player.blasts[i].pos_y = player.blasts[i].pos_y - player.blasts[i].velocity*dt

            -- Delete blast if outside screen
            if player.blasts[i].pos_y < 0 then
                table.insert(_remove_blasts, i) -- put player.blasts index to be reoved in _remove_blasts table
            end

            -- check for collision with enemies
            for j=1,#enemies do

                -- check for collision with enemies
                for k=1,#enemies[j].collision_box do
                    if player.blasts[i].pos_x + player.blasts[i].width > enemies[j].pos_x + enemies[j].collision_box[k][1] and
                    player.blasts[i].pos_x < enemies[j].pos_x + enemies[j].width - enemies[j].collision_box[k][2] and
                    player.blasts[i].pos_y + player.blasts[i].height > enemies[j].pos_y + enemies[j].collision_box[k][3] and
                    player.blasts[i].pos_y < enemies[j].pos_y + enemies[j].height - enemies[j].collision_box[k][4] then
                        enemies[j].dead = true
                        game.score = game.score + enemies[j].points
                        player_hit_sound:stop()
                        player_hit_sound:play()
                        table.insert(_remove_blasts, i)
                    end
                end
            end
        end

        for i=1,#_remove_blasts do -- loop through player_blast indexs to be removed
            table.remove(player.blasts, _remove_blasts[i]) -- ..and remove them from the table
        end

    end
end



-------------------------------------------------------------------
-- update player
-------------------------------------------------------------------
function player_update(dt)

    -- is player alive?
    if player.dead==false then

        -- player still alive
        local _now = love.timer.getTime()

        -- checking keyboard player keyboard input.
        --[[
        if love.keyboard.isDown("right") then
            player.pos_x = player.pos_x + (player.speed * dt)
        end
        if love.keyboard.isDown("left") then
            player.pos_x = player.pos_x - (player.speed * dt)
        end
        if love.keyboard.isDown("up") then
            player.pos_y = player.pos_y - (player.speed * dt)
        end
        if love.keyboard.isDown("down") then
            player.pos_y = player.pos_y + (player.speed * dt)
        end
        -- did player shoot?
        if love.keyboard.isDown("space") then
            player_shoot()        
        end
        ]]

        -- check mouse position
        player.pos_x, player.pos_y = love.mouse.getPosition()
        player.pos_x = player.pos_x / screenScale - 27
        player.pos_y = player.pos_y / screenScale - 54 -- make player image rest above touch point for visibility
        -- check mouse button
        if love.mouse.isDown(1) then
            player_shoot()
        end
        
        -- check touch position
        --[[
        local _touches = love.touch.getTouches()
        for i, id in ipairs(_touches) do
            player.pos_x, player.pos_y = love.touch.getPosition(id)
            player.pos_x = player.pos_x / screenScale - 27
            player.pos_y = player.pos_y / screenScale - 54 -- make player image rest above touch point for visibility
            player_shoot()
        end
        ]]

        -- correct player out of bounds
        if player.pos_x < 0 then
            player.pos_x = 0
        elseif player.pos_x > screenWidth - 54 then
            player.pos_x = screenWidth - 54
        end
        if player.pos_y < 0 then
            player.pos_y = 0
        elseif player.pos_y > screenHeight - 48 then
            player.pos_y = screenHeight - 48
        end
    
        -- check powerup expiration
        if player.rapid_fire_powerup_expiration~=0 and player.rapid_fire_powerup_expiration < _now then
            -- rapid fire powerup has expired
            player.rate_of_fire=player.rate_of_fire*2
            player.rapid_fire_powerup_expiration=0
        else
            -- draw powerup hud in game.lua
        end
        if player.speed_booster_powerup_expiration~=0 and player.speed_booster_powerup_expiration < _now then
            -- rapid fire powerup has expired
            player.speed=player.speed/2
            player.speed_booster_powerup_expiration=0
        else
            -- draw powerup hud in game.lua
        end

    end

    -- update blasts
    player_update_blasts(dt)

end



-------------------------------------------------------------------
-- player hit
-------------------------------------------------------------------
function player_hit()   -- maybe add type of munitions player is hit with?
    -- todo
    player_hit_sound:stop()
    player_hit_sound:play()

    if player.shield then
        player.shield = false
    else
        player.dead = true
    end
end



-------------------------------------------------------------------
-- draw player
-------------------------------------------------------------------
function player_draw()

    local _now = love.timer.getTime()

    if player.dead then
        -- check which explosion image to draw
        if player.explosion == 0 then
            if _now > player.next_explosion then
                player.explosion = 1
                player.next_explosion = (_now + 0.1)
            end
            love.graphics.draw(explosion1, player.pos_x, player.pos_y)
        elseif player.explosion == 1 then
            if _now > player.next_explosion then
                player.explosion = 2
                player.next_explosion = (_now + 0.1)
            end
            love.graphics.draw(explosion2, player.pos_x, player.pos_y)
        elseif player.explosion == 2 then
            if _now > player.next_explosion then
                player.explosion = 3
                player.next_explosion = (_now + 0.1)
            end
            love.graphics.draw(explosion3, player.pos_x, player.pos_y)
        elseif player.explosion == 3 then
            if _now > player.next_explosion then
                player.explosion = 4
                player.next_explosion = (_now + 0.1)
            end
            love.graphics.draw(explosion4, player.pos_x, player.pos_y)
        elseif player.explosion == 4 then
            game.over=true
            game.ended=_now
        end
    else
        love.graphics.draw(player.image,player.pos_x,player.pos_y)
        if player.shield == true then
            love.graphics.draw(player.shield_image,player.pos_x-5,player.pos_y-1)
        end
    end
    
    for i=1,#player.blasts do
        love.graphics.draw(blast_image, player.blasts[i].pos_x, player.blasts[i].pos_y)
    end

end

