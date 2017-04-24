require("cursor")
require("action_menu")
require("ui_states")

ui = {
    sprite = {
        move_area = love.graphics.newImage("assets/move_area.png"),
        attack_area = love.graphics.newImage("assets/attack_area.png"),
    }
}

ui.sprite.move_area:setFilter("nearest")
ui.sprite.attack_area:setFilter("nearest")

function ui.create(world)
    local self = { world = world }
    setmetatable(self, {__index = ui})

    self.active_input = "cursor"
    self.state = browsing

    self.areas = {}

    self.input_map = { w = "up", r = "down", a = "left", s = "right", z = "select", c = "cancel" }
    self.input_queue = {}

    self.cursor = cursor.create(self, 8, 8)
    self.action_menu = nil

    -- To store temporary movement data (e.g. before attacking to store the unit position).
    self.plan_tile_x = nil
    self.plan_tile_y = nil

    -- Feedback data from cursor or action_menu (e.g. cursor sending selected unit data to create action_menu).
    self.feedback_queue = {}

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

function ui:create_action_menu()
    self.action_menu = action_menu.create(self, self.cursor.tile_x + 1, self.cursor.tile_y)
end

function ui:create_area(area)
    local unit = self.selected_unit
    if area == "move" then
        self.areas[area] = self.world:get_tiles_in_distance{tile_x = unit.tile_x, tile_y = unit.tile_y, distance = unit.movement, movement_filter = unit.movement_filter, unlandable_filter = unit.unlandable_filter}
    elseif area == "attack" then
        -- Default min_range to 1.
        local min_range = unit.data.weapon.min_range or 1
        self.areas[area] = self.world:get_tiles_in_distance{tile_x = self.plan_tile_x, tile_y = self.plan_tile_y, distance = unit.data.weapon.range, min_distance = min_range}
    end
end

function ui:draw_area(area)
    local sprite = self.sprite[area .. "_area"]

    for k, tile in pairs(self.areas[area]) do
        love.graphics.draw(sprite, tile.x * tile_size, tile.y * tile_size)
    end
end

function ui:is_in_area(area, tile_x, tile_y)
    local function key(x, y) return string.format("(%i, %i)", x, y) end
    return self.areas[area][key(tile_x, tile_y)] ~= nil
end

function ui:draw()
    -- Draw unit information.
    local unit = self.cursor:get_unit()
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.data.health, unit.strength, unit.speed)
        if unit.data.weapon then
            info = string.format("%s\nWeapon: %s", info, unit.data.weapon.name)
        end
        love.graphics.print(info, tile_size, tile_size)
    end

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

    -- Draw temporary unit sprite if there's any.
    if self.plan_sprite then
        if self.state == moving or self.state == action_menu_control then
            love.graphics.draw(self.plan_sprite, self.cursor.tile_x * tile_size, self.cursor.tile_y * tile_size)
        elseif self.state == attacking then
            love.graphics.draw(self.plan_sprite, self.plan_tile_x * tile_size, self.plan_tile_y * tile_size)
        end
    end

    self.cursor:draw()

    -- Draw action menu if there's any.
    if self.action_menu then
        self.action_menu:draw()
    end

    love.graphics.pop()
end

function ui:update()
    -- Transfer the control according to the active state.
    if self.active_input == "cursor" then
        self.cursor:control(self.input_queue)
    elseif self.active_input == "action_menu" then
        self.action_menu:control(self.input_queue)
    end

    self:process_feedback_queue()

    -- Reset the input queue and feedback queue.
    self.input_queue = {}
    self.feedback_queue = {}
end