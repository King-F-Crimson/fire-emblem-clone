camera = {}

function camera.create(observer, ui)
    local self = { observer = observer, ui = ui }
    setmetatable(self, {__index = camera})

    self.zoom = 2
    self.min_zoom = 1
    self.max_zoom = 8
    self.mouse_scroll_for_zoom = 2

    self.translate = { x = 0, y = 0 }
    self:set_translate_center_to_cursor()

    self.manual_move_threshold = 1/10 * love.graphics.getWidth()
    self.manual_movement_base_speed = 5

    self.screen_center_x = love.graphics.getWidth() / 2 / zoom
    self.screen_center_y = love.graphics.getHeight() / 2 / zoom

    self.observer:add_listener("cursor_moved_using_keyboard", function() self:set_translate_center_to_cursor() end)

    return self
end

function camera:update()
    self:move_manual_center_with_mouse()
end

function camera:move_manual_center_with_mouse()
    local x, y = love.mouse.getPosition()
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
    local threshold = self.manual_move_threshold
    local speed = self.manual_movement_base_speed

    local translate_movement = { x = 0, y = 0 }

    if x < threshold then
        translate_movement.x = (x - threshold) / threshold * speed
    elseif x > screen_width - threshold then
        translate_movement.x = (x - (screen_width - threshold)) / threshold * speed
    end

    if y < threshold then
        translate_movement.y = (y - threshold) / threshold * speed
    elseif y > screen_height - threshold then
        translate_movement.y = (y - (screen_height - threshold)) / threshold * speed
    end

    self.translate_center.x = self.translate_center.x + translate_movement.x
    self.translate_center.y = self.translate_center.y + translate_movement.y
end

function camera:process_event(event)
    if event.type == "mouse_wheel_moved" then
        self:zoom_using_mouse_wheel(event.data.x, event.data.y)
    end
end

function camera:get_tile_from_coordinate(x, y)
    local translated_x, translated_y = (x / zoom - self.translate.x) / self.zoom, (y / zoom - self.translate.y) / self.zoom
    local tile_x, tile_y = math.floor(translated_x / tile_size), math.floor(translated_y / tile_size)

    return tile_x, tile_y
end

function camera:set_translate()
    self.translate = { x = self.screen_center_x - self.translate_center.x * self.zoom,
                       y = self.screen_center_y - self.translate_center.y * self.zoom }

    love.graphics.translate(self.translate.x, self.translate.y)
end

function camera:set_zoom()
    love.graphics.scale(self.zoom)
end

function camera:zoom_using_mouse_wheel(x, y)
    if y > self.mouse_scroll_for_zoom and self.zoom < self.max_zoom then
        self.zoom = self.zoom + 1
    elseif y < -self.mouse_scroll_for_zoom and self.zoom > self.min_zoom then
        self.zoom = self.zoom - 1
    end
end

function camera:set_translate_center_to_cursor()
    local cursor_x, cursor_y = self.ui.cursor:get_position()
    local cursor_center_x, cursor_center_y = (cursor_x + (tile_size / 2)), (cursor_y + (tile_size / 2))

    self.translate_center = { x = cursor_center_x, y = cursor_center_y }
end