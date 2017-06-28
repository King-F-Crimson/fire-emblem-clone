win_screen = {}

function win_screen.create(application)
    local self = { application = application }
    setmetatable(self, {__index = win_screen})

    self.title = love.graphics.newText(self.application.font, "You win!")

    self.zoom = 2

    return self
end

function win_screen:process_event(event)
    if event.type == "key_pressed" or event.type == "mouse_pressed" then
        self.application:change_state(title_screen)
    end
end

function win_screen:update()

end

function win_screen:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.title, (self.application:get_scaled_window_width() / self.zoom - self.title:getWidth()) / 2, self.title:getHeight())
    love.graphics.pop()
end