-- FILE: enemy.lua

-- init
function enemy_init()
    
    enemies = {} -- enemies table
    enemy_fire = {} -- enemy fire table

    enemy1_img = love.graphics.newImage("assets/enemy1.png")
    enemy2_img = love.graphics.newImage("assets/enemy4.png")

    enemy1_shot_img = love.graphics.newImage("assets/enemy_shot1.png")

    explosion1 = love.graphics.newImage("assets/explosion1.png")
    explosion2 = love.graphics.newImage("assets/explosion2.png")
    explosion3 = love.graphics.newImage("assets/explosion3.png")
    explosion4 = love.graphics.newImage("assets/explosion4.png")
    
end


-- new enemy
function new_enemy(enemy_type)

    -- TODO: Implement new enemy function
    local _enemy = {
        type = enemy_type,
        direction_y = 0, -- 0=none, 1=up, 2=down
        direction_x = 0, -- 0=none, 1=left, 2=right
        next_direction = (math.random()*6+1), -- direction change time mark
        next_shot = (math.random()*3), -- shot time mark
        pos_x = (math.random()*screenWidth), -- position on x plane
        pos_y = -32,
        dead = false,
        explosion = 0,
        next_explosion = 0
    }

    if enemy_type == 1 then
        _enemy.speed = 100
        _enemy.rate_of_fire = 0.5
        _enemy.image = enemy1_img
        _enemy.width = _enemy.image:getWidth()
        _enemy.height = _enemy.image:getHeight()
        _enemy.points = 20
        _enemy.collision_box = {{14,14,3,0},{0,0,24,4}}
    elseif enemy_type == 2 then
        _enemy.speed = 50
        _enemy.pos_y = -64
        _enemy.rate_of_fire = 1
        _enemy.image = enemy2_img
        _enemy.width = _enemy.image:getWidth()
        _enemy.height = _enemy.image:getHeight()
        _enemy.points = 25
        _enemy.collision_box = {{7,7,20,40},{14,14,40,20},{20,20,50,4}}
    end

    return _enemy

end


function enemy_shoot(enemy)
    
    -- if enemy is dead if cannot shoot
    if enemy.dead == false then
        -- local storage for new shot
        local _shot = {
            pos_x = enemy.pos_x + enemy.width/2,
            pos_y = enemy.pos_y + enemy.height,
        }

        -- modify local shot depending on enemy type shooting
        if enemy.type == 1 then
            _shot.velocity = (math.random()*50)+200*game.enemy_shot_velocity
            _shot.image = enemy1_shot_img
            _shot.width = _shot.image:getWidth()
            _shot.height = _shot.image:getHeight()
        elseif enemy.type == 2 then
            _shot.velocity = (math.random()*50)+100*game.enemy_shot_velocity
            _shot.image = enemy1_shot_img
            _shot.width = _shot.image:getWidth()
            _shot.height = _shot.image:getHeight()
        end

        -- add _shot to enemy_fire{}
        table.insert(enemy_fire, _shot)
    end
end


function enemy_shots_update(dt)

    local _enemy_shot_remove = {}

    for i=1,#enemy_fire do
        enemy_fire[i].pos_y = enemy_fire[i].pos_y + (enemy_fire[i].velocity * dt)

        -- check if enemy shot passes screen bounds
        if enemy_fire[i].pos_y > love.graphics.getHeight() then
            table.insert(_enemy_shot_remove, i)
        end

        -- check for collision with player by looping through the collision boxes and checking
        -- if enemy shot is within the player collision box edges. Note that the collision_box
        -- is a 2x2 array because there can be multiple collision boxes. [][]
        for j=1,#player.collision_box do
            if enemy_fire[i].pos_x + enemy_fire[i].width > player.pos_x + player.collision_box[j][1] and
            enemy_fire[i].pos_x < player.pos_x + player.width - player.collision_box[j][2] and
            enemy_fire[i].pos_y + enemy_fire[i].height > player.pos_y + player.collision_box[j][3] and
            enemy_fire[i].pos_y < player.pos_y + player.height - player.collision_box[j][4] then
                -- not a good design
                --if player.sheild == true then
                --    player.shield = false
                --else
                --    player.dead = true
                --end
                player_hit()
                table.insert(_enemy_shot_remove, i)
            end
        end

        -- check for enemy shot collision with other enemies
        --[[ for j=1,#enemies do
            if enemy_fire[i].pos_x + enemy_fire[i].width > enemies[j].pos_x and
            enemy_fire[i].pos_x < enemies[j].pos_x + enemies[j].width and
            enemy_fire[i].pos_y + enemy_fire[i].height > enemies[j].pos_y and
            enemy_fire[i].pos_y < enemies[j].pos_y + enemies[j].height then
                enemies[j].dead = true
                table.insert(_enemy_shot_remove, i)
            end
        end ]]
    end

    for i=1,#_enemy_shot_remove do -- loop through player_blast indexs to be removed
        table.remove(enemy_fire, _enemy_shot_remove[i]) -- ..and remove them from the table
    end
end



-- update enemy
function enemy_update(dt)
    -- if enemies, cycle through enemies and update beahavior for each
    if #enemies > 0 then

        -- get current time
        local _now = love.timer.getTime()

        -- iterate over enemies
        for i=1,#enemies do
            -- check if it is time for enemy to shoot
            if enemies[i].next_shot < _now and player.dead~= true then
                enemy_shoot(enemies[i])
                enemies[i].next_shot = love.timer.getTime() + (math.random()*3+enemies[i].rate_of_fire*game.enemy_rate_of_fire)
            end
            -- check if it is time for direction change
            if enemies[i].next_direction < _now then
                enemies[i].direction_x = (math.random()*2)-1
                enemies[i].direction_y = (math.random()*2)-1
                enemies[i].next_direction = love.timer.getTime() + (math.random()*6)
            end
            -- update position
            enemies[i].pos_x = enemies[i].pos_x + enemies[i].speed * game.enemy_speed * enemies[i].direction_x * dt
            enemies[i].pos_y = enemies[i].pos_y + enemies[i].speed * game.enemy_speed * enemies[i].direction_y * dt
            -- check if enemy position is outside screen bounds on x axis
            if enemies[i].pos_x < 0 then
                enemies[i].direction_x = 1
            elseif enemies[i].pos_x + enemies[i].width > screenWidth then
                enemies[i].direction_x = -1
            end
            -- check if enemy position is outside of screen bounds on y axis
            if enemies[i].pos_y < 0 then
                enemies[i].direction_y = 1
            elseif enemies[i].pos_y + enemies[i].height > (screenHeight - screenHeight/3) then
                enemies[i].direction_y = -1
            end
            -- check if enemies are colliding
            ---------------------------------------------------------------------------------
            -- THIS NEEDS TO BE OPTIMEXED! RIGHT NOW EACH ENEMY IS LOOPED OVER TWICE AS    --
            -- THE OUTER LOOP (i) AND INNER LOOP (j) ROLLS THOUGH THE RANDOM CHANGE        --
            -- OF DIRECTION FOR BOTHE COLIDING ENEMIES ARE DUPLICATED AND RANDOMIZED.      --
            -- IN AN IDEAL SCHENARIO ENEMIES ARE ITERATED ONE AND THE DIRECTION CHANGE IS  --
            -- NOT RANDOMIZED BUT RATHER INVERTED.                                         --
            ---------------------------------------------------------------------------------
            -- hmmmm
            -- In the future I will implement a proper collision detection system using box
            -- and circle colliders for each game entity (player, eneies, blasts etc) and have
            -- each entity put its collisioon box data in a global table that will perform all
            -- collision detection in one go, without excessive iteration over the same data.
            for j=1,#enemies do
                if i~=j then
                    --if enemies[i].pos_x < enemies[j].pos_x + enemies[j].width and
                    --enemies[i].pos_x + enemies[i].width > enemies[j].pos_x and
                    --enemies[i].pos_y < enemies[j].pos_y + enemies[j].height and
                    --enemies[i].pos_y + enemies[i].height > enemies[j].pos_y then
                    --    enemies[i].next_direction = 0
                    --end
                    if enemies[i].pos_x < enemies[j].pos_x + enemies[j].width and
                    enemies[i].pos_x + enemies[i].width > enemies[j].pos_x then
                        if enemies[i].direction_x == 1 then
                            enemies[i].direction_x = -1
                            enemies[i].pos_x = enemies[i].pos_x - 2
                        else
                            enemies[i].direction_x = 1
                            enemies[i].pos_x = enemies[i].pos_x + 2
                        end
                    if enemies[i].pos_y < enemies[j].pos_y + enemies[j].height and
                    enemies[i].pos_y + enemies[i].height > enemies[j].pos_y then
                        if enemies[i].direction_y == 1 then
                            enemies[i].direction_y = -1
                            enemies[i].pos_y = enemies[i].pos_y - 2
                        else
                            enemies[i].direction_y = 1
                            enemies[i].pos_y = enemies[i].pos_y + 2
                        end
                    end
                end
            end
        end
    end
    else -- else crete some enemies
        -- TODO: create enemies
    end
    enemy_shots_update(dt)
end



function enemy_draw(dt)
    -- draw enemies if there are eneies
    if #enemies > 0 then
        -- enemy is dead, create table to hold enemies to be removed
        local _enemies_remove = {}
        local _now = love.timer.getTime()

        -- for each enemy 
        for i=1,#enemies do
            -- check if enemy is dead
            if enemies[i].dead == true then                    
                -- check which explosion image to draw
                if enemies[i].explosion == 0 then
                    if _now > enemies[i].next_explosion then
                        enemies[i].explosion = 1
                        enemies[i].next_explosion = (_now + 0.1)
                    end
                    love.graphics.draw(explosion1, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 1 then
                    if _now > enemies[i].next_explosion then
                        enemies[i].explosion = 2
                        enemies[i].next_explosion = (_now + 0.1)
                    end
                    love.graphics.draw(explosion2, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 2 then
                    if _now > enemies[i].next_explosion then
                        enemies[i].explosion = 3
                        enemies[i].next_explosion = (_now + 0.1)
                    end
                    love.graphics.draw(explosion3, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 3 then
                    if _now > enemies[i].next_explosion then
                        enemies[i].explosion = 4
                        enemies[i].next_explosion = (_now + 0.1)
                    end
                    love.graphics.draw(explosion4, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 4 then
                    -- enemy to be removed, put index in temp enemy_remove
                    table.insert(_enemies_remove, i)
                end
            else
                love.graphics.draw(enemies[i].image, enemies[i].pos_x, enemies[i].pos_y)
            end
        end
        -- remove dead exploded enemies
        for i=1,#_enemies_remove do
        --    if enemies[_enemies_remove[i]].type ==1 then
        --        game.kills_enemy1 = game.kills_enemy1+1
        --    elseif enemies[_enemies_remove[i]].type == 2 then
        --        game.kills_enemy2 = game.kills_enemy2+1
        --    elseif enemies[_enemies_remove[i]].type == 3 then
        --        game.kills_enemy3 = game.kills_enemy3+1
        --    elseif enemies[_enemies_remove[i]].type == 4 then
        --        game.kills_enemy4 = game.kills_enemy4+1
        --    elseif enemies[_enemies_remove[i]].type == 5 then
        --        game.kills_enemy5 = game.kills_enemy5+1
        --    end
            table.remove(enemies, _enemies_remove[i])
        end
    end

    -- draw enemy shots
    if #enemy_fire > 0 then
        for i=1,#enemy_fire do
            love.graphics.draw(enemy_fire[i].image, enemy_fire[i].pos_x, enemy_fire[i].pos_y)
        end
    end

end
