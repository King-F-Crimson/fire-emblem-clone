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
    local input_type = { up = "move", down = "move", left = "move", right = "move", select = "select", cancel = "cancel",
                         mouse_pressed = "mouse_pressed" }

    for input, data in pairs(input_queue) do
        local input_type = input_type[input]
        if input_type == "move" then
            self:move(input)
        elseif input_type == "select" then
            self:select()
        elseif input_type == "cancel" then
            self:cancel()
        elseif input_type == "mouse_pressed" then
            self:mouse_pressed(data)
        end
    end
end

function cursor:mouse_pressed(data)
    local tile_x, tile_y = self.ui.game.camera:get_tile_from_coordinate(data.x, data.y)

    self:move_to(tile_x, tile_y)

    if data.button == 1 then
        self:select()
    elseif data.button == 2 then
        self:cancel()
    end
end

-- If tile_x or tile_y is less than minimum value, return the minimum value.
-- If tile_x or tile_y is more than maximum value, return the maximum value.
-- Internal method, doesn't notify "cursor_moved".
function cursor:rebound()
    local minimum = { x = 0, y = 0 }
    local maximum = { x = self.ui.world.map.width - 1, y = self.ui.world.map.height - 1 }

    if self.tile_x < minimum.x then
        self.tile_x = minimum.x
    elseif self.tile_x > maximum.x then
        self.tile_x = maximum.x
    end
    if self.tile_y < minimum.y then
        self.tile_y = minimum.y
    elseif self.tile_y > maximum.y then
        self.tile_y = maximum.y
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

    -- Make sure cursor is not outside the map.
    self:rebound()

    self.ui.observer:notify("cursor_moved")
end

function cursor:move_to(tile_x, tile_y)
    self.tile_x, self.tile_y = tile_x, tile_y

    self:rebound()

    self.ui.observer:notify("cursor_moved")
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