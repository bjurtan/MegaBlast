function love.conf(t)
        
    -- love configuration
    t.version = "11.2" -- love version this game is made for
    
    -- load/disable modules
    t.modules.audio = true              -- Enable the audio module (boolean)
    t.modules.event = true              -- Enable the event module (boolean)
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = true              -- Enable the image module (boolean)
    t.modules.joystick = false          -- Enable the joystick module (boolean)
    t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    t.modules.math = true               -- Enable the math module (boolean)
    t.modules.mouse = true              -- Enable the mouse module (boolean)
    t.modules.physics = true            -- Enable the physics module (boolean)
    t.modules.sound = true              -- Enable the sound module (boolean)
    t.modules.system = true             -- Enable the system module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = true             -- Enable the touch module (boolean)
    t.modules.video = false             -- Enable the video module (boolean)
    t.modules.window = true             -- Enable the window module (boolean)
    t.modules.thread = true             -- Enable the thread module (boolean)
    
    -- window config
    t.window.title = "MegaBlast!"       -- Set window title
    t.window.icon = nil                 -- Find out how to set window icon
    t.window.resizable = false          -- Window should not be resizeable
    t.window.fullscreen = true          -- We use scaling and maximized window
    t.window.fullscreentype = "exclusive"
    t.window.highdpi = true             -- Retina on Mac. Allways true on android?
    t.window.vsync = true
    t.window.width = 0                  -- Window width of 0 will use maximum monitor resolution
    t.window.height = 0                 --
    -- use a canvas of 320*200 drawing all graphics to the canvas then draw canvas to screen with scaling.
    
    -- debugging
    t.console = true
end    
 