cursor = {
    sprite = love.graphics.newImage("assets/cursor.png")
}
cursor.sprite:setFilter("nearest")

function cursor.create(tile_x, tile_y)
    self = { tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    return self
end

function cursor:draw()
    love.graphics.draw(self.sprite, self.tile_x * app.tile_size, self.tile_y * app.tile_size)
end

function cursor:get_position()
    return self.tile_x * app.tile_size, self.tile_y * app.tile_size
end