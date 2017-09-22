require("hud")
require("cursor")
require("menu")
require("ui_states")

ui = {
    sprite = {
        move_area = love.graphics.newImage("assets/move_area.png"),
        attack_area = love.graphics.newImage("assets/attack_area.png"),
        danger_area = love.graphics.newImage("assets/attack_area.png"),
    }
}

ui.sprite.move_area:setFilter("nearest")
ui.sprite.attack_area:setFilter("nearest")
ui.sprite.danger_area:setFilter("nearest")

function ui.create(observer, game, world)
    local self = { observer = observer, game = game, world = world }
    setmetatable(self, {__index = ui})

    self.hud = hud.create(self)
    self.cursor = cursor.create(self, 8, 8)
    self.menu = nil

    self.active_input = "cursor"
    self.state = browsing

    self.areas = {}

    -- In marked_units the unit table is the key, with a truth value as the value.
    self.marked_units = {}

    self.areas.danger = {}

    self.input_map = { w = "up", r = "down", a = "left", s = "right", z = "select", c = "cancel" }
    self.input_queue = {}

    -- To store temporary movement data (e.g. before attacking to store the unit position).
    self.plan_tile_x = nil
    self.plan_tile_y = nil

    -- Feedback data from cursor or menu (e.g. cursor sending selected unit data to create menu).
    self.feedback_queue = {}

    -- Create a listener for world_changed event.
    -- Make it regenerate danger area.
    -- Clear marked_units and danger_area at begining of new turn.
    self.listeners = {
        self.observer:add_listener("world_changed", function() self:generate_danger_area() end),
        self.observer:add_listener("unit_deleted", function(unit) self:remove_unit_references(unit) end),
        self.observer:add_listener("new_turn", function() self.marked_units = {}; self.areas.danger = {}; end),
    }

    return self
end

function ui:destroy()
    self.hud:destroy()

    observer.remove_listeners_from_object(self)
end

function ui:process_event(event)
    if event.type == "key_pressed" then
        local input = self.input_map[event.data.key]

        if input and event.type == "key_pressed" then
            self.input_queue[input] = true
        end
    elseif event.type == "mouse_pressed" then
        self.input_queue["mouse_pressed"] = event.data
    end
end

function ui:receive_feedback(feedback)
    table.insert(self.feedback_queue, feedback)
end

function ui:process_feedback_queue()
    for k, feedback in pairs(self.feedback_queue) do
        self.state.process_feedback(self, feedback)
    end
end

function ui:create_menu(menu_type, content_data)
    local cursor_x, cursor_y = self.cursor:get_position()
    cursor_x, cursor_y = cursor_x * self.game.camera.zoom, cursor_y * self.game.camera.zoom

    local translated_cursor_x, translated_cursor_y = cursor_x + self.game.camera.translate.x, cursor_y + self.game.camera.translate.y

    self.menu = menu.create(self, menu_type, content_data, translated_cursor_x + tile_size * self.game.camera.zoom, translated_cursor_y)
end

function ui:destroy_menu()
    self.observer:notify("menu_destroyed")
    self.menu = nil
end

function ui:create_area(area)
    local unit = self.selected_unit
    if area == "move" then
        self.areas.move = unit:get_movement_area(self.world)
    elseif area == "attack" then
        self.areas.attack = unit:get_attack_area(self.world, self.plan_tile_x, self.plan_tile_y, "standard_attack")
    elseif area == "special" then
        self.areas.attack = unit:get_attack_area(self.world, self.plan_tile_x, self.plan_tile_y, "special")
    elseif area == "danger" then
        self:generate_danger_area()
    end
end

function ui:draw_area(area)
    local sprite = self.sprite[area .. "_area"]

    for k, tile in pairs(self.areas[area]) do
        love.graphics.draw(sprite, tile.x * tile_size, tile.y * tile_size)
    end
end

function ui:remove_unit_references(unit)
    -- Remove unit from marked_units and selected_unit if selected.
    self.marked_units[unit] = nil
    if self.selected_unit == unit then
        self.selected_unit = nil
    end
end

function ui:generate_danger_area()
    self.areas.danger = {}

    -- Get the danger area for every marked unit.
    for unit in pairs(self.marked_units) do
        local unit_danger_area = unit:get_danger_area(self.world)

        for k, tile in pairs(unit_danger_area) do
            -- If the tile is not yet in danger area, add it.
            if not self.areas.danger[k] then
                self.areas.danger[k] = tile
            end
        end
    end
end

function ui:is_in_area(area, tile_x, tile_y)
    local function key(x, y) return string.format("(%i, %i)", x, y) end
    return self.areas[area][key(tile_x, tile_y)] ~= nil
end

function ui:draw(component)
    if component == "hud" then
        self.hud:draw()
    elseif component == "areas" then
        self:draw_areas()
    elseif component == "selected_unit" then
        self:draw_selected_unit()
    elseif component == "cursor" then
        self.cursor:draw()
    elseif component == "menu" then
        if self.menu then
            self.menu:draw()
        end
    end
end

function ui:draw_areas()
    -- Draw movement area if exist (during movement state).
    if self.state == moving then
        self:draw_area("move")
    end

    -- Draw attack area if exist (during attack state).
    if self.state == attacking then
        self:draw_area("attack")
    end

    -- Draw danger area if exist.
    self:draw_area("danger")
end

function ui:draw_selected_unit()
    if self.selected_unit then
        local tile_x, tile_y
        if self.state == moving then
            tile_x, tile_y = self.cursor.tile_x, self.cursor.tile_y
        elseif self.state == attacking or self.state == menu_control then
            tile_x, tile_y = self.plan_tile_x, self.plan_tile_y
        end

        love.graphics.push()
            love.graphics.scale(tile_size / unit_size)
            self.selected_unit:draw("run", tile_x * unit_size, tile_y * unit_size)
            self.selected_unit:draw_health_bar(tile_x * unit_size, tile_y * unit_size)
        love.graphics.pop()
    end
end

function ui:update()
    -- Transfer the control according to the active state.
    if self.active_input == "cursor" then
        self.cursor:control(self.input_queue)
    elseif self.active_input == "menu" then
        self.menu:control(self.input_queue)
    end

    self:process_feedback_queue()

    -- Reset the input queue and feedback queue.
    self.input_queue = {}
    self.feedback_queue = {}
end