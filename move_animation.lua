move_animation = {}

function move_animation.create(args)
    local self = {}
    setmetatable(self, {__index = move_animation})

    self.unit = args.unit

    self.unit.hidden = true

    self.path = args.path

    self.length = 30
    self.current_frame = 1
    self.complete = false

    print("create run")

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

    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)

        unit:draw("run", unit.tile_x * unit_size, unit.tile_y * unit_size)
    love.graphics.pop()
end