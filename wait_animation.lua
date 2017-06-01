wait_animation = {}

function wait_animation.create(args)
    local self = {}
    setmetatable(self, {__index = wait_animation})

    self.attacker, self.target = args.attacker, args.target

    self.length = args.length
    self.current_frame = 1

    return self
end

function wait_animation:update()
    if self.current_frame == self.length then
        self.complete = true
    else
        self.current_frame = self.current_frame + 1
    end
end

function wait_animation:draw()
    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)
        self.attacker:draw("run", self.attacker.tile_x * unit_size, self.attacker.tile_x * unit_size)
        self.target:draw("run", self.target.tile_x * unit_size, self.target.tile_y * unit_size)
    love.graphics.pop()
end