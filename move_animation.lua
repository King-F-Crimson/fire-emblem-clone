move_animation = {}

function move_animation.create(args)
    local self = {}
    setmetatable(self, {__index = move_animation})

    self.unit = args.unit

    self.path = args.path

    self.length_per_tile = 5

    self.length = self.length_per_tile * (#self.path - 1)
    self.current_frame = 1
    self.complete = false

    -- If the path length is 1 (not moving), end the animation immediately.
    if #self.path == 1 then
        self:exit()
    end

    return self
end

function move_animation:exit()
    self.complete = true
    self.unit.hidden = false
end

function move_animation:update()
    if self.current_frame == self.length then
        self:exit()
    else
        self.current_frame = self.current_frame + 1
    end
end

function move_animation:draw()
    local unit = self.unit

    -- Handles if path length is 1.
    local x, y
    if #self.path ~= 1 then
        x, y = self:determine_position()
    else
        x, y = unit.tile_x, unit.tile_y
    end

    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)

        unit:draw("run", x * unit_size, y * unit_size)
    love.graphics.pop()
end

function move_animation:determine_position()
    local current_tile_index = math.floor((self.current_frame - 1) / self.length_per_tile) + 2
    local current_tile = self.path[current_tile_index]
    local previous_tile = self.path[current_tile_index - 1]

    -- Determines how far the unit has moved between two tiles.
    local accumulator = ((self.current_frame - 1) % self.length_per_tile) / self.length_per_tile

    local x, y = current_tile.x * accumulator + previous_tile.x * (1 - accumulator), current_tile.y * accumulator + previous_tile.y * (1 - accumulator)

    return x, y
end