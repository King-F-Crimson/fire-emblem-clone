cursor = {
    sprite = love.graphics.newImage("assets/cursor.png")
}
cursor.sprite:setFilter("nearest")

function cursor.create(application, tile_x, tile_y)
    local self = { app = application, tile_x = tile_x, tile_y = tile_y }
    setmetatable(self, { __index = cursor })

    self.input_map = { w = "up", r = "down", a = "left", s = "right", z = "select" }
    
    self.select_queue = false
    self.selected_unit = nil

    self.movement_map = { w = "up", r = "down", a = "left", s = "right" }
    self.move_queue = { up = false, down = false, left = false, right = false }

    -- Timer is countdown in tick (1/60 second).
    -- Timer for rapid input when button is held.
    self.rapid_time = 10
    -- Timer for subsequent movements when rapid input is activated.
    self.rapid_rate = 3
    self.move_timer = { up = self.rapid_time, down = self.rapid_time, left = self.rapid_time, right = self.rapid_time }

    return self
end

function cursor:draw()
    love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)

    if self.selected_unit then
        love.graphics.print(self.selected_unit:get_info(), self.tile_x * tile_size + tile_size, self.tile_y * tile_size)
    end
end

function cursor:update()
    self:move()
    if self.select_queue then
        self:handle_select()
        self.select_queue = false
    end
end

function cursor:move()
    local tile_axis = { up = "tile_y", down = "tile_y", left = "tile_x", right = "tile_x" }
    local origin_direction = { up = -1, down = 1, left = -1, right = 1 }
    local opposite = {up = "down", down = "up", left = "right", right = "left" }

    for key, d in pairs(self.movement_map) do  -- d = direction
        if self.move_queue[d] or self.move_timer[d] == 0 then
            self[tile_axis[d]] = self[tile_axis[d]] + origin_direction[d]
            self.move_queue[d] = false
            if self.move_timer[d] == 0 then
                self.move_timer[d] = self.rapid_rate
            end
        end

        if love.keyboard.isDown(key) and self.move_timer[d] ~= 0 then
            self.move_timer[d] = self.move_timer[d] - 1
            self.move_timer[opposite[d]] = self.rapid_time
        end
    end
end

function cursor:handle_select()
    if self.selected_unit == nil then
        self:select_unit()
    else
        -- Move unit.
        self.app.world.map.layers.unit_layer:move_unit(self.selected_unit, self.tile_x, self.tile_y)
        self.selected_unit = nil
    end
end

function cursor:select_unit()
    self.selected_unit = self:get_unit()
end

function cursor:process_input(key, pressed)
    local input_type = { up = "move", down = "move", left = "move", right = "move", select = "select" }

    -- If pressed is false the event is key_released.
    local input = self.input_map[key]
    local input_type = input_type[input]

    if input ~= nil then
        if input_type == "move" then
            if pressed then
                self.move_queue[input] = true
                -- Reset rapid movement if a new directional key is pressed.
                for direction, timer in pairs(self.move_timer) do
                    self.move_timer[direction] = self.rapid_time
                end
            else
                self.move_timer[input] = self.rapid_time
            end
        end

        if input_type == "select" and pressed then
            self.select_queue = true
        end
    end
end

function cursor:get_position()
    return self.tile_x * tile_size, self.tile_y * tile_size
end

function cursor:get_unit()
    return self.app.world:get_unit(self.tile_x, self.tile_y)
end

-- TODO: remove this function and replace its occurences with cursor:get_unit()
function cursor:get_info()
    local unit = self.app.world:get_unit(self.tile_x, self.tile_y)
    if unit then
        return unit:get_info()
    else
        return ""
    end
end