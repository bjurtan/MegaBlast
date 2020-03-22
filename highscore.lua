-- FILE: highscore.lua

function highscore_init()

    -- highscore item
    local highscore_item = {
        name="otto",
        score=5663,
        date=os.date(),
        game_version=0.1
    }

    -- highscore list
    highscore_list = {10}

    table.insert(highscore_list, highscore_item)
    highscore_item.score=6793
    table.insert(highscore_list, highscore_item)
    

    -- highscore file
    highscore_file = io.open("highscores.dat", "w")
    
    -- highscore url
    -- todo


end

