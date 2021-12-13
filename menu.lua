-- FILE: menu.lua

-------------------------------------------------------------------
-- menu init
-------------------------------------------------------------------
function menu_init()

    mouse = {
        cursor = love.graphics.newImage("assets/mouse_cursor.png"),
        pos_x = 0,
        pos_y = 0,
    }

    menu = {
        active = true,
        title = "MEGABLAST",
        description = "A galactic space shooter game by F.O.B (c) 2020 Frans, Otto & Björn",
        text = "The Raptor is your trusty ship. Its fast, agile and LETHAL! Best of luck out there pilot..",
        selected = 1,
        ships = {
            {
                name = "Raptor",
                image = love.graphics.newImage("assets/player2.png"),
                pos_x = 100,
                pos_y = 300,
                width = 54,
                height = 48,
                locked = false
            },
            --[[
            {
                name = "Wildfly",
                image = love.graphics.newImage("assets/otto3.png"),
                pos_x = 180,
                pos_y = 300,
                width = 54,
                height = 48,
                locked = false
            },
            {
                name = "Rex",
                image = love.graphics.newImage("assets/frans.png"),
                pos_x = 260,
                pos_y = 300,
                width = 54,
                height = 48,
                locked = false
            } ]]
        },

        -- Each ship is framed depending on is it is locked, selected or not.
        --[[
        selected_ship_img = love.graphics.newImage("assets/ship_framse_selected.png"),
        unselected_ship_img = love.graphics.newImage("assets/ship_framse_unselected.png"),
        locked_ship_img = love.graphics.newImage("assets/ship_framse_locked.png"),
        ]]
        play_button = {
            img = love.graphics.newImage("assets/play_button.png"),
            pos_x = (screenWidth-96)/2,
            pos_y = 340,
            width = 96,
            height = 48,
        }
    }

    title_font = love.graphics.newFont("assets/Audiowide-Regular.ttf", 60)
    main_font = love.graphics.newFont("assets/Audiowide-Regular.ttf", 12)

end

-------------------------------------------------------------------
-- menu update
-------------------------------------------------------------------
function menu_update(dt)
    -- check mouse position
    mouse.pos_x, mouse.pos_y = love.mouse.getPosition()
    mouse.pos_x = mouse.pos_x / screenScale
    mouse.pos_y = mouse.pos_y / screenScale

    -- check mouse button
    if love.mouse.isDown(1) then
        -- TODO: check what was pressed (just like collision detection)
        -- loop over all player images to check for mouse click
        for i=1,#menu.ships do
            if mouse.pos_x > menu.ships[i].pos_x and
            mouse.pos_x < menu.ships[i].pos_x + menu.ships[i].width and
            mouse.pos_y > menu.ships[i].pos_y and
            mouse.pos_y < menu.ships[i].pos_y + menu.ships[i].height then
                if menu.ships[i].locked == false then
                    menu.selected = i
                end
            end
        end
        -- ..and check if mouse clicked play button
        if mouse.pos_x > menu.play_button.pos_x and
        mouse.pos_x < menu.play_button.pos_x + menu.play_button.width and
        mouse.pos_y > menu.play_button.pos_y and
        mouse.pos_y < menu.play_button.pos_y + menu.play_button.height then
            -- start game and pass selected ship to game
            menu.active = false
            game_init()
            level_init()
            enemy_init()
            player_init(menu.selected) -- send selected ship
        end
    end
end

-------------------------------------------------------------------
-- menu draw
-------------------------------------------------------------------
function menu_draw(dt)
    --love.graphics.setFont(title_font)
    --love.graphics.print(menu.title, 100, 100)
    local _title_text = love.graphics.newText(title_font, menu.title)
    love.graphics.draw(_title_text, (screenWidth-_title_text:getWidth())/2, 100)

    --love.graphics.setFont(main_font)
    --love.graphics.print(menu.description, 100, 180)
    local _text_desc = love.graphics.newText(main_font, menu.description)
    love.graphics.draw(_text_desc, (screenWidth-_text_desc:getWidth())/2, 170)

    --[[
    for s=1, #menu.ships do
        love.graphics.draw(menu.ships[s].image, menu.ships[s].pos_x, menu.ships[s].pos_y)
        --love.graphics.print(menu.ships[s].name, menu.ships[s].pos_x, menu.ships[s].pos_y+56)
        if menu.ships[s].locked == true then
            love.graphics.draw(menu.locked_ship_img, menu.ships[s].pos_x-5, menu.ships[s].pos_y-5)
        elseif menu.selected == s then
            love.graphics.draw(menu.selected_ship_img, menu.ships[s].pos_x-5, menu.ships[s].pos_y-5)
        else
        
            love.graphics.draw(menu.unselected_ship_img, menu.ships[s].pos_x-5, menu.ships[s].pos_y-5)
        end
    end
    ]]
    love.graphics.draw(menu.ships[1].image, (screenWidth-menu.ships[1].image:getWidth())/2, 230)

    --love.graphics.print(menu.text1, 170, 300)
    --love.graphics.print(menu.text2, 170, 320)
    --love.graphics.print(menu.text3, 170, 340)

    local _cool_text = love.graphics.newText(main_font, menu.text)
    love.graphics.draw(_cool_text, (screenWidth-_cool_text:getWidth())/2, 289)

    love.graphics.draw(menu.play_button.img, menu.play_button.pos_x, menu.play_button.pos_y)

    -- hide standard mouse cursor and draw draw custom cursor
    love.mouse.setVisible(false)
    love.graphics.draw(mouse.cursor, mouse.pos_x, mouse.pos_y)

end
