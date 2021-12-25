-- FILE: enemy_fighter.lua

function new_enemy_fighter(enemy_type)

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
        start_health = 200,
        health = 200,
        speed = 100,
        pos_y = -64,
        rate_of_fire = 0.4,
        width = enemy2_img:getWidth(),
        height = enemy2_img:getHeight(),
        points = 25,
        collision_box= {{7,7,20,40},{14,14,40,20},{20,20,50,4}}
    }

    return _enemy
end
