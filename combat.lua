combat = {}

function combat.initiate(world, attacker, tile_x, tile_y)
    local defender = world:get_unit(tile_x, tile_y)

    if defender then
        combat.attack(world, attacker, defender)

        if defender.data.health > 0 then
            combat.attack(world, defender, attacker)
        end
    end
end

function combat.attack(world, attacker, target)
    local attack_power = attacker.strength + attacker.data.active_weapon.power
    target:damage(world, attack_power)
end