level_selection = {}

function level_selection.create(application)
    local self = { application = application }
    setmetatable(self, {__index = level_selection})

    self:load_maps()
    self.pointer = 1

    self.title = love.graphics.newText(self.application.font, "Level Selection")
    self.stage_name = love.graphics.newText(self.application.font, self.maps[self.pointer])

    self.zoom = 2

    return self
end

function level_selection:destroy()
    
end

function level_selection:load_maps()
    self.maps = {}

    local files = love.filesystem.getDirectoryItems("maps")

    for k, file in ipairs(files) do
        -- Only add the file if it ends with the ".lua" extension.
        if file:sub(-4) == ".lua" then
            table.insert(self.maps, file)
        end
    end
end

function level_selection:move(direction)
    if direction == "up" then
        if self.pointer == 1 then
            self.pointer = #self.maps    -- If self.pointer is at first item, set it to the last item.
        else
            self.pointer = self.pointer - 1
        end
    elseif direction == "down" then
        if self.pointer == #self.maps then
            self.pointer = 1             -- If self.pointer is at last item, set it to the first item.
        else
            self.pointer = self.pointer + 1
        end
    end

    self.stage_name = love.graphics.newText(self.application.font, self.maps[self.pointer])
end

function level_selection:control(event)
    local key = event.data.key
    local button = event.data.button

    if key == "a" then
        self:move("up")
    elseif key == "s" then
        self:move("down")
    -- Make it confirmable with left-click too.
    elseif key == "space" or button == 1 then
        local stage = self.maps[self.pointer]

        self.application:change_state(game, {stage = stage})
    end
end

function level_selection:process_event(event)
    if event.type == "key_pressed" or event.type == "mouse_pressed" then
        self:control(event)
    end
end

function level_selection:update()

end

function level_selection:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.title, (self.application:get_scaled_window_width() / self.zoom - self.title:getWidth()) / 2, self.title:getHeight())
        love.graphics.draw(self.stage_name, (self.application:get_scaled_window_width() / self.zoom - self.stage_name:getWidth()) / 2, self.application:get_scaled_window_height() / self.zoom / 2)
    love.graphics.pop()
end