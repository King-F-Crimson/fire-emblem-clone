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

function ui.create(observer, world)
    local self = { observer = observer, world = world }
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
    self.observer:add_listener("world_changed", function() self:generate_danger_area() end)
    self.observer:add_listener("unit_deleted", function(unit) self:remove_unit_references(unit) end)

    return self
end

function ui:process_input(key, pressed)
    local input = self.input_map[key]

    if input and pressed then
        self.input_queue[input] = true
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

function ui:create_menu(menu_type)
    self.menu = menu.create(self, menu_type, self.cursor.tile_x + 1, self.cursor.tile_y)
end

function ui:create_area(area)
    local unit = self.selected_unit
    if area == "move" then
        self.areas.move = unit:get_movement_area(self.world)
    elseif area == "attack" then
        self.areas.attack = unit:get_attack_area(self.world, self.plan_tile_x, self.plan_tile_y)
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

function ui:draw()
    self.hud:draw()

    -- Translate screen.
    love.graphics.push()
        local cursor_x, cursor_y = self.cursor:get_position()
        love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

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

        -- Draw temporary unit sprite if there's any.
        if self.plan_sprite then
            if self.state == moving or self.state == menu_control then
                love.graphics.draw(self.plan_sprite, self.cursor.tile_x * tile_size, self.cursor.tile_y * tile_size)
            elseif self.state == attacking then
                love.graphics.draw(self.plan_sprite, self.plan_tile_x * tile_size, self.plan_tile_y * tile_size)
            end
        end

        self.cursor:draw()

        -- Draw action menu if there's any.
        if self.menu then
            self.menu:draw()
        end

    love.graphics.pop()
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