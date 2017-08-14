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
    move_command.data = { unit = unit, tile_x = x, tile_y = unit.tile_y}

    self.world:receive_command(move_command)
end
