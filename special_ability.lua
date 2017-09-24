special_ability = {}

function special_ability.activate(world, caster, special, tile_x, tile_y)
    local affected_tiles = special_ability.get_affected_tiles(world, tile_x, tile_y, special)

    local target_units = {}
    for k, tile in pairs(affected_tiles) do
        local target_unit = world:get_unit(tile.x, tile.y)
        if target_unit then
            table.insert(target_units, target_unit)
        end
    end

    for k, target in pairs(target_units) do
        special:effect(world, caster, target)
    end

    if special.animation then
        world.animation:receive_animation({ type = "special", data = {
                x = tile_x, y = tile_y, special = special
            }
        })
    end
end

function special_ability.get_affected_tiles(world, origin_x, origin_y, special)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    local area = special.area

    local distance = #area * 2

    local tiles = world:get_tiles_in_distance({tile_x = origin_x, tile_y = origin_y, distance = distance})

    -- Find displacement from center.
    local x_displacement, y_displacement
    for i, row in ipairs(area) do
        for j = 1, #area do
            if string.sub(area[i], j, j) == "C" then
                x_displacement, y_displacement = j, i
            end
        end
    end

    local culled_tiles = {}

    -- Cull tiles.
    for i, row in ipairs(area) do
        for j = 1, #area do
            if string.sub(area[i], j, j) == "X" or string.sub(area[i], j, j) == "C" then
                local tile_x, tile_y = origin_x - x_displacement + i, origin_y - y_displacement + j

                culled_tiles[key(tile_x, tile_y)] = tiles[key(tile_x, tile_y)]
            end
        end
    end

    return culled_tiles
end