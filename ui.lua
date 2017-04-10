require("cursor")
require("action_menu")

ui = {}

function ui.create(world)
    local self = { world = world }
    setmetatable(self, {__index = ui})

    self.state = "cursor"

    self.input_map = { w = "up", r = "down", a = "left", s = "right", z = "select", c = "cancel" }
    self.input_queue = {}

    self.cursor = cursor.create(self, 8, 8)
    self.action_menu = nil

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
        if feedback.action == "create_action_menu" then
            self.state = "action_menu"
            self.action_menu = action_menu.create(self, feedback.action_menu_data, feedback.x + tile_size, feedback.y)
        end
        if feedback.action == "close_action_menu" then
            self.state = "cursor"
            self.action_menu = nil
        end
        if feedback.action == "wait" then
            self.state = "cursor"
            self.cursor.selected_unit = nil
            -- Move unit.
            self.world:move_unit(feedback.unit, feedback.tile_x, feedback.tile_y)
            self.action_menu = nil
        end
    end
end

function ui:draw()
    -- Draw unit information.
    local unit = self.cursor:get_unit()
    if unit then
        local info = string.format("%s\nHealth: %i\nStrength: %i\nSpeed: %i", unit.name, unit.health, unit.strength, unit.speed)
        love.graphics.print(info, tile_size, tile_size)
    end

    -- Draw cursor and action_menu at the center of the screen.
    love.graphics.push()

    local cursor_x, cursor_y = self.cursor:get_position()
    love.graphics.translate(love.graphics.getWidth() / zoom / 2 - cursor_x - (tile_size / 2), love.graphics.getHeight() / zoom / 2 - cursor_y - (tile_size / 2))

    self.cursor:draw()

    -- Draw action menu if there's any.
    if self.action_menu then
        self.action_menu:draw()
    end

    love.graphics.pop()
end

function ui:update()
    -- Transfer the control according to the active state.
    if self.state == "cursor" then
        self.cursor:control(self.input_queue)
    elseif self.state == "action_menu" then
        self.action_menu:control(self.input_queue)
    end

    self:process_feedback_queue()

    -- Reset the input queue and feedback queue.
    self.input_queue = {}
    self.feedback_queue = {}
end