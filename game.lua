-- FILE: game.lua


----------------------------------------------------------
-- global objects
----------------------------------------------------------
game = {}       -- global game object later initialized.
powerups = {}   -- global powerup object later initialized


----------------------------------------------------------
-- global handler for mouse press events used simply to
-- exit back to menu after game is over. Ignore all other
-- mouse events as those are handled elsewhere.
----------------------------------------------------------
function love.mousepressed(x, y, button, istouch)
    if game.over then
        game.over = false
        menu.active = true
    end
end


----------------------------------------------------------
-- game_init
----------------------------------------------------------
function game_init()

    -- initialize game properties
    game = {
        over=false,
        ended=0,
        score=0,
        level=1,
        kills=0,
        bonus=0,
        enemy_spawn=3,          -- remove and use enemy types per level
        enemy_speed=1,          -- enemy speed factor used to make all enemies move faster as game progresses
        enemy_rate_of_fire=1,   -- enemy rate of fire factor used to make all enemies fire faster
        enemy_blast_velocity=1, -- enemy show velocity factor used t make all enemy shots move faster
        next_enemy=0,
        next_enemy_type=1,      -- 1=scout, 2=fighter, 3=bomber, 4=cruiser, 5=megablaster
        max_enemies=10,
        next_difficulty=1,
        next_rf_powerup=love.timer.getTime()+(math.random()*40+40), -- rapid fire powerup
        next_sb_powerup=love.timer.getTime()+(math.random()*40+40), -- speed boost powerup
        next_shield_powerup=love.timer.getTime()+(math.random()*50+50) -- shield powerup
    }

    rapid_fire_powerup_image = love.graphics.newImage("assets/rapid_fire_powerup.png")
    speed_booster_powerup_image = love.graphics.newImage("assets/speed_booster_powerup.png")
    shield_powerup_image = love.graphics.newImage("assets/shield_powerup.png")
    cup_powerup_image = love.graphics.newImage("assets/cup_powerup.png")
    powerup_sound = love.audio.newSource("assets/tada.wav", "static")

end



----------------------------------------------------------
-- keeping track of powerups
----------------------------------------------------------
function new_powerup(t)
    -- local powerup variable
    local _powerup = {
        type=t,
        pos_x = -20,
        pos_y=(math.random()*400)+100,
        width=32,
        height=32,
        speed=100 * game.enemy_speed
    }
    if t == "shield" or "cup" then
        _powerup.width=23
        _powerup.height=23
        _powerup.speed=150 * game.enemy_speed
    end
    return _powerup
end

function update_powerups(dt)
    -- hold collected powerups to be removed from table
    local _remove_powerups = {}
    for i=1, #powerups do
        -- update position
        powerups[i].pos_x = powerups[i].pos_x + powerups[i].speed * dt

        -- check for collision with enemies and make enemies change direction
        for j=1,#enemies do
            if powerups[i].pos_x + powerups[i].width > enemies[j].pos_x and
            powerups[i].pos_x < enemies[j].pos_x + enemies[j].width and
            powerups[i].pos_y + powerups[i].height > enemies[j].pos_y and
            powerups[i].pos_y < enemies[j].pos_y + enemies[j].height then
                enemies[j].next_direction = 0
            end
        end

        -- check collision with player
        if powerups[i].pos_x + powerups[i].width > player.pos_x and
        powerups[i].pos_x < player.pos_x + player.width and
        powerups[i].pos_y + player.height > player.pos_y and
        powerups[i].pos_y < player.pos_y + player.height then
            -- update player
            if powerups[i].type=="rf" then
                player.rapid_fire_powerup_expiration=love.timer.getTime()+10
                player.rate_of_fire=player.rate_of_fire/2
            elseif powerups[i].type=="sb" then
                player.speed_booster_powerup_expiration=love.timer.getTime()+10
                player.speed=player.speed*2
            elseif powerups[i].type=="shield" then
                player.shield=true
            elseif powerups[i].type=="cup" then
                game.score=game.score + 500
                game.bonus=game.bonus +1
            end
            table.insert(_remove_powerups,i)
            powerup_sound:stop()
            powerup_sound:play()
        end

        -- check if powerup is outside screen bounds
        if powerups[i].pos_x > screenWidth then
            table.insert(_remove_powerups, i)
        end

    end

    -- remove powerups item from table and play a tada sound
    for i=1,#_remove_powerups do
        table.remove(powerups, _remove_powerups[i])
    end

end



----------------------------------------------------------
-- game_update
----------------------------------------------------------
function game_update(dt)

    -- if game is not in menu
    if menu.active==false then

        -- check if it is time to progress levels
        level_update()

        -- check number of enemies to maximum
        --if #enemies < game.max_enemies then
        if #enemies < game.max_enemies then
            if now > game.next_enemy then

                -- TODO: Move this code to levels.lua and call from here

                -- decide what type of enemy based on score, randomness etc
                -- then spawn new enemy and insert in enemies table/list
                --[[if game.score > 100 then
                    local _enemy_type = math.random()*2
                    if _enemy_type < 1.5 then
                        game.next_enemy_type = 1
                    else
                        game.next_enemy_type = 2
                    end
                end ]]
                local _enemy = math.random() * levels.enemies
                if _enemy < 10 and _enemy > 0 then
                    _enemy = 1
                elseif _enemy < 12 and _enemy > 10 then
                    _enemy = 2
                else
                    _enemy = 2
                end
                
                table.insert(enemies, new_enemy(_enemy))
                game.next_enemy = now+(math.random()*game.enemy_spawn)
            end
        end

        -- unless player is dead, check if time for powerups
        if player.dead == false then
            if game.next_rf_powerup < now then
                -- if previous powerup has not expired we do not need another
                --if player.rapid_fire_powerup_expiration == 0 then
                table.insert(powerups, new_powerup("rf"))
                --end
                game.next_rf_powerup = love.timer.getTime()+(math.random()*30+30)
            end
            if game.next_sb_powerup < now then
                --if player.speed_booster_powerup_expiration == 0 then
                table.insert(powerups, new_powerup("sb"))
                --end
                game.next_sb_powerup = love.timer.getTime()+(math.random()*30+30)
            end
            if game.next_shield_powerup < now then
                -- check if player allready has shield and if so send cup/bonus instead
                if player.shield == true then
                    table.insert(powerups, new_powerup("cup"))
                else
                    table.insert(powerups, new_powerup("shield"))
                end
                game.next_shield_powerup = love.timer.getTime()+(math.random()*40+40)
            end
        end
        
        -- update powerups (if there are some)
        if #powerups > 0 then
            update_powerups(dt)
        end

        -- TODO: move level code to levels.lua and call it
        if game.kills > levels.enemies then
            game.kills = 0
            game.level = game.level + 1
            -- make game more diccifult over time
            if game.next_difficulty == 1 then
                game.enemy_spawn = game.enemy_spawn * 0.9
            elseif game.next_difficulty == 2 then
                game.enemy_speed = game.enemy_speed + 0.1
            elseif game.next_difficulty == 3 then
                game.enemy_rate_of_fire = game.enemy_rate_of_fire - 1
            elseif game.next_difficulty == 4 then
                game.enemy_blast_velocity = game.enemy_blast_velocity + 0.1
            end
            game.next_difficulty = game.next_difficulty + 1
            if game.next_difficulty == 5 then game.next_difficulty = 1 end
        end
    end
end


----------------------------------------------------------
-- draw_hud
----------------------------------------------------------
function draw_hud()
    
    -- save original colors
    local r, g, b, a
    r, g, b, a = love.graphics.getColor()

    --local _now = love.timer.getTime()
    local _speed_booster = player.speed_booster_powerup_expiration - now
    local _rapid_fire = player.rapid_fire_powerup_expiration - now

    if _speed_booster < 0 then _speed_booster = 0 end
    if _rapid_fire < 0 then _rapid_fire = 0 end

    -- draw score
    love.graphics.print("Score: "..game.score, 10, 2)

    -- draw speed boost timer
    love.graphics.setColor(0,1,0,0.4) -- hud speed booster background
    love.graphics.print("speed boost", 100, 2)
    love.graphics.rectangle("fill", 100, 5, 100, 10)
    love.graphics.rectangle("fill", 100, 5, 10*_speed_booster, 10)

    -- draw rapid fire timer
    love.graphics.setColor(1,0,1,0.4) -- hud speed booster background
    love.graphics.print("rapid fire", 220, 2)
    love.graphics.rectangle("fill", 220, 5, 100, 10)
    love.graphics.rectangle("fill", 220, 5, 10*_rapid_fire, 10)

    -- restore colors
    love.graphics.setColor(r, g, b, a)

    if game.over and (game.ended < now + 2) then -- check game.ended
        
        love.graphics.setFont(title_font)
        love.graphics.print("Game Over", screenWidth/3.6, 200)
        love.graphics.setFont(main_font)
        love.graphics.print("Your score: "..game.score, screenWidth/2.4, 300)
        love.graphics.print("MOUSE BUTTON or ESC to return to menu..",100, 500)
    end

    -- print screen and canvas size
    --love.graphics.print("screenWidth: "..screenWidth, 10, 20)
    --love.graphics.print("pixelWidth: "..love.graphics.getPixelWidth(), 10, 40)

    love.graphics.print(levels.enemies, 10, 20)
    
end


----------------------------------------------------------
-- draw_game
----------------------------------------------------------
function game_draw()
    if game.over == false then -- check game.ended
        -- draw powerups
        for i=1,#powerups do
            if powerups[i].type=="rf" then
                love.graphics.draw(rapid_fire_powerup_image, powerups[i].pos_x, powerups[i].pos_y)
            elseif powerups[i].type=="sb" then
                love.graphics.draw(speed_booster_powerup_image, powerups[i].pos_x, powerups[i].pos_y)
            elseif powerups[i].type=="shield" then
                love.graphics.draw(shield_powerup_image, powerups[i].pos_x, powerups[i].pos_y)
            elseif powerups[i].type=="cup" then
                love.graphics.draw(cup_powerup_image, powerups[i].pos_x, powerups[i].pos_y)
            end
        end

        love.mouse.setVisible(false)

    end
end

