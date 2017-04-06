unit = {
    sprite = love.graphics.newImage("assets/template_unit.png")
}

unit.sprite:setFilter("nearest")

function unit.create(x, y)
    self = { x = x, y = y }
    setmetatable(self, { __index = unit })

    return self
end

function unit:draw()
    love.graphics.draw(self.sprite, self.x, self.y)
end