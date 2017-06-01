require("utility")
require("unit_class")
require("colored_sprite")
require("animated_sprite")

unit = {
    idle_color = love.graphics.newImage("assets/template_unit_idle_color.png"),
    run_color = love.graphics.newImage("assets/template_unit_run_color.png"),

    health_bar_base = love.graphics.newImage("assets/health_bar_32.png"),

    colorize_shader = love.graphics.newShader("shaders/colorize_shader.fs"),
    desaturate_shader = love.graphics.newShader("shaders/desaturate_shader.fs"),
    gradient_shader = love.graphics.newShader("shaders/gradient_shader_blocky.fs"),
}

function unit.create(class, tile_x, tile_y, data)
    local self = deepcopy(class)
    setmetatable(self, { __index = unit })

    self.tile_x = tile_x
    self.tile_y = tile_y

    if data then
        self.data = data
    else
        self.data = {}
    end

    -- If health is not already specified then set health to max_health.
    if not self.data.health then
        self.data.health = self.max_health
    end

    self:generate_animations()

    self:generate_health_bar()

    -- Create movement filter functions.
    function self.movement_filter(terrain, unit)
        return self:default_movement_filter(terrain, unit)
    end

    -- Create unlandable tile filter functions.
    function self.unlandable_filter(terrain, unit)
        return self:default_unlandable_filter(terrain, unit)
    end

    return self
end

function unit:generate_animations()
    self.sprites = {
        idle = colored_sprite.create(self.idle_base, self.idle_color, self.data.team.color),
        run = colored_sprite.create(self.run_base, self.run_color, self.data.team.color),
    }
    self.animations = {
        idle = animated_sprite.create{ image = self.sprites.idle, frame_width = unit_size, durations = 10 },
        run = animated_sprite.create{ image = self.sprites.run, frame_width = unit_size, durations = 5 },
    }
end

function unit:update_animation()
    for k, animation in pairs(self.animations) do
        animation:update(1)
    end
end

function unit:draw(animation, x, y)
    -- Gray out unit if it has moved.
    if self.data.moved then
        love.graphics.setShader(self.desaturate_shader)
    end

    if animation == "idle" then
        animation = self.animations.idle
    elseif
        animation == "run" then animation = self.animations.run
    end

    animation:draw(x, y)

    love.graphics.setShader()
end

function unit:draw_health_bar(x, y)
    love.graphics.draw(self.health_bar, x, y + unit_size)
end

function unit:generate_health_bar()
    self.health_bar = love.graphics.newCanvas()
    self.health_bar:setFilter("nearest")

    local bar_length = self.data.health / self.max_health * self.health_bar_base:getWidth()
    local bar_height = self.health_bar_base:getHeight()

    love.graphics.setCanvas(self.health_bar)
        -- Draw the health bar with gradient according to the max_health.
        self.gradient_shader:send("start_color", {0, 0.5, 1, 1})
        self.gradient_shader:send("end_color", {0, 1, 0, 1})
        love.graphics.setShader(self.gradient_shader)
            love.graphics.draw(self.health_bar_base)
        love.graphics.setShader()

        -- Draw black cover.
        love.graphics.setColor(10, 10, 10)
            love.graphics.rectangle("fill", bar_length, 0, unit_size - bar_length, bar_height)
        -- Reset color so canvas will be drawn properly.
        love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setCanvas()
end

function unit:get_movement_area(world)
    return world:get_tiles_in_distance{tile_x = self.tile_x, tile_y = self.tile_y, distance = self.movement, movement_filter = self.movement_filter, unlandable_filter = self.unlandable_filter}
end

-- Find area the unit can attack from a location.
function unit:get_attack_area(world, tile_x, tile_y)
    -- Create default filter for attack, which does not include wall tiles.
    local function unlandable_filter(terrain, unit)
        if terrain == "wall" then
            return true
        end
    end

    local attack_area = {}

    for k, weapon in pairs(self.data.weapons) do
        -- Default min_range to 1.
        local min_range = weapon.min_range or 1

        for key, tile in pairs(world:get_tiles_in_distance{tile_x = tile_x, tile_y = tile_y, distance = weapon.range, min_distance = min_range, unlandable_filter = unlandable_filter}) do
            if not attack_area[key] then
                attack_area[key] = tile
            end
        end
    end

    return attack_area
end

-- Weapons that can attack a tile.
function unit:get_valid_weapons(world, tile_x, tile_y, target_tile_x, target_tile_y)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    local valid_weapons = {}

    local function unlandable_filter(terrain, unit)
        if terrain == "wall" then
            return true
        end
    end

    for k, weapon in pairs(self.data.weapons) do
        -- Default min_range to 1.
        local min_range = weapon.min_range or 1

        local valid_tiles = world:get_tiles_in_distance{tile_x = tile_x, tile_y = tile_y, distance = weapon.range, min_distance = min_range, unlandable_filter = unlandable_filter}
        if valid_tiles[key(target_tile_x, target_tile_y)] then
            table.insert(valid_weapons, weapon)
        end
    end

    return valid_weapons
end

function unit:can_counter_attack(world, target_tile_x, target_tile_y)
    local function key(x, y) return string.format("(%i, %i)", x, y) end

    local weapon = self.data.active_weapon
    local attack_area = world:get_tiles_in_distance{tile_x = self.tile_x, tile_y = self.tile_y, distance = weapon.range, min_distance = weapon.min_range or 1}

    return attack_area[key(target_tile_x, target_tile_y)] ~= nil
end

-- Get every posible area that the unit can attack by moving then attacking.
function unit:get_danger_area(world)
    local danger_area = {}
    local movement_area = self:get_movement_area(world)

    -- For every visitable tile, get the attack area.
    for k, tile in pairs(movement_area) do
        local attack_area = self:get_attack_area(world, tile.x, tile.y)

        for k, tile in pairs(attack_area) do
            -- Add it to danger area if it's not included yet.
            if not danger_area[k] then
                danger_area[k] = tile
            end
        end
    end

    return danger_area
end

function unit:move(tile_x, tile_y)
    self.tile_x, self.tile_y = tile_x, tile_y
end

function unit:damage(world, damage)
    self.data.health = self.data.health - damage

    -- Regenerate health_bar display since health is changed.
    self:generate_health_bar()

    if self.data.health <= 0 then
        self.death_flag = true
    end
end

function unit:die(world)
    local unit_layer = world.map.layers.unit_layer
    unit_layer:delete_unit(self)
end

function unit:default_movement_filter(terrain, unit)
    local cost

    local terrain_cost = {
        plain = 1,
        water = "impassable",
        sand = 2,
        wall = "impassable",
    }

    -- Defaults to impassable.
    cost = terrain_cost[terrain] or "impassable"

    -- Check unit on tile if exist.
    if unit then
        if unit.data.team ~= self.data.team then
            cost = "impassable"
        end
    end

    return cost
end

function unit:default_unlandable_filter(terrain, unit)
    local unlandable = false

    return unlandable
end