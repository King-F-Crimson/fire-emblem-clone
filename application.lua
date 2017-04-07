require("cursor")
require("world")

application = {
    tile_size = 16
}

function application.create()
    local self = {}
    setmetatable(self, { __index = application })

    love.window.setFullscreen(true, "desktop")

    self.cursor = cursor.create(8, 8)
    self.world = world.create()
    return self
end

function application:update()
    self.world:update()
    self.cursor:update()
end

function application:draw()
    love.graphics.push()
    local zoom = 2
    love.graphics.scale(zoom)

    local cursor_x, cursor_y = self.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.world:draw()
    self.cursor:draw()
    love.graphics.pop()
end

function application:keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    self.cursor:process_input(key)
end