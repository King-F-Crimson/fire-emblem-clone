require("game")
require("observer")

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
    love.keyboard.setKeyRepeat(true)

    self.observer = observer.create()
    self.game = game.create(self.observer)

    return self
end

function application:update()
    self.game:update()
end

function application:draw()
    self.game:draw()
end

function application:keypressed(key)
    if key == "rctrl" then
        debug.debug()
    end
    if key == "escape" then
        love.event.push("quit")
    end

    self.game:process_input(key, true)
end

function application:keyreleased(key)
    self.game:process_input(key, false)
end