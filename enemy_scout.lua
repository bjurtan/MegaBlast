-- FILE: enemy_scout.lua

function new_enemy_scout(enemy_type)

    local _enemy = {
        type = enemy_type,
        direction_y = 1, -- 0=none, 1=down, -1=up
        direction_x = 0, -- 0=none, 1=right, -1=left
        next_direction = (math.random()*6+3), -- direction change time mark
        next_shot = (math.random()*3), -- shot time mark
        pos_x = (math.random()*480), -- position on x plane
        pos_y = -32,
        collision = false,
        dead = false,
        explosion = 0,
        next_explosion = 0,
        start_health = 100,
        health = 100,
        speed = 80,
        rate_of_fire = 0.6,
        width = enemy1_img:getWidth(),
        height = enemy1_img:getHeight(),
        points = 20,
        collision_box = {{14,14,3,0},{0,0,24,4}}
    }

    return _enemy
    
end