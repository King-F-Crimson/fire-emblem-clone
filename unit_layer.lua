unit_layer = {}

function unit_layer.create(map, width, height)
    local self = map:addCustomLayer("unit_layer")

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

        tile_x, tile_y = tile_x + 1, tile_y + 1
        self.tiles[tile_y][tile_x] = unit
    end

    function self:set_unit(unit, tile_x, tile_y)
        -- Translation since lua index starts from 1.
        tile_x, tile_y = tile_x + 1, tile_y + 1
        self.tiles[tile_y][tile_x] = unit
    end

    function self:get_unit(tile_x, tile_y)
        -- Translation since lua index starts from 1.
        tile_x, tile_y = tile_x + 1, tile_y + 1
        
        local unit
        -- Prevent nil error when tile_y is 0 or lower.
        if tile_x > 0 and tile_y > 0 then
            unit = self.tiles[tile_y][tile_x]
        end

        return unit
    end

    return self
end