wait_animation = {}

function wait_animation.create(data)
    local self = {}
    setmetatable(self, {__index = wait_animation})

    self.length = data.length
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

end