require("utility")
require("unit_class")

unit = {
    sprite = love.graphics.newImage("assets/template_unit.png")
}

unit.sprite:setFilter("nearest")

function unit.create(class, tile_x, tile_y, data)
    local self = deepcopy(class)

    self.tile_x = tile_x
    self.tile_y = tile_y

    -- Copy extra data (weapon, starting HP, etc) if exist.
    if data then
        self.data = deepcopy(data)
    else
        self.data = {}
    end

    if not self.data.health then
        self.data.health = self.max_health
    end
    
    setmetatable(self, { __index = unit })

    return self
end

function unit:draw()
    -- Unit will be hidden during animation.
    if not self.hidden then
        love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)
        love.graphics.print(self.data.health, self.tile_x * tile_size, (self.tile_y - 1) * tile_size)
    end
end

function unit:move(tile_x, tile_y)
    self.tile_x, self.tile_y = tile_x, tile_y
end