cursor = {
    sprite = {
        move = love.graphics.newImage("assets/cursor_move.png"),
        attack = love.graphics.newImage("assets/cursor_attack.png"),
    }
}
cursor.sprite.move:setFilter("nearest")
cursor.sprite.attack:setFilter("nearest")

function cursor.create(ui, tile_x, tile_y)
    local self = { ui = ui, observer = ui.observer, tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    return self
end

function cursor:draw()
    local sprite = self.sprite.move
    if self.ui.state == attacking then
        sprite = self.sprite.attack
    end

    love.graphics.draw(sprite, self.tile_x * tile_size, self.tile_y * tile_size)
end

function cursor:update()

end

function cursor:control(input_queue)
    local input_type = { up = "move", down = "move", left = "move", right = "move", select = "select", cancel = "cancel" }

    for input in pairs(input_queue) do
        local input_type = input_type[input]
        if input_type == "move" then
            self:move(input)
            self.observer:notify("cursor_moved")
        end
        if input_type == "select" then
            self:select()
        end
        if input_type == "cancel" then
            self:cancel()
        end
    end
end

function cursor:move(direction)
    local tile_axis = { up = "tile_y", down = "tile_y", left = "tile_x", right = "tile_x" }
    local origin_direction = { up = -1, down = 1, left = -1, right = 1 }

    tile_axis = tile_axis[direction]
    origin_direction = origin_direction[direction]
    if love.keyboard.isDown("lshift") then
        origin_direction = origin_direction * 5
    end

    self[tile_axis] = self[tile_axis] + origin_direction

    -- Make cursor unmoveable to outside map.

    -- Map left-side and up-side.
    if self[tile_axis] < 0 then
        self[tile_axis] = 0
    end

    -- Map right-side and down-side.
    -- Determine the maximum value for the axis.
    local max_value
    if tile_axis == "tile_y" then
        max_value = self.ui.world.map.width - 1
    elseif tile_axis == "tile_x" then
        max_value = self.ui.world.map.height - 1
    end

    if self[tile_axis] > max_value then
        self[tile_axis] = max_value
    end
end

function cursor:select()
    local feedback = { action = "select" }
    feedback.data = { tile_x = self.tile_x, tile_y = self.tile_y }

    self.ui:receive_feedback(feedback)
end

function cursor:cancel()
    local feedback = { action = "cancel" }
    feedback.data = { tile_x = self.tile_x, tile_y = self.tile_y }

    self.ui:receive_feedback(feedback)
end

function cursor:get_position()
    return self.tile_x * tile_size, self.tile_y * tile_size
end

function cursor:get_unit()
    return self.ui.world:get_unit(self.tile_x, self.tile_y)
end