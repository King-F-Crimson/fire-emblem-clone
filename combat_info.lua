require("combat")

combat_info = {}

function combat_info.create(observer, ui, x, y)
    local self = { observer = observer, ui = ui, x = x, y = y, info = "" }
    setmetatable(self, {__index = combat_info})

    self.observer:add_listener("menu_moved", function(action) self:set_combat_info(action) end)
    self.observer:add_listener("menu_created", function(action) self:set_combat_info(action) end)
    self.observer:add_listener("menu_destroyed", function() self:clear_combat_info() end)

    return self
end

function combat_info:set_combat_info(action)
    if action.action == "attack" then
        self.info = string.format(
            "Attack power: %i\nHit rate: %i",
            combat.get_attack_power(self.ui.world, self.ui.selected_unit, self.ui.world:get_unit(action.data.tile_x, action.data.tile_y)),
            combat.get_hit_rate(self.ui.world, self.ui.selected_unit, self.ui.world:get_unit(action.data.tile_x, action.data.tile_y))
        )
    end
end

function combat_info:clear_combat_info()
    self.info = ""
end

function combat_info:draw()
    love.graphics.print(self.info, self.x, self.y)
end