require("cursor")
require("ui")
require("world")
require("animation")

game = {}

function game.create(observer)
    local self = { observer = observer }
    setmetatable(self, {__index = game})

    self.animation = animation.create()
    self.world = world.create(self.observer, self.animation)
    self.ui = ui.create(self.observer, self.world)

    return self
end

function game:update()
    if self.animation.active then
        self.animation:update()
    else
        self.ui:update()
        self.world:update()
    end
end

function game:draw()
    -- Draw the world and animation with cursor at the center of the screen.
    love.graphics.push()
    love.graphics.scale(zoom)

    local cursor_x, cursor_y = self.ui.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.world:draw()
    
    -- Draw animation if active.
    if self.animation.active then
        self.animation:draw()
    end

    love.graphics.pop()

    -- Draw UI without translation.
    love.graphics.push()
    love.graphics.scale(zoom)
    
    self.ui:draw()

    love.graphics.pop()
end

function game:process_input(key, pressed)
    self.ui:process_input(key, pressed)
end