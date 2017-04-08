unit_layer = {}

function unit_layer.create(map, width, height)
    local self = map:addCustomLayer("unit_layer")

    -- Operation that involves self.tiles should be translated 1 since Lua index starts from 1.
    self.tiles = {}
    for y = 1, height do
        self.tiles[y] = {}
        for x = 1, width do
            self.tiles[y][x] = nil
        end
    end

    function self:draw()
        for y, column in pairs(self.tiles) do
            for x, unit in pairs(column) do
                if unit ~= nil then
                    unit:draw()
                end
            end
        end
    end

    function self:update(dt)

    end

    function self:create_unit(unit_class, tile_x, tile_y)
        local unit = unit_class.create(tile_x, tile_y)

        self.tiles[tile_y + 1][tile_x + 1] = unit
    end

    function self:set_unit(unit, tile_x, tile_y)
        -- Translation since lua index starts from 1.
        self.tiles[tile_y + 1][tile_x + 1] = unit
    end

    function self:get_unit(tile_x, tile_y)
        -- Translation since lua index starts from 1.
        
        local unit
        -- Prevent nil error when tile_y is 1 or lower.
        if tile_x >= 0 and tile_y >= 0 then
            unit = self.tiles[tile_y + 1][tile_x + 1]
        end

        return unit
    end

    function self:move_unit(unit, end_x, end_y)
        local start_x, start_y = unit.tile_x, unit.tile_y
        -- Move the actual unit in the unit's state.
        local unit = self:get_unit(start_x, start_y)
        unit:move(end_x, end_y)

        -- Change the map tiles.
        -- Translate 1 since it involves self.tiles
        self.tiles[start_y + 1][start_x + 1] = nil
        self.tiles[end_y + 1][end_x + 1] = unit
    end

    return self
end