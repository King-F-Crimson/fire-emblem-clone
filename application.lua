require("game")
require("title_screen")
require("observer")
require("queue")

tile_size = 16
unit_size = 32

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
    love.graphics.setBackgroundColor(32, 32, 32)

    math.randomseed(os.time())

    self.zoom = 2

    self.observer = observer.create()
    self.state = title_screen.create(self, self.observer)

    self.event_queue = queue.create()

    return self
end

function application:get_scaled_window_width()
    return love.graphics.getWidth() / self.zoom
end

function application:get_scaled_window_height()
    return love.graphics.getHeight() / self.zoom
end

function application:update()
    while not self.event_queue:empty() do
        self.state:process_event(self.event_queue:pop())
    end
    self.state:update()
end

function application:draw()
    love.graphics.push()
        love.graphics.scale(self.zoom)
        self.state:draw()
    love.graphics.pop()
end

function application:change_state(new_state, state_args)
    self.state:destroy()

    self.state = new_state.create(self, self.observer, state_args)
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

function application:mouse_wheel_moved(x, y)
    local event = { type = "mouse_wheel_moved", data = { x = x, y = y } }
    self:receive_event(event)
end