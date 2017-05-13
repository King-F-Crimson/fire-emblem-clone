pause_menu = {}

function pause_menu.create()
    local self = {}
    setmetatable(self, {__index = pause_menu})

    return self
end

function pause_menu:update()

end

function pause_menu:draw()
    love.graphics.print("Paused")
end

function pause_menu:process_event()

end