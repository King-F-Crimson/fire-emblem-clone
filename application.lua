require("cursor")
require("ui")
require("world")

application = {
    font = love.graphics.newImageFont("assets/font.png",
    " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\"")
}
application.font:setFilter("nearest")
love.graphics.setFont(application.font)

function application.create()
    local self = {}
    setmetatable(self, { __index = application })

    love.window.setFullscreen(true, "desktop")

    self.ui = ui.create(self)
    self.world = world.create()
    return self
end

function application:update()
    self.world:update()
    self.ui:update()
end

function application:draw()
    -- Draw the world with cursor at the center of the screen.
    love.graphics.push()
    love.graphics.scale(zoom)

    local cursor_x, cursor_y = self.ui.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.world:draw()
    love.graphics.pop()

    -- Draw UI without translation.
    love.graphics.push()
    love.graphics.scale(zoom)
    
    self.ui:draw()

    love.graphics.pop()
end

function application:keypressed(key)
    if key == "escape" then
        love.event.push("quit")
    end

    self.ui.cursor:process_input(key, true)
end

function application:keyreleased(key)
    self.ui.cursor:process_input(key, false)
end