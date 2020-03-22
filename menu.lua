-- FILE: menu.lua


function menu_init()
    menu = {
        title = "MEGABLAST",
        description = "A galactic space shooter game by F.O.B.S (c) 2020 Frans | Otto | Björn | Sara",
        --description = "Ett galaktiskt rymdskjutarspel av Otto Seger & Björn Spåra (c) 2019"
    }

    title_font = love.graphics.newFont("assets/Audiowide-Regular.ttf", 60)
    main_font = love.graphics.newFont("assets/Audiowide-Regular.ttf", 12)

end

function menu_update(dt)
    -- implemented if animated buttons are required but for now, some static
    -- text drawn is enough.
end

function menu_draw(dt)
    -- todo: implement
    love.graphics.setFont(title_font)
    love.graphics.print(menu.title, 100, 100)

    love.graphics.setFont(main_font)
    love.graphics.print(menu.description, 100, 180)
    love.graphics.print("MOUSE BUTTON to play or ESC to quit..",100,500)
    --love.graphics.print("Tryck på ENTER för att spela eller ESC för att avstluta spelet..",100,500)
end
