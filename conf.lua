function love.conf(t)
    t.console = true
    t.identity = "fe_clone"

    t.window.title = "Fire Emblem Clone"
    t.window.highdpi = true
    -- t.window.icon = "assets/window_icon.png"

    io.stdout:setvbuf("no")
end