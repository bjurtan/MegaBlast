-- FILE: player.lua

-------------------------------------------------------------------
-- init player
-------------------------------------------------------------------
function player_init(selected_ship)
    
    player = {} -- new table/dict to hold player data and assign it to variable player

    player.dead = false
    player.health = 100
    player.explosion = 0
    player.next_explosion = 0
    player.pos_x = 240
    player.pos_y = 340
    player.speed = 200 -- pixels per second used when keyboard controls player. Not used now.
    player.speed_booster_powerup_expiration=0 -- has no effect on game. Maybe change to slow down game speed?
    player.rapid_fire_powerup_expiration=0
    player.shield = 0 -- added to when collecting shield gems
    player.shield_image = love.graphics.newImage("assets/player_shield.png")
    player.last_shot = love.timer.getTime() -- needed for rate of fire calulation
    player.blasts = {}

    --[[
        player collision boxes

        Each player can have multiple collision boxes. Each box is made up of four
        elements, each of which represents the number of pixels from the edge.

        A player with two collosion boxes would look like this: {{a,b,c,d},{a,b,c,d}}

            a=pixels right of lext most player image edge (pos_x+a)
            b=pixels right of left mos player imgage edge (pos_x+width-b)
            c=pixels down from upper player image edge (pos_y+c)
            d=pixels up from bottom eplayer imagedge (pos_y+height-d)

        The collision detection code using these boxes is in enemy.lua and the
        enemy_blasts_update() function.
    ]]
    if selected_ship == 1 then
        player.ship = "Raptor"
        player.image = love.graphics.newImage("assets/player2.png") -- selected ship
        player.collision_box = { {22,22,6,4}, {0,0,36,6} }
        player.width = player.image:getWidth()
        player.height = player.image:getHeight()
        player.rate_of_fire = 0.2 -- 0.2 = 5 blasts /second. Rapid fire upgrades available during gameplay.
    elseif selected_ship == 2 then
        player.ship = "Wildfly"
        player.image = love.graphics.newImage("assets/otto3.png") -- selected ship
        player.collision_box = { {24,24,2,8}, {18,18,15,6}, {7,7,28,10} }
        player.width = player.image:getWidth()
        player.height = player.image:getHeight()
        player.rate_of_fire = 0.25 -- 0.2 = 5 blasts /second. Rapid fire upgrades available during gameplay.
    elseif selected_ship == 3 then
        player.ship = "Rex"
        player.image = love.graphics.newImage("assets/frans.png") -- selected ship
        player.collision_box = { {21,21,3,12}, {10,32,10,6}, {32,10,10,6}, {4,4,37,6} }
        player.width = player.image:getWidth()
        player.height = player.image:getHeight()
        player.rate_of_fire = 0.3 -- 0.2 = 5 blasts /second. Rapid fire upgrades available during gameplay.
    end

    blast_image = love.graphics.newImage("assets/player_blast.png")
    blast_sound = love.audio.newSource("assets/Laser_Shoot3.wav", "static")
    player_hit_sound = love.audio.newSource("assets/player_hit.wav", "static")

    -- uses explosion1-4 from enemy.lua

    -- move mouse cursor->player ship to starting position
    love.mouse.setPosition(player.pos_x*screenScale+54, player.pos_y*screenScale+48)
    
end



-------------------------------------------------------------------
-- shoot player blast
-------------------------------------------------------------------
function player_shoot()
    local _shot = love.timer.getTime()
    if _shot > (player.last_shot + player.rate_of_fire) then
        player.last_shot = _shot
        local blast = {}
        if player.ship == "Wildfly" then
            -- shot 1
            blast.pos_x = player.pos_x + 3
            blast.pos_y = player.pos_y + 20
            blast.width = 8
            blast.height = 10
            blast.velocity = (math.random()*50)+300
            table.insert(player.blasts, blast)
            -- shot 2
            local blast2 = {}
            blast2.pos_x = player.pos_x + 43
            blast2.pos_y = player.pos_y + 20
            blast2.width = 8
            blast2.height = 10
            blast2.velocity = (math.random()*50)+300
            table.insert(player.blasts, blast2)
        elseif player.ship == "Rex" then
            -- shot 1
            blast.pos_x = player.pos_x + 10
            blast.pos_y = player.pos_y + 2
            blast.width = 8
            blast.height = 10
            blast.velocity = (math.random()*50)+300
            table.insert(player.blasts, blast)
            -- shot 2
            local blast2 = {}
            blast2.pos_x = player.pos_x + 23
            blast2.pos_y = player.pos_y -5
            blast2.width = 8
            blast2.height = 10
            blast2.velocity = (math.random()*50)+300
            table.insert(player.blasts, blast2)
            -- shot 3
            local blast3 = {}
            blast3.pos_x = player.pos_x + 38
            blast3.pos_y = player.pos_y + 2
            blast3.width = 8
            blast3.height = 10
            blast3.velocity = (math.random()*50)+300
            table.insert(player.blasts, blast3)
        else
            blast.pos_x = player.pos_x + 23 -- player width / 2 - blast width / 2
            blast.pos_y = player.pos_y - 4
            blast.width = 8
            blast.height = 10
            blast.velocity = (math.random()*50)+300
            blast.damage = (math.random()*50)+50
            table.insert(player.blasts, blast)
        end
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
                        enemies[j].health = enemies[j].health - player.blasts[i].damage
                        if enemies[j].health < 1 then
                            enemies[j].dead = true
                            game.kills = game.kills + 1
                            game.score = game.score + enemies[j].points
                        end
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

        -- check mouse position
        player.pos_x, player.pos_y = love.mouse.getPosition()
        player.pos_x = player.pos_x / screenScale - 27
        player.pos_y = player.pos_y / screenScale - 54 -- make player image rest above touch point for visibility
        -- check mouse button
        if love.mouse.isDown(1) then
            player_shoot()
        end
        
        -- check touch position
        --[[ love.touch not needed? love.mouse seems to work just fine for touch.
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
        elseif player.pos_x > 480 - 54 then
            player.pos_x = 480 - 54
            -- correct mouse position
            love.mouse.setX(480 * screenScale - 54)
        end
        if player.pos_y < 0 then
            player.pos_y = 0
            love.mouse.setY(48*screenScale)
        elseif player.pos_y > 480 - 48 then
            player.pos_y = 480 - 48
            love.mouse.setY(480 * screenScale - 48)
        end
        
        -- check powerup expiration
        if player.rapid_fire_powerup_expiration~=0 and player.rapid_fire_powerup_expiration < now then
            -- rapid fire powerup has expired
            player.rate_of_fire=player.rate_of_fire*2
            player.rapid_fire_powerup_expiration=0
        else
            -- draw powerup hud in game.lua
        end
        if player.speed_booster_powerup_expiration~=0 and player.speed_booster_powerup_expiration < now then
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
function player_hit(b)   -- b is enemy blast that hit player
    -- todo
    player_hit_sound:stop()
    player_hit_sound:play()

    if player.shield > 0 then
        player.shield = player.shield - b.damage
        if player.shield < 0 then
            player.health = player.health + player.shield
        end
    else
        player.health = player.health - b.damage
        if player.health <= 0 then
            player.dead = true
        end
    end
    if player.health < 0 then player.health = 0 end
    if player.shield < 0 then player.shield = 0 end
end



-------------------------------------------------------------------
-- draw player
-------------------------------------------------------------------
function player_draw()

    if player.dead then
        -- check which explosion image to draw
        if player.explosion == 0 then
            if now > player.next_explosion then
                player.explosion = 1
                player.next_explosion = (now + 0.1)
            end
            love.graphics.draw(explosion1, player.pos_x, player.pos_y)
        elseif player.explosion == 1 then
            if now > player.next_explosion then
                player.explosion = 2
                player.next_explosion = (now + 0.1)
            end
            love.graphics.draw(explosion2, player.pos_x, player.pos_y)
        elseif player.explosion == 2 then
            if now > player.next_explosion then
                player.explosion = 3
                player.next_explosion = (now + 0.1)
            end
            love.graphics.draw(explosion3, player.pos_x, player.pos_y)
        elseif player.explosion == 3 then
            if now > player.next_explosion then
                player.explosion = 4
                player.next_explosion = (now + 0.1)
            end
            love.graphics.draw(explosion4, player.pos_x, player.pos_y)
        elseif player.explosion == 4 then
            game.over=true
            game.ended=now
        end
    else
        love.graphics.draw(player.image,player.pos_x,player.pos_y)
        -- to print some variable at player position
        --love.graphics.print(screenScale, player.pos_x, player.pos_y)
        if player.shield > 0 then
            love.graphics.draw(player.shield_image,player.pos_x-5,player.pos_y-1)
        end
    end
    
    for i=1,#player.blasts do
        love.graphics.draw(blast_image, player.blasts[i].pos_x, player.blasts[i].pos_y)
    end

end


