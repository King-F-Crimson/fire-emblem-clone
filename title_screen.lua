title_screen = {}

function title_screen.create(application)
    local self = { application = application }
    setmetatable(self, {__index = title_screen})

    self.title = love.graphics.newText(self.application.font, "Fire Emblem Clone")
    self.title_width = self.title:getWidth()

    self.instruction = love.graphics.newText(self.application.font, "Press any button to start!")
    self.instruction_width = self.instruction:getWidth()

    self.zoom = 4

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
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.title, (love.graphics.getWidth() / self.zoom - self.title_width) / 2, 20)
        love.graphics.draw(self.instruction, (love.graphics.getWidth() / self.zoom - self.instruction_width) / 2, 200)
    love.graphics.pop()
end