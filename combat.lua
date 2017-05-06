combat = {}

function combat.initiate(world, attacker, tile_x, tile_y)
    local defender = world:get_unit(tile_x, tile_y)

    if defender then
        combat.attack(world, attacker, defender)

        if defender.data.health > 0 and defender:can_counter_attack(world, attacker.tile_x, attacker.tile_y) then
            -- Create empty wait animation for 20 frames.
            combat.push_animation(world, {length = 20}, "wait")

            combat.attack(world, defender, attacker)
        end
    end
end

function combat.attack(world, attacker, target)
    -- Check miss:
    if math.random(1, 100) <= combat.get_hit_rate(world, attacker, target) then
        target:damage(world, combat.get_attack_power(world, attacker, target))

        combat.push_animation(world, {attacker = attacker, target = target}, "attack")
    else
        combat.push_animation(world, {attacker = attacker, target = target, miss = true}, "attack")
    end
end

function combat.get_attack_power(world, attacker, target)
    local attack_power = attacker.data.active_weapon.power + attacker.strength - target.defense
    if attack_power < 0 then attack_power = 0 end

    return attack_power
end

function combat.get_hit_rate(world, attacker, target)
    local hit_rate = attacker.data.active_weapon.accuracy + attacker.skill * 2 - target.speed * 2

    return hit_rate
end

function combat.push_animation(world, data, animation_type)
    local animation

    if animation_type == "attack" then
        animation = { type = "attack", data = { attacker = data.attacker, tile_x = data.target.tile_x, tile_y = data.target.tile_y, miss = data.miss } }
    elseif animation_type == "wait" then
        animation = { type = "wait", data = data }
    end

    world.animation:receive_animation(animation)
end