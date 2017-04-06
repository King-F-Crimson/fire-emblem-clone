require("unit")

local sti = require "libs/Simple-Tiled-Implementation/sti"

world = {
    
}

function world.create()
    local self = {}
    setmetatable(self, {__index = world})

    self.map = sti("maps/sample_map.lua")
    self.unit = unit.create(0, 0)

    return self
end

function world:update()

end

function world:draw()
    self.map:draw()
    self.unit:draw()
end