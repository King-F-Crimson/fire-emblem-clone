hud = {}

function hud.create(ui)
    local self = { ui = ui, observer = ui.observer }
    setmetatable(self, {__index = hud})

    -- Add hook to observer.
    local function set_unit_on_cursor_as_displayed()
        local unit_on_cursor = ui.world:get_unit(ui.cursor.tile_x, ui.cursor.tile_y)
        local selected_unit = ui.selected_unit

        if unit_on_cursor then
            self:set_displayed_unit(unit_on_cursor)
        elseif selected_unit then
            self:set_displayed_unit(selected_unit)
        end
    end
    self.observer:add_listener("cursor_moved", set_unit_on_cursor_as_displayed)

    return self
end

function hud:set_displayed_unit(unit)
    self.displayed_unit = unit
end

function hud:draw()
    -- Draw unit information.
    local unit = self.displayed_unit
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.data.health, unit.strength, unit.speed)
        if unit.data.weapon then
            info = string.format("%s\nWeapon: %s", info, unit.data.weapon.name)
        end
        love.graphics.print(info, tile_size, tile_size)
    end
end