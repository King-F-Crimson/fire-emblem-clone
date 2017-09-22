local json = require("json")

unit_class = {
    generic_unit = {
        sprites = {
            base_sprite = love.graphics.newImage("assets/template_unit.png"),
        },

        name = "Generic Unit",
        
        max_health = 10,
        strength = 4,
        defense = 4,
        skill = 4,
        speed = 4,
        movement = 5,
    },

    sword_fighter = {
        sprites = {
            idle = {
                base = love.graphics.newImage("assets/sword_fighter_idle.png"),
                color = love.graphics.newImage("assets/template_unit_idle_color.png"),
            },
            run = {
                base = love.graphics.newImage("assets/sword_fighter_run.png"),
                color = love.graphics.newImage("assets/template_unit_run_color.png"),
            },
        },

        name = "Sword Fighter",
        
        max_health = 16,
        strength = 5,
        defense = 6,
        skill = 10,
        speed = 10,
        movement = 5,

        weapon_type = "sword"
    },

    lance_fighter = {
        sprites = {
            idle = {
                base = love.graphics.newImage("assets/lance_fighter_idle.png"),
                color = love.graphics.newImage("assets/template_unit_idle_color.png"),
            },
            run = {
                base = love.graphics.newImage("assets/lance_fighter_run.png"),
                color = love.graphics.newImage("assets/template_unit_run_color.png"),
            },
        },

        name = "Lance Fighter",
        
        max_health = 18,
        strength = 7,
        defense = 9,
        skill = 8,
        speed = 7,
        movement = 5,

        weapon_type = "lance"
    },

    axe_fighter = {
        sprites = {
            idle = {
                base = love.graphics.newImage("assets/axe_fighter_idle.png"),
                color = love.graphics.newImage("assets/template_unit_idle_color.png"),
            },
            run = {
                base = love.graphics.newImage("assets/axe_fighter_run.png"),
                color = love.graphics.newImage("assets/template_unit_run_color.png"),
            },
        },

        name = "Axe Fighter",
        
        max_health = 20,
        strength = 10,
        defense = 5,
        skill = 5,
        speed = 5,
        movement = 5,

        weapon_type = "axe"
    },

    bow_fighter = {
        sprites = {
            idle = {
                base = love.graphics.newImage("assets/bow_fighter_idle.png"),
                color = love.graphics.newImage("assets/template_unit_idle_color.png"),
            },
            run = {
                base = love.graphics.newImage("assets/bow_fighter_run.png"),
                color = love.graphics.newImage("assets/template_unit_run_color.png"),
            },
        },

        name = "Bow Fighter",
        
        max_health = 15,
        strength = 8,
        defense = 5,
        skill = 9,
        speed = 5,
        movement = 5,

        weapon_type = "bow"
    }
}