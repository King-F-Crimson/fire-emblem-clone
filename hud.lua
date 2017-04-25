hud = {
    minimap_unit = love.graphics.newImage("assets/minimap_unit.png")
}

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

    self:generate_minimap()

    self.observer:add_listener("cursor_moved", set_unit_on_cursor_as_displayed)

    return self
end

function hud:set_displayed_unit(unit)
    self.displayed_unit = unit
end

function hud:draw_unit_info()
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

function hud:generate_minimap()
    local terrain_color = {
        plain = {141, 196, 53},
        water = {99, 197, 207},
        sand  = {230, 218, 191},
        wall  = {168, 182, 183},
    }

    local minimap_tile_size = tile_size / 4
    local mts = minimap_tile_size

    self.minimap = love.graphics.newCanvas()
    self.minimap:setFilter("nearest")
    love.graphics.setCanvas(self.minimap)
        -- Draw the terrain.
        local terrain_map = self.ui.world:get_terrain_map()

        for k, tile in pairs(terrain_map) do
            love.graphics.setColor(terrain_color[tile.terrain])
            love.graphics.rectangle("fill", tile.x * mts, tile.y * mts, mts, mts )
        end

        -- Reset color.
        love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setCanvas()
end

function hud:draw_minimap()
    love.graphics.draw(self.minimap, tile_size, 200) -- 200 is hardcoded, change later.
end

function hud:draw()
    self:draw_unit_info()
    self:draw_minimap()
end