require("unit")
require("unit_class")
require("unit_layer")

local sti = require "libs/Simple-Tiled-Implementation/sti"

world = {
    
}

function world.create()
    local self = {}
    setmetatable(self, {__index = world})

    self.map = sti("maps/sample_map.lua")

    self.command_queue = {}

    local unit_layer = unit_layer.create(self.map, 200, 200)
    unit_layer:create_unit(unit_class.sword_fighter, 0, 0)
    unit_layer:create_unit(unit_class.axe_fighter, 3, 5)
    unit_layer:create_unit(unit_class.lance_fighter, 2, 10)
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
                target_unit.health = target_unit.health - attack_power
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

function world:get_tiles_in_range(tile_x, tile_y, max, min)

end