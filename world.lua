require("unit")

local sti = require "libs/Simple-Tiled-Implementation/sti"

world = {
    
}

function world.create()
    local self = {}
    setmetatable(self, {__index = world})

    self.map = sti("maps/sample_map.lua")

    unit_layer = self.map:addCustomLayer("unit_layer", 69)
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
    self.map.layers.unit_layer:draw()
end