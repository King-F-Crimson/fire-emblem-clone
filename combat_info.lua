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
        local world = self.ui.world
        local selected_unit = self.ui.selected_unit
        local selected_weapon = action.data.weapon

        local target_unit = world:get_unit(action.data.tile_x, action.data.tile_y)
        if target_unit then
            local player_attack_power, player_hit_rate, enemy_attack_power, enemy_hit_rate

            player_attack_power = tostring(combat.get_attack_power(world, selected_unit, action.data.weapon, target_unit))
            if combat.can_double_attack(world, selected_unit, selected_weapon, target_unit) then
                player_attack_power = player_attack_power .. " x2"
            end
            player_hit_rate = tostring(combat.get_hit_rate(world, selected_unit, action.data.weapon, target_unit)) .. "%"

            if target_unit:can_counter_attack(world, self.ui.plan_tile_x, self.ui.plan_tile_y) then
                enemy_attack_power = tostring(combat.get_attack_power(world, target_unit, target_unit:get_active_weapon(), selected_unit))
                if combat.can_double_attack(world, target_unit, target_unit:get_active_weapon(), selected_unit) then
                    enemy_attack_power = enemy_attack_power .. " x2"
                end
                enemy_hit_rate = tostring(combat.get_hit_rate(world, target_unit, target_unit:get_active_weapon(), selected_unit)) .. "%"
            else
                enemy_attack_power = "-"
                enemy_hit_rate = "-"
            end

            self.info = string.format(
                "Attack power: %s\nHit rate: %s\n\nAttack power: %s\nHit rate: %s",
                player_attack_power, player_hit_rate, enemy_attack_power, enemy_hit_rate
            )
        end
    end
end

function combat_info:clear_combat_info()
    self.info = ""
end

function combat_info:draw()
    love.graphics.print(self.info, self.x, self.y)
end