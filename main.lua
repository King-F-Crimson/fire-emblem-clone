require("run")
require("application")


tile_size = 16

function love.load()
    app = application.create()
end

function love.update()
    app:update()
end

function love.draw()
    app:draw()
end

function love.keypressed(key)
    if key == "rctrl" then
        debug.debug()
    end

    app:keypressed(key)
end

function love.keyreleased(key)
    app:keyreleased(key)
end