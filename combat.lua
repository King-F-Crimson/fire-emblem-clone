combat = {}

combat.weapon_advantage = {
    sword = { sword = "neutral", lance = "lose",    axe = "win",     bow = "neutral", spell = "neutral" },
    lance = { sword = "win",     lance = "neutral", axe = "lose",    bow = "neutral", spell = "neutral" },
    axe   = { sword = "lose",    lance = "win",     axe = "neutral", bow = "neutral", spell = "neutral" },
    bow   = { sword = "neutral", lance = "neutral", axe = "neutral", bow = "neutral", spell = "neutral" },
    spell = { sword = "neutral", lance = "neutral", axe = "neutral", bow = "neutral", magic = "neutral" },
}

function combat.initiate(world, attacker, tile_x, tile_y)
    local defender = world:get_unit(tile_x, tile_y)

    if defender then
        combat.attack(world, attacker, defender)

        if not defender.death_flag and defender:can_counter_attack(world, attacker.tile_x, attacker.tile_y) then
            -- Create empty wait animation for 20 frames.
            combat.push_animation(world, {length = 20, attacker = attacker, target = defender}, "wait")

            combat.attack(world, defender, attacker)

            if defender.speed >= attacker.speed + 5 and not attacker.death_flag and not defender.death_flag then
                combat.push_animation(world, {length = 20, attacker = attacker, target = defender}, "wait")

                combat.attack(world, defender, attacker)
            end
        end

        -- Double attack if speed is 5 or more.
        if attacker.speed >= defender.speed + 5 and not defender.death_flag and not attacker.death_flag then
            combat.push_animation(world, {length = 20, attacker = attacker, target = defender}, "wait")

            combat.attack(world, attacker, defender)
        end
    end
end

function combat.attack(world, attacker, target)
    -- Check miss:
    if math.random(1, 100) <= combat.get_hit_rate(world, attacker, attacker:get_active_weapon(), target) then
        local damage = combat.get_attack_power(world, attacker, attacker:get_active_weapon(), target)
        target:damage(world, damage)

        combat.push_animation(world, {attacker = attacker, target = target, damage = damage }, "attack")
    else
        combat.push_animation(world, {attacker = attacker, target = target, miss = true, damage = damage }, "attack")
    end
end

function combat.get_attack_power(world, attacker, weapon, target)
    local attack_power
    if weapon.class == "physical" then
        attack_power = weapon.power + attacker.strength - target.defense
    elseif weapon.class == "magical" then
        attack_power = weapon.power + attacker.magic - target.resistance
    end

    if attack_power < 0 then attack_power = 0 end

    return attack_power
end

function combat.get_hit_rate(world, attacker, weapon, target)
    local hit_rate = weapon.accuracy + attacker.skill * 2 - target.speed * 2

    local weapon_advantage = combat.get_weapon_advantage(weapon, target:get_active_weapon())

    if weapon_advantage == "win" then
        hit_rate = hit_rate + 10
    elseif weapon_advantage == "lose" then
        hit_rate = hit_rate - 10
    end

    if hit_rate < 0 then hit_rate = 0 end
    if hit_rate > 100 then hit_rate = 100 end

    return hit_rate
end

function combat.can_double_attack(world, attacker, weapon, target)
    return attacker.speed >= target.speed + 5
end

function combat.get_weapon_advantage(attacking_weapon, defending_weapon)
    return combat.weapon_advantage[attacking_weapon.type][defending_weapon.type]
end

function combat.push_animation(world, data, animation_type)
    local animation

    if animation_type == "attack" then
        animation = { type = "attack", data = data }
    elseif animation_type == "wait" then
        animation = { type = "wait", data = data }
    end

    world.animation:receive_animation(animation)
end