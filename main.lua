require("run")
require("world")

app = {}

function love.load()
    love.window.setFullscreen(true, "desktop")

    app.camera = { x = 0, y = 0 }
    app.world = world.create()
end

function love.update()
    local move = { x = 0, y = 0 }
    if love.keyboard.isDown("up") then
        move.y =  1
    end
    if love.keyboard.isDown("down") then
        move.y =  -1
    end
    if love.keyboard.isDown("left") then
        move.x =  1
    end
    if love.keyboard.isDown("right") then
        move.x =  -1
    end
    if love.keyboard.isDown("lshift") then
        move.y = move.y * 5
        move.x = move.x * 5
    end

    app.camera.x = app.camera.x + move.x
    app.camera.y = app.camera.y + move.y

    app.world:update()
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(2)
    love.graphics.translate(app.camera.x, app.camera.y)

    app.world:draw()
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.window.close()
    end
    local unit = app.world.unit
    if key == "w" then
        app.world.unit.y = app.world.unit.y - 16
    end
    if key == "r" then
        app.world.unit.y = app.world.unit.y + 16
    end
    if key == "a" then
        app.world.unit.x = app.world.unit.x - 16
    end
    if key == "s" then
        app.world.unit.x = app.world.unit.x + 16
    end
end