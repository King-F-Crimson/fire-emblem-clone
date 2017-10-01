map_info = {}

function map_info.create(observer, ui, x, y)
    local self = { observer = observer, ui = ui, x = x, y = y }
    setmetatable(self, {__index = map_info})

    self:determine_objective()
    self:update_turn_info()

    self.listeners = {
        self.observer:add_listener("new_turn", function() self:update_turn_info() end)
    }

    return self
end

function map_info:destroy()
    observer.remove_listeners_from_object(self)
end

function map_info:determine_objective()
    local game_mode = self.ui.game.game_mode

    if game_mode == "death_match" then
        self.objective = "Kill all the enemies"
    elseif game_mode == "defense" then
        self.objective = string.format("Defend the orange tiles for %i turns.", self.ui.world.map.properties.turns_to_defend_for)
    end
end

function map_info:update_turn_info()
    self.turn_info = string.format("Turn: %i", self.ui.game.turn_count)
end

function map_info:draw()
    local info = string.format("%s\n%s", self.objective, self.turn_info)

    love.graphics.print(info, self.x, self.y)
end