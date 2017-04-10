action_menu = {}

function action_menu.create(content, x, y)
    local self = {}
    setmetatable(self, { __index = action_menu })

    self.x, self.y = x, y
    self:generate_content(content)

    return self
end

function action_menu:generate_content(content)
    self.items = {}
    self.actions = {}
    self.pointer = 1

    if content.wait then
        table.insert(self.items, "Wait") 
        table.insert(self.actions, function() print("Wait pressed") end) --TODO insert function for wait.
    end
    if content.items then
        table.insert(self.items, "Items")
        table.insert(self.actions, function() print("Items pressed") end)
    end

    self.item_count = #self.items
end

function action_menu:control(input_queue)
    for input in pairs(input_queue) do
        -- Move the selected item with keys.
        if input == "up" then
            -- self.scroll_sound:play()
            if self.pointer == 1 then
                self.pointer = self.item_count    -- If self.pointer is at first item, set it to the last item.
            else
                self.pointer = self.pointer - 1
            end
        end
        if input == "down" then
            -- self.scroll_sound:play()
            if self.pointer == self.item_count then
                self.pointer = 1             -- If self.pointer is at last item, set it to the first item.
            else
                self.pointer = self.pointer + 1
            end
        end
        if input == "select" then
            -- self.select_sound:play()
            self.actions[self.pointer]()
        end
    end
end

function action_menu:draw()
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