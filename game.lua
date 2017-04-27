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

    self.world_zoom = 2
    self.min_world_zoom = 1
    self.max_world_zoom = 8

    self.translate = { x = 0, y = 0 }
    self.translate_mode = "center_cursor"

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
    local translated_x, translated_y = (x / zoom - self.translate.x) / self.world_zoom, (y / zoom - self.translate.y) / self.world_zoom
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

        if self.translate_mode == "center_cursor" then
            self:set_translate_to_center_cursor()
        elseif self.translate_mode == "not_center_cursor" then

        end
        love.graphics.translate(self.translate.x, self.translate.y)

        love.graphics.push()
            love.graphics.scale(self.world_zoom)
            self.world:draw("tiles")
            self.ui:draw("areas")
            self.world:draw("units")
            self.ui:draw("planned_unit")
            self.ui:draw("cursor")

            -- Draw animation if active.
            if self.animation.active then
                self.animation:draw()
            end
        love.graphics.pop()

        self.ui:draw("menu")

    love.graphics.pop()

    love.graphics.push()
        love.graphics.scale(zoom)
        self.ui:draw("hud")
    love.graphics.pop()
end

function game:set_translate_to_center_cursor()
    local cursor_x, cursor_y = self.ui.cursor:get_position()
    local cursor_center_x, cursor_center_y = (cursor_x + (tile_size / 2)) * self.world_zoom, (cursor_y + (tile_size / 2)) * self.world_zoom
    local screen_center_x, screen_center_y = love.graphics.getWidth() / 2 / zoom, love.graphics.getHeight() / 2 / zoom

    self.translate = { x = screen_center_x - cursor_center_x, y =  screen_center_y - cursor_center_y }
end

function game:zoom_world_using_mouse_wheel(x, y)
    if y > 5 and self.world_zoom < self.max_world_zoom then
        self.world_zoom = self.world_zoom + 1
    elseif y < -5 and self.world_zoom > self.min_world_zoom then
        self.world_zoom = self.world_zoom - 1
    end
end

function game:process_event(event)
    -- Change translate mode according to how the player moves the cursor.
    if event.type == "key_pressed" then
        self.translate_mode = "center_cursor"
    elseif event.type == "mouse_pressed" then
        self.translate_mode = "not_center_cursor"
    elseif event.type == "mouse_wheel_moved" then
        self:zoom_world_using_mouse_wheel(event.data.x, event.data.y)
    end

    self.ui:process_event(event)
end