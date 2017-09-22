local json = require("json")

local special_class = {
    explosion = {
        name = "Explosion",

        power = 50,
        accuracy = 100,
        range = 20,
        min_range = 10,

        area = {
            "OXXXO",
            "XXXXX",
            "XXCXX",
            "XXXXX",
            "OXXXO",
        },

        type = "spell",
        class = "magical",

        sprite = love.graphics.newImage("mods/konosuba/assets/explosion.png"),
        sprite_scale = 1/2,
    }
}

special_class.explosion.sprite:setFilter("nearest")
special_class.explosion.animation = animated_sprite.create(special_class.explosion.sprite, json.decode(load_file_as_string("mods/konosuba/assets/explosion.json")))

return special_class