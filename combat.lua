combat = {}

function combat.initiate(world, attacker, tile_x, tile_y)
    local attack_power = attacker.strength + attacker.data.weapon.power

    local target_unit = world:get_unit(tile_x, tile_y)

    if target_unit then
        target_unit.data.health = target_unit.data.health - attack_power

        -- Regenerate health_bar display since health is changed.
        target_unit:generate_health_bar()

        if target_unit.data.health <= 0 then
            local unit_layer = world.map.layers.unit_layer
            unit_layer:delete_unit(target_unit)
        end
    end
end