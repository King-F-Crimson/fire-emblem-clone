combat = {}

function combat.initiate(world, attacker, tile_x, tile_y)
    local defender = world:get_unit(tile_x, tile_y)

    if defender then
        combat.attack(world, attacker, defender)

        if defender.data.health > 0 and defender:can_counter_attack(world, attacker.tile_x, attacker.tile_y) then
            combat.attack(world, defender, attacker)
        end
    end
end

function combat.attack(world, attacker, target)
    local weapon = attacker.data.active_weapon

    local attack_power = weapon.power + attacker.strength - target.defense
    if attack_power < 0 then attack_power = 0 end
    
    local accuracy = weapon.accuracy + attacker.skill * 2 - target.speed * 2

    -- Check miss:
    if math.random(1, 100) <= accuracy then
        target:damage(world, attack_power)
    end
end