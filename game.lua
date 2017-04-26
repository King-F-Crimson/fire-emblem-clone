require("cursor")
require("ui")
require("world")
require("animation")
require("team")
require("color")

game = {}

function game.create(observer)
    local self = { observer = observer }
    setmetatable(self, {__index = game})

    self.teams = {
        team.create("Player 1 Army", color.create_from_rgb(25, 83, 255)),
        team.create("Player 2 Army", color.create_from_rgb(255, 25, 25)),
    }

    self.current_turn = self.teams[1]
    self.current_turn_number = 1

    self.animation = animation.create()
    self.world = world.create(self.observer, self.teams, self.animation)
    self.ui = ui.create(self.observer, self, self.world)

    return self
end

function game:new_turn()
    self.observer:notify("new_turn")

    -- Change current turn, cycle if previous turn is the last team.
    self.current_turn_number = self.current_turn_number + 1
    if self.current_turn_number > #self.teams then
        self.current_turn_number = 1
    end

    self.current_turn = self.teams[self.current_turn_number]
end

function game:get_tile_from_coordinate(x, y)
    local translated_x, translated_y = x / zoom - self.translate.x, y / zoom - self.translate.y
    local tile_x, tile_y = math.floor(translated_x / tile_size), math.floor(translated_y / tile_size)

    return tile_x, tile_y
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
        self:center_cursor()

        self.world:draw("tiles")
        self.ui:draw("areas")
        self.world:draw("units")
        self.ui:draw("planned_unit")
        self.ui:draw("cursor")
        self.ui:draw("menu")
        
        -- Draw animation if active.
        if self.animation.active then
            self.animation:draw()
        end
    love.graphics.pop()

    love.graphics.push()
        love.graphics.scale(zoom)
        self.ui:draw("hud")
    love.graphics.pop()
end

function game:center_cursor()
    local cursor_x, cursor_y = self.ui.cursor:get_position()
    self.translate = { x = love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), y = love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2) }
    love.graphics.translate(self.translate.x, self.translate.y)
end

function game:process_event(event)
    self.ui:process_event(event)
end