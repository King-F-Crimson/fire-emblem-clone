ui = {}

function ui.create(application)
    local self = { app = application }
    setmetatable(self, {__index = ui})

    return self
end

function ui:draw()
    local info = self.app.cursor:get_info()
    love.graphics.print(info)
end

function ui:update()

end