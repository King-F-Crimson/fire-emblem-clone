local json = require("json")

special_class = {
    heal = {
        name = "Heal",

        recovery = 10,

        range = 1,
        min_range = 1,

        area = {
            "C",
        },

        type = "staff",
        class = "magical",

        effect = function(self, world, caster, target)
            target:heal(world, self.recovery + math.floor(caster.magic / 3))
        end
    }
}