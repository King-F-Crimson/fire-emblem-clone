title_screen = {}

function title_screen.create(application)
    local self = { application = application }
    setmetatable(self, {__index = title_screen})

    self.title = love.graphics.newText(self.application.font, "Fire Emblem Clone")
    self.instruction = love.graphics.newText(self.application.font, "Press any button to start!")

    self.zoom = 2

    return self
end

function title_screen:process_event(event)
    if event.type == "key_pressed" or event.type == "mouse_pressed" then
        self.application:change_state(game)
    end
end

function title_screen:update()

end

function title_screen:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.title, (self.application:get_scaled_window_width() / self.zoom - self.title:getWidth()) / 2, self.title:getHeight())
        love.graphics.draw(self.instruction, (self.application:get_scaled_window_width() / self.zoom - self.instruction:getWidth()) / 2, self.application:get_scaled_window_height() / self.zoom - self.instruction:getHeight() * 2)
    love.graphics.pop()
end