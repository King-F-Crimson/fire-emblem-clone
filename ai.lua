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
    local x = unit.tile_x - 1
    if self.world:get_unit(x, unit.tile_y) then
        x = unit.tile_x
    end
    if x < 0 then x = 0 end
    move_command.data = { unit = unit, tile_x = x, tile_y = unit.tile_y }

    self:determine_move_spot(unit)

    self.world:receive_command(move_command)
end

function ai:determine_move_spot(unit)
    local function early_exit(terain, unit_on_tile)
        if unit_on_tile then
            return unit_on_tile.data.team ~= unit.data.team
        else
            return false
        end
    end

    local function movement_filter(terrain, unit_on_tile)
        local cost

        local terrain_cost = {
            plain = 1,
            water = "impassable",
            sand = 2,
            wall = "impassable",
        }

        -- Defaults to impassable.
        cost = terrain_cost[terrain] or "impassable"

        return cost
    end

    local tiles = self.world:get_tiles_in_distance({distance = 500, min_distance = 1, tile_x = unit.tile_x, tile_y = unit.tile_y, early_exit = early_exit, movement_filter = movement_filter})

    local nearest_enemy

    for key, tile in pairs(tiles) do
        if tile.tile_content.unit then
            if tile.tile_content.unit.data.team ~= unit.data.team then
                nearest_enemy = tile.tile_content.unit
            end
        end
    end

    if nearest_enemy then
        print(string.format("Nearest enemy: %s at (%s, %s)", nearest_enemy.name, nearest_enemy.tile_x, nearest_enemy.tile_y))
    end
end