require("utility")
require("unit_class")

unit = {
    base_sprite = love.graphics.newImage("assets/template_unit.png"),
    colored_part = love.graphics.newImage("assets/template_unit_color.png"),

    health_bar_base = love.graphics.newImage("assets/health_bar.png"),

    colorize_shader = love.graphics.newShader("shaders/colorize_shader.fs"),
    desaturate_shader = love.graphics.newShader("shaders/desaturate_shader.fs"),
    gradient_shader = love.graphics.newShader("shaders/gradient_shader.fs")
}

unit.base_sprite:setFilter("nearest")

function unit.create(class, tile_x, tile_y, data)
    local self = deepcopy(class)
    setmetatable(self, { __index = unit })

    self.tile_x = tile_x
    self.tile_y = tile_y

    -- Copy extra data (weapon, starting HP, etc) if exist.
    if data then
        self.data = deepcopy(data)
    else
        self.data = {}
    end

    -- If health is not already specified then set health to max_health.
    if not self.data.health then
        self.data.health = self.max_health
    end

    self:generate_sprite()
    self:generate_health_bar()

    -- Create movement filter functions.
    function self.movement_filter(terrain, unit)
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

    -- Create unlandable tile filter functions.
    function self.unlandable_filter(terrain, unit)
        local unlandable = false

        -- Tile will be unlandable if there's an allied unit on it. 
        if unit then
            if unit.data.team == self.data.team then
                unlandable = true
            end
        end

        return unlandable
    end

    return self
end

function unit:draw()
    -- Unit will be hidden during animation.
    if not self.hidden then
        -- Gray out unit if it has moved.
        if self.data.moved then
            love.graphics.setShader(self.desaturate_shader)
        end

        love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)

        love.graphics.setShader()

        self:draw_health_bar()
    end
end

function unit:draw_health_bar()
    local x, y = self.tile_x * tile_size, (self.tile_y + 7/8) * tile_size
    love.graphics.draw(self.health_bar, x, y)
end

-- Get team colorized sprite.
function unit:generate_sprite()
    -- Draw to canvas to apply colorize shader.
    self.sprite = love.graphics.newCanvas()
    self.sprite:setFilter("nearest")

    love.graphics.setCanvas(self.sprite)
        -- Draw the normal sprite.
        love.graphics.draw(self.base_sprite)

        -- Draw team-colorized part using shader.
        self.colorize_shader:send("tint_color", self:get_team_color())
        love.graphics.setShader(self.colorize_shader)
        love.graphics.draw(self.colored_part, 0, 0)
        love.graphics.setShader()

    love.graphics.setCanvas()
end

function unit:generate_health_bar()
    self.health_bar = love.graphics.newCanvas()
    self.health_bar:setFilter("nearest")

    local bar_length = self.data.health / self.max_health * tile_size

    love.graphics.setCanvas(self.health_bar)
        -- Draw the health bar with gradient according to the max_health.
        self.gradient_shader:send("start_color", {0, 0.5, 1, 1})
        self.gradient_shader:send("end_color", {0, 1, 0, 1})
        love.graphics.setShader(self.gradient_shader)
            love.graphics.draw(self.health_bar_base)
        love.graphics.setShader()

        -- Draw black cover.
        love.graphics.setColor(0, 0, 0)
            love.graphics.rectangle("fill", bar_length, 0, tile_size - bar_length, tile_size / 16)
        -- Reset color so canvas will be drawn properly.
        love.graphics.setColor(255, 255, 255, 255)

    love.graphics.setCanvas()
end

function unit:get_team_color()
    local team_color = {
        player = {0.25, 0.25, 1},
        enemy = {1, 0.25, 0.25},
        ally = {0.25, 1, 0.25},
    }

    return team_color[self.data.team]
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

    -- Default min_range to 1.
    local min_range = self.data.weapon.min_range or 1

    return world:get_tiles_in_distance{tile_x = tile_x, tile_y = tile_y, distance = self.data.weapon.range, min_distance = min_range, unlandable_filter = unlandable_filter}
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