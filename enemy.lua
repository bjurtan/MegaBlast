-- FILE: enemy.lua

require "enemy_scout"
require "enemy_fighter"
require "enemy_bomber"
require "enemy_bomber"
require "enemy_cruiser"
require "enemy_megablast"


--------------------------------------------------------------------------------
-- enemy_init()
--------------------------------------------------------------------------------
-- This function initializes enemy assets.
--------------------------------------------------------------------------------
function enemy_init()
    
    enemies = {} -- enemies table
    enemy_blasts = {} -- enemy fire table

    enemy1_img = love.graphics.newImage("assets/enemy_scout.png")
    enemy2_img = love.graphics.newImage("assets/enemy4.png")

    enemy1_shot_img = love.graphics.newImage("assets/enemy_blast.png")

    explosion1 = love.graphics.newImage("assets/explosion1.png")
    explosion2 = love.graphics.newImage("assets/explosion2.png")
    explosion3 = love.graphics.newImage("assets/explosion3.png")
    explosion4 = love.graphics.newImage("assets/explosion4.png")
    
end


--------------------------------------------------------------------------------
-- new_enemy()
--------------------------------------------------------------------------------
-- The function will create and immediately spawn a new enemy in the game.
-- the function will decide depending on game state such as score, level
-- etc choose the next enemy type and spawn a new enemy of selected type.
--------------------------------------------------------------------------------
function new_enemy(enemy_type)

    local _enemy

    if enemy_type == 1 then
        _enemy = new_enemy_scout(enemy_type)
    elseif enemy_type == 2 then
        _enemy = new_enemy_fighter(enemy_type)
    end

    return _enemy

end


function enemy_shoot(enemy)
    
    -- if enemy is dead it cannot shoot
    if enemy.dead == false then
        -- local storage for new shot
        local _shot = {
            pos_x = enemy.pos_x + enemy.width/2,
            pos_y = enemy.pos_y + enemy.height,
        }

        -- modify local shot depending on enemy type shooting
        if enemy.type == 1 then
            _shot.velocity = (math.random()*50)+200*game.enemy_blast_velocity
            _shot.image = enemy1_shot_img
            _shot.width = _shot.image:getWidth()
            _shot.height = _shot.image:getHeight()
            _shot.damage = (math.random()*30)+40
        elseif enemy.type == 2 then
            _shot.velocity = (math.random()*50)+200*game.enemy_blast_velocity
            _shot.image = enemy1_shot_img
            _shot.width = _shot.image:getWidth()
            _shot.height = _shot.image:getHeight()
            _shot.damage = (math.random()*50)+60
        end

        -- add _shot to enemy_blasts{}
        table.insert(enemy_blasts, _shot)
    end
end


function enemy_blasts_update(dt)

    local _enemy_blast_remove = {}

    for i=1,#enemy_blasts do
        enemy_blasts[i].pos_y = enemy_blasts[i].pos_y + (enemy_blasts[i].velocity * dt)

        -- check if enemy blast passes screen bounds
        if enemy_blasts[i].pos_y > love.graphics.getHeight() then
            table.insert(_enemy_blast_remove, i)
        end

        -- check for collision with player by looping through the collision boxes and checking
        -- if enemy blast is within the player collision box edges. Note that the collision_box
        -- is a 2 dimensional array because there can be multiple collision boxes. [][]
        for j=1,#player.collision_box do
            if enemy_blasts[i].pos_x + enemy_blasts[i].width > player.pos_x + player.collision_box[j][1] and
            enemy_blasts[i].pos_x < player.pos_x + player.width - player.collision_box[j][2] and
            enemy_blasts[i].pos_y + enemy_blasts[i].height > player.pos_y + player.collision_box[j][3] and
            enemy_blasts[i].pos_y < player.pos_y + player.height - player.collision_box[j][4] then
                player_hit(enemy_blasts[i]) -- handles stuff like shield power depletion and player death
                table.insert(_enemy_blast_remove, i) -- remove enemy shot hitting player
            end
        end

        -- check for enemy blast collision with other enemies
        --[[ for j=1,#enemies do
            if enemy_blasts[i].pos_x + enemy_blasts[i].width > enemies[j].pos_x and
            enemy_blasts[i].pos_x < enemies[j].pos_x + enemies[j].width and
            enemy_blasts[i].pos_y + enemy_blasts[i].height > enemies[j].pos_y and
            enemy_blasts[i].pos_y < enemies[j].pos_y + enemies[j].height then
                enemies[j].dead = true
                table.insert(_enemy_blast_remove, i)
            end
        end ]]
    end

    for i=1,#_enemy_blast_remove do -- loop through player_blast indexs to be removed
        table.remove(enemy_blasts, _enemy_blast_remove[i]) -- ..and remove them from the table
    end
end


function enemy_update(dt)

    local _enemy_distance = {}

    -- if enemies, cycle through enemies and update beahavior for each
    if #enemies > 0 then

        -- iterate over enemies
        for i=1,#enemies do
            -- check if enemies are colliding
            for j=1,#enemies do
                if i~=j then
                    -- check distance between enemies i (outer loop) and j (inner loop)
                    local _distance_x = math.abs(enemies[i].pos_x+enemies[i].width/2 - enemies[j].pos_x+enemies[j].width/2)
                    local _distance_y = math.abs(enemies[i].pos_y+enemies[i].height/2 - enemies[j].pos_y+enemies[j].height/2)
                    local _distance = math.abs(math.sqrt(_distance_x ^ 2 + _distance_y ^ 2))
                    if _distance < 128 then
                        local middle_x, middle_y = 240, 240
                        local i_x = enemies[i].pos_x+enemies[i].width/2
                        local i_y = enemies[i].pos_y+enemies[i].height/2
                        local j_x = enemies[j].pos_x+enemies[j].width/2
                        local j_y = enemies[j].pos_y+enemies[j].height/2
                        local dis_i = math.abs(math.sqrt(math.abs(i_x-middle_x)^2+math.abs(i_y-middle_y)^2))
                        local dis_j = math.abs(math.sqrt(math.abs(j_x-middle_x)^2+math.abs(j_y-middle_y)^2))
                        if dis_i > dis_j then
                            if enemies[i].collision == false then
                                enemies[i].direction_x = enemies[i].direction_x * -1
                                --enemies[i].direction_y = enemies[j].direction_y * -1
                                enemies[i].collision = true
                            end
                        else
                            if enemies[j].collision == false then
                                enemies[j].direction_x = enemies[j].direction_x * -1
                                --enemies[j].direction_y = enemies[j].direction_y * -1
                                enemies[j].collision = true
                            end
                        end
                    else
                        enemies[i].collision = false
                    end
                end
            end
            -- check if it is time for enemy to shoot
            if enemies[i].next_shot < now and player.dead~= true then
                enemy_shoot(enemies[i])
                enemies[i].next_shot = love.timer.getTime() + (math.random()*3+enemies[i].rate_of_fire*game.enemy_rate_of_fire)
            end
            -- check if enemy position is outside screen bounds on x axis
            if enemies[i].pos_x < 0 then
                enemies[i].direction_x = 1
            elseif enemies[i].pos_x + enemies[i].width > 480 then
                enemies[i].direction_x = -1
            end
            -- check if enemy position is outside of screen bounds on y axis
            if enemies[i].pos_y < 0 then
                enemies[i].direction_y = 1
            elseif enemies[i].pos_y > (480) then
                --enemies[i].direction_y = -1
                if enemies[i].dead == false then
                    game.danger = game.danger + 1
                    enemies[i].dead = true
                end
            end
            -- check if it is time for direction change
            if enemies[i].next_direction < now then
                enemies[i].direction_x = ((math.random()*2)-1)*0.5
                enemies[i].direction_y = (math.random()*2)+2
                enemies[i].next_direction = love.timer.getTime() + (math.random()*6+6)
            end
            -- update position
            enemies[i].pos_x = enemies[i].pos_x + enemies[i].speed * game.enemy_speed * enemies[i].direction_x * dt
            enemies[i].pos_y = enemies[i].pos_y + enemies[i].speed * game.enemy_speed * enemies[i].direction_y * dt
        end
    end
    enemy_blasts_update(dt)
end


function enemy_draw(dt)
    -- draw enemies if there are eneies
    if #enemies > 0 then
        -- enemy is dead, create table to hold enemies to be removed
        local _enemies_remove = {}

        -- for each enemy 
        for i=1,#enemies do
            -- check if enemy is dead
            if enemies[i].dead == true then                    
                -- check which explosion image to draw
                if enemies[i].explosion == 0 then
                    if now > enemies[i].next_explosion then
                        enemies[i].explosion = 1
                        enemies[i].next_explosion = (now + 0.1)
                    end
                    love.graphics.draw(explosion1, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 1 then
                    if now > enemies[i].next_explosion then
                        enemies[i].explosion = 2
                        enemies[i].next_explosion = (now + 0.1)
                    end
                    love.graphics.draw(explosion2, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 2 then
                    if now > enemies[i].next_explosion then
                        enemies[i].explosion = 3
                        enemies[i].next_explosion = (now + 0.1)
                    end
                    love.graphics.draw(explosion3, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 3 then
                    if now > enemies[i].next_explosion then
                        enemies[i].explosion = 4
                        enemies[i].next_explosion = (now + 0.1)
                    end
                    love.graphics.draw(explosion4, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].explosion == 4 then
                    -- enemy to be removed, put index in temp enemy_remove
                    table.insert(_enemies_remove, i)
                end
            else
                -- enemy alive
                if enemies[i].type == 1 then
                    love.graphics.draw(enemy1_img, enemies[i].pos_x, enemies[i].pos_y)
                elseif enemies[i].type == 2 then
                    love.graphics.draw(enemy2_img, enemies[i].pos_x, enemies[i].pos_y)
                end
                -- draw enemy health gauge
                local _hr = enemies[i].start_health / 20
                local r, g, b, a
                r, g, b, a = love.graphics.getColor()
                love.graphics.setColor(
                    enemies[i].start_health - enemies[i].health,
                    enemies[i].health - enemies[i].start_health / 2,
                    0, 
                    2
                )
                love.graphics.rectangle(
                    "fill",
                    enemies[i].pos_x,
                    enemies[i].pos_y-7,
                    enemies[i].health/_hr,
                    3
                )
                love.graphics.setColor(r,g,b,a)
            end
        end
        -- remove dead exploded enemies
        for i=1,#_enemies_remove do
            table.remove(enemies, _enemies_remove[i])
        end
    end

    -- draw enemy shots
    if #enemy_blasts > 0 then
        for i=1,#enemy_blasts do
            love.graphics.draw(enemy_blasts[i].image, enemy_blasts[i].pos_x, enemy_blasts[i].pos_y)
        end
    end

end
