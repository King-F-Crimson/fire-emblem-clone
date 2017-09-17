ai = {}

function ai.create(observer, game, world)
    local self = { observer = observer, game = game, world = world }
    setmetatable(self, {__index = ai})

    return self
end

function ai:set_team(team)
    self.team = team
end

function ai:do_step()
    local units = self.world:get_all_units()
    local move_unit_flag = false

    for k, unit in pairs(units) do
        if unit.data.team == self.team and not unit.data.moved then
            self:move_unit(unit)
            move_unit_flag = true
            break
        end
    end

    if not move_unit_flag then
        self.game:new_turn()
    end
end

function ai:move_unit(unit)
    local move_command = { action = "move_unit" }

    local x, y = self:determine_move_spot(unit)

    move_command.data = { unit = unit, tile_x = x, tile_y = y }

    self.world:receive_command(move_command)
end

function ai:determine_move_spot(unit)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    -- Early exit if the unit can attack from the position.
    local function early_exit(tile)
        if not tile.unlandable then
            local attack_area = unit:get_attack_area(self.world, tile.x, tile.y)

            for key, tile in pairs(attack_area) do
                if tile.tile_content.unit then
                    if tile.tile_content.unit.data.team ~= unit.data.team then
                        return true
                    end
                end
            end
        end
    end

    local traversed_tiles = self.world:get_tiles_in_distance({distance = 100, tile_x = unit.tile_x, tile_y = unit.tile_y, early_exit = early_exit, movement_filter = unit.movement_filter, unlandable_filter = unit.unlandable_filter})

    -- Find the nearest spot where the unit can attack an enemy.
    local nearest_attacking_spot

    for key, tile in pairs(traversed_tiles) do
        if tile.trigger_early_exit then
            nearest_attacking_spot = tile
        end
    end

    if nearest_attacking_spot then
        print(string.format("Nearest attacking spot at (%s, %s)", nearest_attacking_spot.x, nearest_attacking_spot.y))
    end

    -- Find the furthest the unit can move to reach the spot.
    local furthest_traversable_spot = nearest_attacking_spot

    while furthest_traversable_spot.distance > unit.movement do
        if furthest_traversable_spot.come_from ~= "origin" then
            furthest_traversable_spot = traversed_tiles[key(furthest_traversable_spot.come_from.x, furthest_traversable_spot.come_from.y)]
        end
    end

    return furthest_traversable_spot.x, furthest_traversable_spot.y
end