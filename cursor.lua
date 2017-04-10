cursor = {
    sprite = love.graphics.newImage("assets/cursor.png")
}
cursor.sprite:setFilter("nearest")

function cursor.create(ui, tile_x, tile_y)
    local self = { ui = ui, tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    return self
end

function cursor:draw()
    love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)

    if self.selected_unit then
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

    self[tile_axis[direction]] = self[tile_axis[direction]] + origin_direction[direction]
end

function cursor:select()
    -- If not selecting any unit, select the unit on cursor.
    if self.selected_unit == nil then
        self.selected_unit = self:get_unit()
    else
        -- Create feedback data.
        local feedback = { action = "create_action_menu" }
        feedback.x, feedback.y = self:get_position()
        -- Populate data for action menu
        feedback.action_menu_data = {}
        feedback.action_menu_data.unit = self.selected_unit
        feedback.action_menu_data.tile_x = self.tile_x
        feedback.action_menu_data.tile_y = self.tile_y
        feedback.action_menu_data.content = { wait = true, items = true }

        -- Push feedback to ui class.
        self.ui:receive_feedback(feedback)

        -- Move unit.
        -- self.app.world.map.layers.unit_layer:move_unit(self.selected_unit, self.tile_x, self.tile_y)
        -- self.selected_unit = nil
    end
end

function cursor:cancel()
    self.selected_unit = nil
end

function cursor:get_position()
    return self.tile_x * tile_size, self.tile_y * tile_size
end

function cursor:get_unit()
    return self.ui.world:get_unit(self.tile_x, self.tile_y)
end