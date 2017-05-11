title_screen = {}

function title_screen.create(application)
    local self = { application = application }
    setmetatable(self, {__index = title_screen})

    return self
end

function title_screen:process_event(event)
    if event.type == "key_pressed" then
        self.application:change_state(game)
    end
end

function title_screen:update()

end

function title_screen:draw()
    love.graphics.push()
        love.graphics.scale(4)
        love.graphics.print("Fire Emblem Clone", 20, 20)
    love.graphics.pop()
end