ui = {}

function ui.create(application)
    local self = { app = application }
    setmetatable(self, {__index = ui})

    return self
end

function ui:draw()
    local unit = self.app.cursor:get_unit()
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.health, unit.strength, unit.speed)
        love.graphics.print(info, tile_size, tile_size)
    end
end

function ui:update()

end