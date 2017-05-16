pause_menu = {}

function pause_menu.create(application)
    local self = { application = application }
    setmetatable(self, {__index = pause_menu})

    self.text = love.graphics.newText(self.application.font, "Paused")

    self.zoom = 4

    return self
end

function pause_menu:update()

end

function pause_menu:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        love.graphics.draw(self.text, (love.graphics.getWidth() / self.zoom - self.text:getWidth()) / 2, self.text:getHeight())
    love.graphics.pop()
end

function pause_menu:process_event()

end