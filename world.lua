require("unit")

local sti = require "libs/Simple-Tiled-Implementation/sti"

world = {
    
}

function world.create()
    local self = {}
    setmetatable(self, {__index = world})

    self.map = sti("maps/sample_map.lua")

    local unit_layer = self.map:addCustomLayer("unit_layer")
    unit_layer.units = {}
    unit_layer.units.player = unit.create(-16, 0)

    function unit_layer:update(dt)

    end

    function unit_layer:draw()
        for _, unit in pairs(self.units) do
            unit:draw()
        end
    end

    return self
end

function world:update()
    self.map:update()
end

function world:draw()
    self.map:draw()
end

function world:get_unit(tile_x, tile_y)
    print(tile_x, tile_y)
    local unit = self.map.layers.unit_layer.units.player
    local unit_x, unit_y = self.map:convertPixelToTile(unit.x, unit.y)
    if tile_x == unit_x and tile_y == unit_y then
        return unit
    end
end