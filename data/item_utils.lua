local start_m = love.timer.getTime()

local item_utils = {}

-- items / item tooltip box data
item_utils.STAT_CATEGORIES = {
    -- be careful naming new categories because they are also the names visible on item tooltips
    -- all of these stats will be given a base value per character

    -- each category in the items table will have a value that looks like this {"modifier", number}
    -- numbers may be negative or floating point values
    -- modifiers
    -- - add: a flat modifier to the stat. this is calculated first
    -- - percent: a multiplicative modifier to the stat. this is calculated second
    -- - multiply: a multiplicative modifier to the stat. this is calculated last
    -- - - multiply is basically identical to percent, where x2 == +200%.
    -- - - the only thing is that multply modifiers are applied last

    -- this moves the attack damage range up or down depending on its value.
    -- first this will be calculated, then minimum and maximum respectively.
    attack_damage = "attack_damage",

    minimum_attack_damage = "minimum_attack_damage",

    maximum_attack_damage = "maximum_attack_damage",

    max_health = "max_health",

    health_regeneration = "health_regeneration",

    movement_speed = "movement_speed",

    -- damage reduction
    armor = "armor",

    -- amount of times bullets go through enemies.
    pierce = "pierce",

    -- amount of times bullets bounce off of enemies.
    -- if pierce is greater than zero, then start bouncing after all pierces are used up.
    bounce = "bounce",

    -- attacks per second
    attack_speed = "attack_speed",

    -- healing amplification multiplier
    healing_power = "healing_power",

    -- if 100%, critical hit every hit
    critical_hit_chance = "critical_hit_chance",

    -- critical hit damage amplification multiplier
    critical_hit_power = "critical_hit_damage_amp",

    -- this value is added to the friend's base damage
    friend_damage = "friend_damage",

    -- if 100%, heal for every point of damage dealt to enemies
    lifesteal = "lifesteal",


    -- friends
    lil_gabbron = "lil_gabbron",
    wizard_sponge = "wizard_sponge",
    gangster_sponge = "gangster_sponge",
    ant = "ant",
    bone_buddy = "bone_buddy",
    screeming_scamper = "screeming_scamper",
}

item_utils.STAT_CATEGORIES = {
    "attack_damage",
    "minimum_attack_damage",
    "maximum_attack_damage",
    "max_health",
    "health_regeneration",
    "movement_speed",
    "pierce",
    "bounce",
    "attack_speed",
    "healing_power",
    "critical_hit_chance",
    "critical_hit_power",
    "friend_damage",
    "lifesteal",
    "lil_gabbron",
    "wizard_sponge",
    "gangster_sponge",
    "ant",
    "bone_buddy",
    "screeming_scamper"
}

item_utils.DESC_CATEGORIES = {
    name = "name",
    lore = "lore",
    description = "description",
    bullet = "bullet",
    note = "note",
}

item_utils.RARITIES = {
    {"common", 22},
    {"rare", 19},
    {"epic", 10},
    {"legendary", 28},
    {"ultimate", 30}
}

item_utils.SLOT_CATEGORIES = {
    big_slot = "big_slot",
    slot = "slot",
    area = "area",
}

item_utils.SLOT_VANITY_NAMES = {
    big_slot = {"Socketed:", 6},
    slot = {"Slotted:", 11},
    area = {"Bagged:", 19},
}


local effect_override = {
    text_color = 22,
    text_shader = "shimmer",
    text_coordinate_transformation = {"circle", 2, 20},
    text_font = 1,
    box_color = 1,
    box_shader = "scrolling_rainbow",
    box_coordinate_transformation = {"circle", 2, 20},
    box_outlines = 1,
}

local result_m = love.timer.getTime() - start_m
print(string.format("Item Utils loaded in %.3f milliseconds!", result_m * 1000))
return item_utils