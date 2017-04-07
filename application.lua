require("cursor")
require("ui")
require("world")

application = {
    tile_size = 16
}

function application.create()
    local self = {}
    setmetatable(self, { __index = application })

    love.window.setFullscreen(true, "desktop")

    self.cursor = cursor.create(self, 8, 8)
    self.ui = ui.create(self)
    self.world = world.create()
    return self
end

function application:update()
    self.world:update()
    self.cursor:update()
    self.ui:update()
end

function application:draw()
    local zoom = 2

    -- Draw the world and cursor, with cursor at the center of the screen.
    love.graphics.push()
    love.graphics.scale(zoom)

    local cursor_x, cursor_y = self.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.world:draw()
    self.cursor:draw()
    love.graphics.pop()

    -- Draw UI without translation.
    love.graphics.push()
    love.graphics.scale(zoom)
    
    self.ui:draw()

    love.graphics.pop()
end

function application:keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    self.cursor:process_input(key, true)
end

function application:keyreleased(key)
    self.cursor:process_input(key, false)
end