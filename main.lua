require("run")
require("app")
require("cursor")
require("world")

tile_size = 16

function love.load()
    love.window.setFullscreen(true, "desktop")

    app = application.create()
end

function love.update()
    app:update()
end

function love.draw()
    app:draw()
end

function love.keypressed(key)
    app:keypressed(key)
end