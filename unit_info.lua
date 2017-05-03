unit_info = {}

function unit_info.create(observer, ui, x, y)
    local self = { observer = observer, ui = ui, x = x, y = y }
    setmetatable(self, {__index = unit_info})

    self.observer:add_listener("cursor_moved", function() self:set_displayed_unit_from_cursor() end)
    self.observer:add_listener("unit_deleted", function(unit) self:handle_unit_deletion(unit) end)

    return self
end

function unit_info:set_displayed_unit(unit)
    self.displayed_unit = unit
end

function unit_info:set_displayed_unit_from_cursor()
    local ui = self.ui

    local unit_on_cursor = ui.world:get_unit(ui.cursor.tile_x, ui.cursor.tile_y)
    local selected_unit = ui.selected_unit

    if unit_on_cursor then
        self:set_displayed_unit(unit_on_cursor)
    elseif selected_unit then
        self:set_displayed_unit(selected_unit)
    end
end

-- If the deleted unit is the displayed_unit, remove it.
function unit_info:handle_unit_deletion(unit)
    if unit == self.displayed_unit then
        self.displayed_unit = nil
    end
end

function unit_info:draw()
    local unit = self.displayed_unit
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.data.health, unit.strength, unit.speed)
        if unit.data.active_weapon then
            info = string.format("%s\nWeapon: %s", info, unit.data.active_weapon.name)
        end
        love.graphics.print(info, tile_size, tile_size)
    end
end