minimap = {
    colorize_shader = love.graphics.newShader("shaders/colorize_shader.fs"),
    minimap_unit = love.graphics.newImage("assets/minimap_unit.png"),
}

function minimap.create(observer, ui, x, y)
    local self = { observer = observer, ui = ui, x = x, y = y }
    setmetatable(self, {__index = minimap})

    self:generate()

    self.listeners = {
        self.observer:add_listener("world_changed", function() self:generate() end)
    }

    return self
end

function minimap:destroy()
    observer.remove_listeners_from_object(self)
end

function minimap:generate()
    -- Scaled 0-255 since these are used by Love directly.
    local terrain_color = {
        plain = {141, 196, 53},
        water = {99, 197, 207},
        sand  = {230, 218, 191},
        wall  = {168, 182, 183},
    }

    local minimap_tile_size = tile_size / 4
    local mts = minimap_tile_size

    self.canvas = love.graphics.newCanvas()
    self.canvas:setFilter("nearest")
    love.graphics.setCanvas(self.canvas)
        -- Draw the terrain.
        local terrain_map = self.ui.world:get_terrain_map()

        for k, tile in pairs(terrain_map) do
            love.graphics.setColor(terrain_color[tile.terrain])
            love.graphics.rectangle("fill", tile.x * mts, tile.y * mts, mts, mts )
        end

        -- Reset color.
        love.graphics.setColor(255, 255, 255, 255)

        -- Draw units.
        for k, unit in pairs(self.ui.world:get_all_units()) do
            local team_color = unit.data.team.color:get_color_as_table(1)
            self.colorize_shader:send("tint_color", team_color)
            love.graphics.setShader(self.colorize_shader)
                love.graphics.draw(self.minimap_unit, unit.tile_x * mts, unit.tile_y * mts)
            love.graphics.setShader()
        end

    love.graphics.setCanvas()
end

function minimap:draw()
    love.graphics.draw(self.canvas, self.x, self.y)
end