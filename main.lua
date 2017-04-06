require("run")
require("cursor")
require("world")

app = {
    tile_size = 16
}

function love.load()
    love.window.setFullscreen(true, "desktop")

    app.cursor = cursor.create(8, 8)
    app.world = world.create()
end

function love.update()
    app.world:update()
end

function love.draw()
    love.graphics.push()
    local zoom = 2
    love.graphics.scale(zoom)

    local cursor_x, cursor_y = app.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (app.tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (app.tile_size / 2))

    app.world:draw()
    app.cursor:draw()
    love.graphics.pop()
end

function love.keypressed(key)
    if key == "escape" then
        love.window.close()
    end
    
    if key == "w" then
        app.cursor.tile_y = app.cursor.tile_y - 1
    end
    if key == "r" then
        app.cursor.tile_y = app.cursor.tile_y + 1
    end
    if key == "a" then
        app.cursor.tile_x = app.cursor.tile_x - 1
    end
    if key == "s" then
        app.cursor.tile_x = app.cursor.tile_x + 1
    end
end