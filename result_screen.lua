result_screen = {}

function result_screen.create(application, observer, args)
    local self = { application = application }
    setmetatable(self, {__index = result_screen})

    if args.winner == "player" then
        self.title = love.graphics.newText(self.application.font, "You win!")
    else
        self.title = love.graphics.newText(self.application.font, "You lose!")
    end

    self.zoom = 2

    return self
end

function result_screen:destroy()
    
end

function result_screen:process_event(event)
    if event.type == "key_pressed" or event.type == "mouse_pressed" then
        self.application:change_state(title_screen)
    end
end

function result_screen:update()

end

function result_screen:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.title, (self.application:get_scaled_window_width() / self.zoom - self.title:getWidth()) / 2, self.title:getHeight())
    love.graphics.pop()
end