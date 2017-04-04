require("world")

app = {}

function love.load()
    app.world = world
end

function love.draw()
    world:draw()
end