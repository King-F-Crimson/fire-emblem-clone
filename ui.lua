require("cursor")
require("action_menu")

ui = {}

function ui.create(application)
    local self = { app = application }
    setmetatable(self, {__index = ui})

    self.cursor = cursor.create(self.app, 8, 8)

    return self
end

function ui:draw()
    -- Draw unit information.
    local unit = self.cursor:get_unit()
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.health, unit.strength, unit.speed)
        love.graphics.print(info, tile_size, tile_size)
    end

    -- Draw action menu if there's any.
    -- if self.action_menu then
    --     self.action_menu:draw()
    -- end

    -- Draw cursor at the center of the screen.
    love.graphics.push()

    local cursor_x, cursor_y = self.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.cursor:draw()

    love.graphics.pop()
end

function ui:update()
    self.cursor:update()
end