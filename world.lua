require("unit")
require("unit_class")
require("unit_layer")
require("weapon_class")
require("queue")

local sti = require "libs/Simple-Tiled-Implementation/sti"

world = {
    
}

function world.create()
    local self = {}
    setmetatable(self, {__index = world})

    self.map = sti("maps/sample_map.lua")

    self.command_queue = {}

    local unit_layer = unit_layer.create(self.map, 200, 200)

    unit_layer:create_unit(unit_class.sword_fighter, 0, 0, { weapon = weapon_class.iron_sword })
    unit_layer:create_unit(unit_class.axe_fighter, 3, 5, { weapon = weapon_class.iron_axe })
    unit_layer:create_unit(unit_class.lance_fighter, 2, 10, { weapon = weapon_class.iron_lance })
    unit_layer:create_unit(unit_class.bow_fighter, 4, 8, { weapon = weapon_class.iron_bow })
    unit_layer:create_unit(unit_class.generic_unit, 8, 2)

    return self
end

function world:receive_command(command)
    table.insert(self.command_queue, command)
end

function world:process_command_queue()
    for k, command in pairs(self.command_queue) do
        local data = command.data
        if command.action == "move_unit" then
            self:move_unit(data.unit, data.tile_x, data.tile_y)
        end
        if command.action == "attack" then
            local attack_power = data.attacking_unit.strength

            local target_unit = self:get_unit(data.target_tile_x, data.target_tile_y)

            if target_unit then
                target_unit.data.health = target_unit.data.health - attack_power
            end
        end
    end

    self.command_queue = {}
end

function world:update()
    self:process_command_queue()

    self.map:update()
end

function world:draw()
    self.map:draw()
end

function world:get_unit(tile_x, tile_y)
    return self.map.layers.unit_layer:get_unit(tile_x, tile_y)
end

function world:move_unit(unit, tile_x, tile_y)
    self.map.layers.unit_layer:move_unit(unit, tile_x, tile_y)
end

function world:get_adjacent_tiles(tile_x, tile_y)
    return  {
                { x = tile_x, y = tile_y + 1 },
                { x = tile_x, y = tile_y - 1 },
                { x = tile_x + 1, y = tile_y },
                { x = tile_x - 1, y = tile_y }
            }
end

function world:get_tiles_in_range(tile_x, tile_y, range)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    local output = {}
    output[key(tile_x, tile_y)] = { x = tile_x, y = tile_y, distance = 0 }

    -- Start the frontier from the first tile.
    local frontier = queue.create()
    frontier:push(output[key(tile_x, tile_y)])

    -- Each for iteration increases the distance.
    for i = 1, range do
        local next_frontier = queue.create()

        -- Expand each frontier in current distance.
        while not frontier:empty() do
            local current = frontier:pop()
            for k, tile in pairs(self:get_adjacent_tiles(current.x, current.y)) do
                -- If tile is not already in output, add it and put it in frontier.
                if output[key(tile.x, tile.y)] == nil then
                    output[key(tile.x, tile.y)] = { x = tile.x, y = tile.y, distance = i }
                    next_frontier:push(output[key(tile.x, tile.y)])
                end
            end
        end

        frontier = next_frontier
    end

    return output
end