special_ability = {}

function special_ability.activate(world, caster, special, tile_x, tile_y)
    local affected_tiles = special_ability.get_affected_tiles(world, tile_x, tile_y, special.area)

    local target_units = {}
    for k, tile in pairs(affected_tiles) do
        local target_unit = world:get_unit(tile.x, tile.y)
        if target_unit then
            table.insert(target_units, target_unit)
        end
    end

    for k, target in pairs(target_units) do
        target:damage(world, special.power)
    end

    world.animation:receive_animation({ type = "special", data = {
            x = tile_x, y = tile_y, special = special
        }
    })
end

function special_ability.get_affected_tiles(world, tile_x, tile_y, area)
    local distance = #area

    local tiles = world:get_tiles_in_distance({tile_x = tile_x, tile_y = tile_y, distance = distance})

    return tiles
end