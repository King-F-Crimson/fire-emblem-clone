cursor = {
    sprite = {
        move = love.graphics.newImage("assets/cursor_move.png"),
        attack = love.graphics.newImage("assets/cursor_attack.png"),
    }
}
cursor.sprite.move:setFilter("nearest")
cursor.sprite.attack:setFilter("nearest")

function cursor.create(ui, tile_x, tile_y)
    local self = { ui = ui, tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    self.state = "move"

    return self
end

function cursor:draw()
    local sprite = self.sprite[self.state]
    love.graphics.draw(sprite, self.tile_x * tile_size, self.tile_y * tile_size)

    if self.selected_unit and self.state == "move" then
        love.graphics.draw(self.selected_unit.sprite, self.tile_x * tile_size, self.tile_y * tile_size)
    end
end

function cursor:update()

end

function cursor:control(input_queue)
    local input_type = { up = "move", down = "move", left = "move", right = "move", select = "select", cancel = "cancel" }

    for input in pairs(input_queue) do
        local input_type = input_type[input]
        if input_type == "move" then
            self:move(input)
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

    -- Make cursor unmoveable to outside border.
    if self[tile_axis[direction]] + origin_direction[direction] >= 0 then
        self[tile_axis[direction]] = self[tile_axis[direction]] + origin_direction[direction]
    end
end

function cursor:select()
    -- If not selecting any unit, select the unit on cursor.
    if self.state == "move" then
        if self.selected_unit == nil then
            self.selected_unit = self:get_unit()

            if self.selected_unit then
                local feedback = { action = "select_unit" }
                feedback.data = { unit = self.selected_unit, tile_x = self.tile_x, tile_y = self.tile_y }

                self.ui:receive_feedback(feedback)
            end
        else
            -- Create feedback data.
            local feedback = { action = "select_position" }
            -- Populate data for action menu
            feedback.data = { unit = self.selected_unit, tile_x = self.tile_x, tile_y = self.tile_y }

            -- Push feedback to ui class.
            self.ui:receive_feedback(feedback)
        end
    end
    if self.state == "attack" then
        -- Create feedback for attacking that contains target position.
        local feedback = { action = "attack" }
        feedback.data = { tile_x = self.tile_x, tile_y = self.tile_y }

        self.ui:receive_feedback(feedback)
    end
end

function cursor:cancel()
    if self.state == "move" then
        self.selected_unit = nil

        local feedback = { action = "cancel_move" }
        feedback.data = { unit = self.selected_unit, tile_x = self.tile_x, tile_y = self.tile_y }

        self.ui:receive_feedback( feedback )
    end
    
    if self.state == "attack" then
        local feedback = { action = "cancel_attack" }
        feedback.data = { unit = self.selected_unit, tile_x = self.tile_x, tile_y = self.tile_y }

        self.ui:receive_feedback( feedback )
    end
end

function cursor:get_position()
    return self.tile_x * tile_size, self.tile_y * tile_size
end

function cursor:get_unit()
    return self.ui.world:get_unit(self.tile_x, self.tile_y)
end