require("run")
require("application")

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
    app:key_pressed(key)
end

function love.keyreleased(key)
    app:key_released(key)
end

function love.mousepressed(x, y, button, istouch)
    app:mouse_pressed(x, y, button)
end

function love.wheelmoved(x, y)
    app:mouse_wheel_moved(x, y)
end