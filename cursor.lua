cursor = {
    sprite = love.graphics.newImage("assets/cursor.png")
}
cursor.sprite:setFilter("nearest")

function cursor.create(tile_x, tile_y)
    local self = { tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    self.move_queue = { up = false, down = false, left = false, right = false }

    return self
end

function cursor:draw()
    love.graphics.draw(self.sprite, self.tile_x * app.tile_size, self.tile_y * app.tile_size)
end

function cursor:update()
    if self.move_queue.up then
        self.tile_y = self.tile_y - 1
        self.move_queue.up = false
    end
    if self.move_queue.down then
        self.tile_y = self.tile_y + 1
        self.move_queue.down = false
    end
    if self.move_queue.left then
        self.tile_x = self.tile_x - 1
        self.move_queue.left = false
    end
    if self.move_queue.right then
        self.tile_x = self.tile_x + 1
        self.move_queue.right = false
    end
end

function cursor:process_input(key)
    local input_map = { w = "up", r = "down", a = "left", s = "right" }
    local input = input_map[key]
    if input ~= nil then
        self.move_queue[input] = true
    end
end

function cursor:get_position()
    return self.tile_x * app.tile_size, self.tile_y * app.tile_size
end