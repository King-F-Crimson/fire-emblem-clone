require("game")
require("observer")
require("queue")

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

    self.event_queue = queue.create()

    return self
end

function application:update()
    while not self.event_queue:empty() do
        self.game:process_event(self.event_queue:pop())
    end    
    self.game:update()
end

function application:draw()
    self.game:draw()
end

function application:receieve_event(event)
    self.event_queue:push(event)
end

function application:keypressed(key)
    if key == "rctrl" then
        debug.debug()
    end
    if key == "escape" then
        love.event.push("quit")
    end

    local event = { type = "key_pressed", data = { key = key } }
    self:receieve_event(event)
end

function application:keyreleased(key)
    local event = { type = "key_released", data = { key = key } }
    self:receieve_event(event)
end