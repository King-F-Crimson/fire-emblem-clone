move_animation = {}

function move_animation.create(args)
    local self = {}
    setmetatable(self, {__index = move_animation})

    self.unit = args.unit

    self.unit.hidden = true

    self.path = args.path

    self.length_per_tile = 10

    self.length = self.length_per_tile * (#self.path - 1)
    self.current_frame = 1
    self.complete = false

    return self
end

function move_animation:update()
    if self.current_frame == self.length then
        self.complete = true

        self.unit.hidden = false
    else
        self.current_frame = self.current_frame + 1
    end
end

function move_animation:draw()
    local unit = self.unit
    local x, y = self:determine_position()

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