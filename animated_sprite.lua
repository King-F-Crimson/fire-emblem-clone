local anim8 = require("libs/anim8/anim8")

-- Wrapper class for anim8 and aseprite json export.
animated_sprite = {}

function animated_sprite.create(image, animation_data)
    local self = {}
    setmetatable(self, {__index = animated_sprite})

    self.image = image

    self:process_animation_data(animation_data)

    self.animation = anim8.newAnimation(self.grid('1-' .. tostring(#self.durations), 1), self.durations)

    if self.loop == false then
        self.animation.onLoop = "pauseAtEnd"
    end

    return self
end

function animated_sprite:process_animation_data(animation_data)
    self.frame_size = {
        w = animation_data.frames[1].frame.w,
        h = animation_data.frames[1].frame.h,
    }

    self.image_size = {
        w = animation_data.meta.size.w,
        h = animation_data.meta.size.h,
    }

    self.loop = animation_data.meta.loop

    self.durations = {}
    self.total_duration = 0
    for i, frame in ipairs(animation_data.frames) do
        table.insert(self.durations, frame.duration / 1000)
        self.total_duration = self.total_duration + frame.duration / 1000
    end

    self.grid = anim8.newGrid(self.frame_size.w, self.frame_size.h, self.image_size.w, self.image_size.h)
end

function animated_sprite:draw(x, y)
    self.animation:draw(self.image, x, y)
end

function animated_sprite:update()
    -- Updates the animation by one frame.
    self.animation:update(1/60)
end

function animated_sprite:go_to_frame(frame)
    self.animation:gotoFrame(frame)
end

function animated_sprite:resume()
    self.animation:resume()
end