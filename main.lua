require("run")
require("world")

app = {}

function love.load()
    app.world = world.create()
end

function love.update()
    app.world:update()
end

function love.draw()
    app.world:draw()
end

