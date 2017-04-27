require("game")
require("observer")
require("queue")

tile_size = 16
unit_size = 32
zoom = 2

application = {
    font = love.graphics.newImageFont("assets/font_16_height.png",
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

function application:receive_event(event)
    self.event_queue:push(event)
end

function application:key_pressed(key)
    if key == "rctrl" then
        debug.debug()
    end
    if key == "escape" then
        love.event.push("quit")
    end

    local event = { type = "key_pressed", data = { key = key } }
    self:receive_event(event)
end

function application:key_released(key)
    local event = { type = "key_released", data = { key = key } }
    self:receive_event(event)
end

function application:mouse_pressed(x, y, button)
    local event = { type = "mouse_pressed", data = { button = button, x = x, y = y} }
    self:receive_event(event)
end