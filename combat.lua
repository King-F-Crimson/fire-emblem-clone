combat = {}

combat.weapon_advantage = {
    sword = { sword = "neutral", lance = "lose",    axe = "win",     bow = "neutral" },
    lance = { sword = "win",     lance = "neutral", axe = "lose",    bow = "neutral" },
    axe   = { sword = "lose",    lance = "win",     axe = "neutral", bow = "neutral" },
    bow   = { sword = "neutral", lance = "neutral", axe = "neutral", bow = "neutral" },
}

function combat.initiate(world, attacker, tile_x, tile_y)
    local defender = world:get_unit(tile_x, tile_y)

    if defender then
        combat.attack(world, attacker, defender)

        if defender.data.health > 0 and defender:can_counter_attack(world, attacker.tile_x, attacker.tile_y) then
            -- Create empty wait animation for 20 frames.
            combat.push_animation(world, {length = 20}, "wait")

            combat.attack(world, defender, attacker)

            if defender.speed >= attacker.speed + 5 then
                combat.push_animation(world, {length = 20}, "wait")

                combat.attack(world, defender, attacker)
            end
        end

        -- Double attack if speed is 5 or more.
        if attacker.speed >= defender.speed + 5 then
            combat.push_animation(world, {length = 20}, "wait")

            combat.attack(world, attacker, defender)
        end
    end
end

function combat.attack(world, attacker, target)
    -- Check miss:
    if math.random(1, 100) <= combat.get_hit_rate(world, attacker, attacker.data.active_weapon, target) then
        target:damage(world, combat.get_attack_power(world, attacker, attacker.data.active_weapon, target))

        combat.push_animation(world, {attacker = attacker, target = target}, "attack")
    else
        combat.push_animation(world, {attacker = attacker, target = target, miss = true}, "attack")
    end
end

function combat.get_attack_power(world, attacker, weapon, target)
    local attack_power = weapon.power + attacker.strength - target.defense
    if attack_power < 0 then attack_power = 0 end

    return attack_power
end

function combat.get_hit_rate(world, attacker, weapon, target)
    local hit_rate = attacker.data.active_weapon.accuracy + attacker.skill * 2 - target.speed * 2

    local weapon_advantage = combat.get_weapon_advantage(weapon, target.data.active_weapon)

    if weapon_advantage == "win" then
        hit_rate = hit_rate + 10
    elseif weapon_advantage == "lose" then
        hit_rate = hit_rate - 10
    end

    return hit_rate
end

function combat.get_weapon_advantage(attacking_weapon, defending_weapon)
    return combat.weapon_advantage[attacking_weapon.type][defending_weapon.type]
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