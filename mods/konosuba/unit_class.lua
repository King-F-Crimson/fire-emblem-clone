local json = require("json")

local unit_class = {
    crimson_demon = {
        sprites = {
            idle = {
                base = love.graphics.newImage("mods/konosuba/assets/megumin_idle.png"),
                color = love.graphics.newImage("assets/blank_sprite.png"),
                animation = json.decode(load_file_as_string("mods/konosuba/assets/megumin_idle.json")),
            },
            run = {
                base = love.graphics.newImage("mods/konosuba/assets/megumin_run.png"),
                color = love.graphics.newImage("assets/blank_sprite.png"),
                animation = json.decode(load_file_as_string("mods/konosuba/assets/megumin_run.json")),
            }
        },

        name = "Megumin",
        
        max_health = 15,
        strength = 2,
        defense = 4,
        magic = 13,
        resistance = 10,
        skill = 10,
        speed = 6,
        movement = 5,

        weapon_type = "magic"
    }
}

return unit_class