-- FILE: game.lua


----------------------------------------------------------
-- game_init
----------------------------------------------------------

function game_init()

    -- create game object
    game = {
        over=false,
        ended=0,
        score=0,
        kills_enemy1=0,
        kills_enemy2=0,
        kills_enemy3=0,
        kills_enemy4=0,
        kills_enemy5=0,
        bonus=0,
        menu=true,
        enemy_spawn=3,
        enemy_speed=1,          -- enemy speed factor used to make all enemies move faster as game progresses
        enemy_rate_of_fire=1,   -- enemy rate of fire factor used to make all enemies fire faster
        enemy_shot_velocity=1,  -- enemy show velocity factor used t make all enemy shots move faster
        next_enemy=0,
        next_enemy_type=1,
        max_enemies=10,
        next_level=100,
        next_difficulty=1,
        next_rf_powerup=love.timer.getTime()+(math.random()*30+30), -- rapid fire powerup
        next_sb_powerup=love.timer.getTime()+(math.random()*30+30), -- speed boost powerup
        next_shield_powerup=love.timer.getTime()+(math.random()*40+40), -- shield powerup
        scale=1,  -- graphics scaling coeficient
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

powerups = {}

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
    if game.menu==false then
        -- get current time
        local _now = love.timer.getTime()
        -- check number of enemies to maximum
        if #enemies < game.max_enemies then
            if _now > game.next_enemy then
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
                table.insert(enemies, new_enemy(game.next_enemy_type))
                game.next_enemy = _now+(math.random()*game.enemy_spawn)
            end
        end

        -- check if time for powerups
        if game.next_rf_powerup < _now then
            -- if previous powerup has not expired we do not need another
            --if player.rapid_fire_powerup_expiration == 0 then
            table.insert(powerups, new_powerup("rf"))
            --end
            game.next_rf_powerup = love.timer.getTime()+(math.random()*30+30)
        end
        if game.next_sb_powerup < _now then
            --if player.speed_booster_powerup_expiration == 0 then
            table.insert(powerups, new_powerup("sb"))
            --end
            game.next_sb_powerup = love.timer.getTime()+(math.random()*30+30)
        end
        if game.next_shield_powerup < _now then
            -- check if player allready has shield and if so send cup/bonus instead
            if player.shield == true then
                table.insert(powerups, new_powerup("cup"))
            else
                table.insert(powerups, new_powerup("shield"))
            end
            game.next_shield_powerup = love.timer.getTime()+(math.random()*40+40)
        end
        
        -- update powerups (if there are some)
        if #powerups > 0 then
            update_powerups(dt)
        end

        if game.score > game.next_level then
            game.next_level = game.next_level + (math.random()*25)*25
            -- make game more diccifult over time
            if game.next_difficulty == 1 then
                game.enemy_spawn = game.enemy_spawn * 0.9
            elseif game.next_difficulty == 2 then
                game.max_enemies = game.max_enemies + 1
            elseif game.next_difficulty == 3 then
                game.enemy_speed = game.enemy_speed + 0.1
            elseif game.next_difficulty == 4 then
                game.enemy_rate_of_fire = game.enemy_rate_of_fire - 1
            elseif game.next_difficulty == 5 then
                game.enemy_shot_velocity = game.enemy_shot_velocity + 0.1
            end
            game.next_difficulty = game.next_difficulty + 1
            if game.next_difficulty == 6 then game.next_difficulty = 1 end
        end
    end
end


function draw_hud()
    
    -- save original colors
    local r, g, b, a
    r, g, b, a = love.graphics.getColor()

    local _now = love.timer.getTime()
    local _speed_booster = player.speed_booster_powerup_expiration - _now
    local _rapid_fire = player.rapid_fire_powerup_expiration - _now

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
end


function game_draw()
    local _now = love.timer.getTime()
    if game.over and (game.ended < _now + 2) then -- check game.ended
        love.graphics.setFont(title_font)
        love.graphics.print("Game Over", screenWidth/3.6, 200)
        love.graphics.setFont(main_font)
        love.graphics.print("Your score: "..game.score, screenWidth/2.4, 300)
        love.graphics.print("MOUSE BUTTON or ESC to return to menu..",100, 500)
    else

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

        draw_hud()

    end
end

