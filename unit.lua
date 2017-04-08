require("utility")
require("unit_class")

unit = {
    sprite = love.graphics.newImage("assets/template_unit.png")
}

unit.sprite:setFilter("nearest")

function unit.create(class, tile_x, tile_y)
    local self = deepcopy(class)

    self.tile_x = tile_x
    self.tile_y = tile_y
    
    setmetatable(self, { __index = unit })

    return self
end

function unit:draw()
    love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)
    love.graphics.print(self.health, self.tile_x * tile_size, (self.tile_y - 1) * tile_size)
end

function unit:move(tile_x, tile_y)
    self.tile_x, self.tile_y = tile_x, tile_y
end