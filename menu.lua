require("utility")

menu = {}

function menu.create(ui, menu_type, content_data, x, y)
    local self = { ui = ui, observer = ui.observer, menu_type = menu_type, x = x, y = y }
    setmetatable(self, { __index = menu })

    self:generate_content(content_data)

    -- Notify menu creation, passing data on current action for objects that need it such as combat_info.
    self.observer:notify("menu_created", self.actions[self.pointer])

    return self
end

function menu:generate_content(content_data)
    self.items = {}
    self.actions = {}
    self.pointer = 1

    if self.menu_type == "action" then
        self.items  = { "Wait", "Attack", "Items" }
        self.actions = { {action = "wait"}, {action = "prompt_attack"}, {action = "items"} }
    elseif self.menu_type == "turn" then
        self.items = { "End turn" }
        self.actions = { {action = "end_turn"} }
    elseif self.menu_type == "weapon_select" then
        self:create_weapon_select_content(content_data)
    end

    self.item_count = #self.items
end

function menu:create_weapon_select_content(content_data)
    self.items = {}
    self.actions = {}

    local weapons = content_data.weapons
    for k, weapon in pairs(weapons) do
        table.insert(self.items, weapon.name)
        table.insert(self.actions, {action = "attack",
            data = { weapon = weapon, tile_x = content_data.tile_x, tile_y = content_data.tile_y }} )
    end
end

function menu:control(input_queue)
    for input, data in pairs(input_queue) do
        -- Move the selected item with keys.
        if input == "up" then
            self:move("up")
        elseif input == "down" then
            self:move("down")
        elseif input == "select" then
            -- Push feedback to ui.
            self:push_feedback(self.actions[self.pointer])
        elseif input == "cancel" then
            self:push_feedback({ action = "cancel" })
        elseif input == "mouse_pressed" then
            self:mouse_pressed(data)
        end
    end
end

function menu:move(direction)
    if direction == "up" then
        if self.pointer == 1 then
            self.pointer = self.item_count    -- If self.pointer is at first item, set it to the last item.
        else
            self.pointer = self.pointer - 1
        end
    elseif direction == "down" then
        if self.pointer == self.item_count then
            self.pointer = 1             -- If self.pointer is at last item, set it to the first item.
        else
            self.pointer = self.pointer + 1
        end
    end

    self.observer:notify("menu_moved", self.actions[self.pointer])
end

function menu:mouse_pressed(data)
    if data.button == 1 then
        local index = self:get_index_from_coordinate(data.x, data.y)

        if index >= 1 and index <= self.item_count then
            if self.pointer == index then
                self:push_feedback(self.actions[self.pointer])
            else
                self.pointer = index
            end
        end
    end
    if data.button == 2 then
        self:push_feedback({ action = "cancel" })
    end
end

function menu:get_index_from_coordinate(x, y)
    local index = math.floor((y / zoom - self.y) / app.font:getHeight()) + 1
    return index
end

function menu:push_feedback(feedback)
    self.ui:receive_feedback(feedback)
end

function menu:draw()
    local output = ""

    for i = 1, self.item_count do
        -- If the item is selected print the character '-' in front of it, else it's blank or a space.
        if i == self.pointer then
            output = output .. "-"
        else
            output = output .. " "
        end
        output = output .. self.items[i] .. "\n"
    end

    love.graphics.print(output, self.x, self.y)
end