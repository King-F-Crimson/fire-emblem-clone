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
    local world = self.ui.world
    local selected_unit = self.ui.selected_unit

    if action.action == "attack" then
        local target_unit = world:get_unit(action.data.tile_x, action.data.tile_y)
        if target_unit then
            if target_unit:can_counter_attack(world, self.ui.plan_tile_x, self.ui.plan_tile_y) then
                self.info = string.format(
                    "Attack power: %i\nHit rate: %i%%\n\nAttack power: %i\nHit rate: %i%%",
                    combat.get_attack_power(world, selected_unit, action.data.weapon, target_unit),
                    combat.get_hit_rate(world, selected_unit, action.data.weapon, target_unit),
                    combat.get_attack_power(world, target_unit, target_unit.data.active_weapon, selected_unit),
                    combat.get_hit_rate(world, target_unit, target_unit.data.active_weapon, selected_unit)
                )
            else
                self.info = string.format(
                    "Attack power: %i\nHit rate: %i%%\n\nAttack power: -\nHit rate: -",
                    combat.get_attack_power(world, selected_unit, action.data.weapon, target_unit),
                    combat.get_hit_rate(world, selected_unit, action.data.weapon, target_unit)
                )
            end
        end
    end
end

function combat_info:clear_combat_info()
    self.info = ""
end

function combat_info:draw()
    love.graphics.print(self.info, self.x, self.y)
end