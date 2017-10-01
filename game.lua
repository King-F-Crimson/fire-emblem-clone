require("cursor")
require("ai")
require("ui")
require("world")
require("animation")
require("team")
require("color")
require("camera")
require("pause_menu")
require("result_screen")
require("mods")

local sti = require("libs/Simple-Tiled-Implementation/sti")

game = {}

function game.create(application, observer, args)
    local self = { application = application, observer = observer }
    setmetatable(self, {__index = game})

    self.teams = {
        team.create("Player 1 Army", color.create_from_rgb(25, 83, 255), "player"),
        team.create("Player 2 Army", color.create_from_rgb(255, 25, 25), "ai"),
    }

    self.current_team = self.teams[1]
    self.current_team_index = 1

    self.turn_count = 1

    self.is_paused = false

    self.mods = mods.create(self)
    self.mods:load("konosuba")

    self.map = sti("maps/" .. args.stage)
    self.game_mode = self.map.properties.game_mode

    self.pause_menu = pause_menu.create(self.application)
    self.animation = animation.create(self.observer)
    self.world = world.create(self.observer, self, self.mods, self.teams, self.animation, self.map)
    self.ui = ui.create(self.observer, self, self.world)
    self.ai = ai.create(self.observer, self, self.world)
    self.camera = camera.create(self.observer, self.ui)

    self.listeners = {
        self.observer:add_listener("game_end", function(args) self:game_end(args) end)
    }

    return self
end

function game:destroy()
    self.world:destroy()
    self.ui:destroy()
    self.camera:destroy()
    self.animation:destroy()

    -- Remove listeners from observer.
    observer.remove_listeners_from_object(self)
end

function game:game_end(args)
    self.application:change_state(result_screen, args)
end

function game:new_turn()
    self.observer:notify("new_turn")

    -- Change current turn, cycle if previous turn is the last team.
    self.current_team_index = self.current_team_index + 1
    if self.current_team_index > #self.teams then
        self.current_team_index = 1
    end

    self.current_team = self.teams[self.current_team_index]

    -- Update turn count once every team has made a play.
    if self.current_team_index == 1 then
        self.turn_count = self.turn_count + 1
        self.observer:notify("new_turn_cycle")
    end
end

function game:update()
    -- Camera is moveable both during and outside animation.
    self.camera:update()
    self.world:update_animation()

    if self.is_paused then
        self.pause_menu:update()
    elseif self.animation.active then
        self.animation:update()
    else
        self.ui:update()
        if self.current_team.controller == "ai" then
            self.ai:set_team(self.current_team)
            self.ai:do_step()
        end
        self.world:update()
    end
end

function game:draw()
    -- Draw the world and animation with cursor at the center of the screen.
    love.graphics.push()
        self.camera:set_translate()
        self.camera:set_zoom()

        self.world:draw("tiles")
        self.ui:draw("areas")
        self.ui:draw("cursor")
        self.world:draw("units")
        self.ui:draw("selected_unit")
        self.world:draw("health_bars")

        -- Draw animation if active.
        if self.animation.active then
            self.animation:draw()
        end
    love.graphics.pop()

    love.graphics.push()
        self.ui:draw("hud")
        self.ui:draw("menu")
    love.graphics.pop()

    if self.is_paused then
        self.pause_menu:draw()
    end
end

function game:process_event(event)
    if event.type == "key_pressed" and event.data.key == "p" then
        self.is_paused = not self.is_paused
    end
    -- Skip animations for the turn by pressing space while it is active.
    if event.type == "key_pressed" and event.data.key == "space" and self.animation.active then
        if self.current_team.controller == "player" then
            self.animation:skip_current_animation()
        elseif self.current_team.controller == "ai" then
            self.animation:skip_animations_for_this_turn()
        end
    end

    self.camera:process_event(event)

    if self.is_paused then
        self.pause_menu:process_event(event)
    else
        if self.current_team.controller == "player" then
            self.ui:process_event(event)
        end
    end
end

