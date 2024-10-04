-- access player stats here
local start_m = love.timer.getTime()
love.graphics.setDefaultFilter("nearest", "nearest")

function get_image(path)
	local info = love.filesystem.getInfo(path)
	if info then
		return love.graphics.newImage(path)
	end
	print("Couldn't grab image from " .. path)
end

local shaders = require('data/shaders')

local STAT_CATEGORIES = {
    -- be careful naming new categories because they are also the names visible on item tooltips
    -- all of these stats will be given a base value per character

    -- each category in the items table will have a value that looks like this
    -- "stat",
    -- {
    -- 		"statistic",
    -- 		"modifier",
    -- 		value
    -- }
    -- numbers may be negative or floating point values
    -- modifiers
    -- - add: a flat modifier to the stat. this is calculated first
    -- - percent: a multiplicative modifier to the stat. this is calculated second
    -- - multiply: a multiplicative modifier to the stat. this is calculated last
    -- - - multiply is basically identical to percent, where x2 == +200%.
    -- - - the only thing is that multply modifiers are applied last

    -- this moves the attack damage range up or down depending on its value.
    -- first this will be calculated, then minimum and maximum respectively.
    "attack_damage",

    "minimum_attack_damage",

    "maximum_attack_damage",

    "max_health",

    "health_regeneration",

    -- pixels moved per second
    "movement_speed",

    -- damage reduction
    "armor",

    -- amount of times bullets go through enemies.
    "pierce", 

    -- amount of times bullets bounce off of enemies.
    -- if pierce is greater than zero, then start bouncing after all pierces are used up.
    "bounce",

    -- attacks per second
    "attack_speed",

    -- healing amplification multiplier (100 = 100%)
    "healing_power",

    -- critical hit chance multiplier (100 = 100%)
    "critical_hit_chance",

    -- critical hit damage amplification multiplier (100 = 100%)
    "critical_hit_power",

    -- friends (by default) do your base damage times this multiplier (100 = 100%)
    "friend_damage",

    -- if 100%, heal for every point of damage dealt to enemies (100 = 100%)
    -- if over 100, gain a chance to heal double for a single instance of damage.
    -- for example, if lifesteal = 120, 100% to heal, 20% to heal double.
    "lifesteal",

    -- friends down here!
    "lil_gabbron",
    "wizard_sponge",
    "gangster_sponge",
    "ant",
    "bone_buddy",
    "screeming_scamper",
    "duck",
}

items = {}

items.blast_gem = {
	{
		"data",
		{
			id = 1,
			rarity = 2,
			image = get_image("sprites/items/blast_gem.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Blast Gem",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Very sensitive, handle with care.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Your attacks explode on hit, dealing ",
					{color = 22},
					"25% ",
					{color = 9},
					"of your total attack damage.\n§",
					{color = 9},
					"- The size of the explosion increases based on your total attack damage."
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					50
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Enemies explode on death, dealing ",
					{color = 22},
					"10% ",
					{color = 9},
					"of your total attack damage.\n§",
					{color = 9},
					"- The size of the explosion increases based on your total attack damage."
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					25
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_damage",
					"add",
					5
				}
			}
		}
	}
}

items.mangic_ingot = {
	{
		"data",
		{
			id = 2,
			rarity = 3,
			image = get_image("sprites/items/mangic_ingot.png"),
			box_line_effects = {
				color = 22,
			},
			box_back_effects = {
				color = 20,
			}
		}
	},
	{
		"text",
		{
			{
				color = 19,
			},
			"Mangic Ingot"
		}
	},
	{
		"text",
		{
			{
				color = 22,
				font = 2,
			},
			"Real mangic, ultraconcentrated into a purified ingot!\n§",
			{
				color = 22,
				font = 2,
			},
			"It shimmers a blue hue, emitting sparks when touched.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 9,
					},
					"- Instead of bullets, fire a continuous laserbeam.\n§",
					{
						color = 9,
					},
					"- On hit, shock enemies for an extra ",
					{
						color = 22,
					},
					"10 ",
					{
						color = 9,
					},
					"damage.\n§",
					{
						color = 9,
					},
					"- When an enemy is shocked, a ",
					{
						color = 22,
					},
					"10% ",
					{
						color = 9,
					},
					"chance for a lightning bolt to arc to another enemy.",
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{
						color = 9,
					},
					"- If you don't already, acquire a ",
					{
						color = 22,
					},
					"100 ",
					{
						color = 9,
					},
					"point shield at the start of every zone.",
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					20
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					-20
				}
			},
			{
				"stat",
				{
					"armor",
					"add",
					5
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{
						color = 9,
					},
					"- On hit, gain a ",
					{
						color = 22,
					},
					"0.1% ",
					{
						color = 9,
					},
					"chance to kill non-boss enemies in one shot!",
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					2
				}
			}
		}
	}
}

items.smorc_skull = {
	{
		"data",
		{
			id = 3,
			rarity = 2,
			designation = "smorc",
			image = get_image("sprites/items/smorc_skull.png"),
		}
	},
	{
		"text", 
		{
			{
				color = 22,
			},
			"Smorc Skull"
		}
	},
	{
		"text",
		{
			{
				color = 10,
				font = 2,
			},
			"Ripped straight out of the head of a smorc."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 9,
					},
					"- On kill, increase your attack speed by ",
					{
						color = 22,
					},
					"50% ",
					{
						color = 9,
					},
					"up to ",
					{
						color = 22,
					},
					"3 ",
					{
						color = 9,
					},
					"times. ",
					{
						color = 10,
					},
					"[Dur. 00:05]"
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					25
				}
			},
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Let the hate flow through you."
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"stat",
				{
					"attack_damage",
					"add",
					12
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_damage",
					"add",
					5
				}
			}
		}
	}

}

items.ring_of_barley = {
	{
		"data",
		{
			id = 4,
			rarity = 1,
			designation = "bread",
			image = get_image("sprites/items/ring_of_barley.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Wheat Ring",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Get ready to carbo-load.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- When an enemy is killed, ",
					{color = 22},
					"10% ",
					{color = 9},
					"chance to spawn a loaf of bread.\n§",
					{color = 9},
					"- If a loaf of bread touches another loaf of bread, they will fuse.\n§",
					{color = 9},
					"- Eating a loaf of bread increases your attack speed."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"percent",
					75
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Eating a loaf of bread increases your health regeneration."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"percent",
					40
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9},
					"Bread heals you for ",
					{color = 22},
					"20% ",
					{color = 9},
					"more.",
				}
			}
		}
	}
}

--§

items.weezt_bulb = {
	{
		"data",
		{
			id = 5,
			rarity = 1,
			image = get_image("sprites/items/weezt_bulb.png"),
		}
	},
	{
		"text",
		{
			{
				color = 22,
			},
			"Weezt Bulb",
		}
	},
	{
		"text",
		{
			{
				color = 22,
				font = 2,
			},
			"Something is wriggling inside it.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 28,
						font = 2,
					},
					"It's alive!",
				}
			},
			{
				"text",
				{
					{color = 9},
					"- The bulb has opened, summoning a Weezt Sprout to eat your foes.\n§",
					{color = 9},
					"- The plant moves faster when exposed to sunlight.",
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					20
				}
			},
			{
				"stat",
				{
					"weezt_sprout",
					"add",
					1
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{
						color = 9,
					},
					"The bulb wriggles around violently, altering your movement.\n§When moving fast enough, pound enemies out of the way, dealing extra damage."
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"movement_speed",
					"percent",
					5
				}
			}
		}
	}
}

items.lil_gabbron = {
	{
		"data",
		{
			id = 6,
			rarity = 2,
			designation = "gabbron",
			image = get_image("sprites/items/lil_gabbron.png"),
		}
	},
	{
		"text",
		{
			{color = 9},
			"Lil Gabbron",
		}
	},
	{
		"text",
		{
			{color = 9, font = 2},
			"Primed and ready for ",
			{color = 28, font = 2},
			"murder!",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 28, font = 2},
					"It's murdering time!"
				}
			},
			{
				"text",
				{
					{color = 9},
					"- You become an accomplice to lil gabbron, who follows you and brutally consumes prey.\n§",
					{color = 9},
					"- Lil gabbron latches onto foes, stunning them and making them weaker."
				}
			},
			{
				"stat",
				{
					"lil_gabbron",
					"add",
					1
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Lil gabbron imprints on you, matching your behavior.\n§",
					{color = 9},
					"- Lil gabbron will shoot when you do, following right behind you."
				}
			},
			{
				"stat",
				{
					"lil_gabbron",
					"add",
					1
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9},
					"- Lil gabbron becomes your accomplice, accompanying you and bumping into your enemies.\n§",
					{color = 9},
					"- Bump damage increases with lil gabbron's velocity.",
				}
			},
			{
				"stat",
				{
					"lil_gabbron",
					"add",
					1
				}
			}
		}
	}
}

items.jugg_milk_carton = {
	{
		"data",
		{
			id = 7,
			rarity = 2,
			image = get_image("sprites/items/jugg_milk_carton.png"),
			box_back_effects = {
				color = 21
			}
		}
	},
	{
		"text",
		{
			{color = 21},
			"Jugg Milk",
		}
	},
	{
		"text",
		{
			{color = 21, font = 2},
			"The healthiest jugg milk, grown and raised on the oceanside.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- The milk fortifies your body, granting you ",
					{color = 22},
					"3 ",
					{color = 9},
					"armor per zone completed.",
				}
			},
			{
				"stat",
				{
					"armor",
					"add",
					10
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"stat",
				{
					"armor",
					"add",
					10
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"armor",
					"add",
					1
				}
			}
		}
	}
}


items.pink_plasmid = {
	{
		"data",
		{
			id = 8,
			rarity = 4,
			designation = "plasmid",
			image = get_image("sprites/items/pink_plasmid.png"),
		}
	},
	{
		"text",
		{
			{color = 30},
			"Pink"
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"It's fuzzy in some places, smooth others.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Enemies stick to you when you run into them.\n§",
					{color = 9},
					"- Gain 1 armor for every enemy stuck to you.\n§",
					{color = 9},
					"- Each enemy only sticks around to tank 100 damage.",
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"add",
					35
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"movement_speed",
					"add",
					5
				}
			}
		}
	}
}

items.blue_plasmid = {
	{
		"data",
		{
			id = 9,
			rarity = 2,
			designation = "plasmid",
			image = get_image("sprites/items/blue_plasmid.png"),
		}
	},
	{
		"text",
		{
			{color = 19},
			"Blue"
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"It's squishy, yet solid. Like gelatin."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Enemies bounce off of the top and bottom of the screen, taking damage.§",
					{color = 9},
					"- Enemies which are being bounced bounce into each other, dealing damage.§",
					{color = 9},
					"- Your attacks bounce enemies."
				}
			},
			{
				"stat",
				{
					"bounce",
					"add",
					1
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Your bullets bounce off the sides of the screen.",
				}
			},
			{
				"stat",
				{
					"bounce",
					"add",
					1
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"bounce",
					"add",
					1
				}
			}
		}
	}
}

items.empty_jar = {
	{
		"data",
		{
			id = 10,
			rarity = 1,
			image = get_image("sprites/items/empty_jar.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Empty Jar",
		}
	},
	{
		"text",
		{
			{color = 25, font = 2},
			"It's sad because it's empty.",
		}
	},
}

items.jar_of_eyeballs = {
	{
		"data",
		{
			id = 11,
			rarity = 1,
			image = get_image("sprites/items/jar_of_eyeballs.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Jar of Eyeballs"
		}
	},
	{
		"text",
		{
			{color = 26, font = 2},
			"I think they've expired..."
		}
	},
}

items.weird_mushroom = {
	{
		"data",
		{
			id = 12,
			rarity = 4,
			image = get_image("sprites/items/weird_mushroom.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Weird Mushroom"
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Eat this to change up your brain!"
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Every item pulled will be of a random rarity."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"percent",
					77
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					77
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Enemy spawns are random.",
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"percent",
					33
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					33
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_speed",
					"percent",
					3
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					3
				}
			}
		}
	}
}

items.wyrm = {
	{
		"data",
		{
			id = 13,
			rarity = 2,
			designation = "rud",
			image = get_image("sprites/items/wyrm.png"),
			box_back_effects = {
				color = 31
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Rud Larva",
		}
	},
	{
		"text",
		{
			{color = 24, font = 2},
			"Its hiss is intimidating, but it can hardly move.",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- On hit, poison enemies.\n§",
					{color = 9},
					"- Sometimes, your shots can burst, coating nearby enemies in venom.\n§",
					{color = 9},
					"- Poison ticks once every second for ",
					{color = 22},
					"10 ",
					{color = 9},
					"damage.\n§",
					{color = 9},
					"- Venom makes poison more painful, doubling its damage.",
				}
			},
			{
				"stat",
				{
					"pierce",
					"add",
					2
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- On hit, poison enemies.\n§",
					{color = 9},
					"- Poison ticks once every second for ",
					{color = 22},
					"10 ",
					{color = 9},
					"damage.",
				}
			},
			{
				"stat",
				{
					"pierce",
					"add",
					1
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"pierce",
					"add",
					1
				}
			}
		}
	}
}

items.subpocket = {
	{
		"data",
		{
			id = 14,
			rarity = 4,
			image = get_image("sprites/items/subpocket.png"),
			box_line_effects = {
				color = 19,
				shader = shaders.shimmer,
			},
			box_back_effects = {
				color = 17,
			}
		}
	},
	{
		"text",
		{
			{color = 13},
			"Subpocket"
		}
	},
	{
		"text",
		{
			{color = 9, font = 2},
			"Space within your space!"
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Gain ",
					{color = 22},
					"2 ",
					{color = 9},
					"more sockets."
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Gain ",
					{color = 22},
					"4 ",
					{color = 9},
					"more slots."
				}
			},
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9, font = 2},
					"Your mind deepens."
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					50
				}
			},
			{
				"stat",
				{
					"minimum_attack_damage",
					"add",
					-50
				}
			},
		}
	}
}

items.personal_wormhole = {
	{
		"data",
		{
			id = 15,
			rarity = 3,
			image = get_image("sprites/items/personal_wormhole.png"),
			box_line_effects = {
				color = 2,
				shader = shaders.shimmer
			},
			box_back_effects = {
				color = 16
			}
		}
	},
	{
		"text",
		{
			{color = 29},
			"Pocket Wormhole",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"It's a bit heavy!",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Gain a ",
					{color = 22},
					"0.1% ",
					{color = 9},
					"chance to spawn an item every time you damage an enemy.",
				}
			},
			{
				"stat",
				{
					"pierce",
					"add",
					2
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"percent",
					20
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Spawn a random item in your bag at the start of every zone.",
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"add",
					10
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_speed",
					"add",
					2.5
				}
			},
		}
	},
}

items.wood_block = {
	{
		"data",
		{
			id = 16,
			rarity = 1,
			designation = "fundamental",
			image = get_image("sprites/items/wood_block.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Wood Block",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Sturdy yet flexible.",
		}
	},
	{
		"big_slot",
		{
			{
				"stat",
				{
					"max_health",
					"add",
					300
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"stat",
				{
					"max_health",
					"add",
					150
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"max_health",
					"add",
					25
				}
			}
		}
	},
}

items.quacker = {
	{
		"data",
		{
			id = 17,
			rarity = 1,
			designation = "bread",
			image = get_image("sprites/items/quacker.png"),
			box_back_effects = {
				color_override = {150, 140, 100, 240}
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Quacker",
		}
	},
	{
		"text",
		{
			{color = 10, font = 2},
			"This fella is ravenous!",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Loaves of bread attract ducks.\n§",
					{color = 9},
					"- Ducks will peck at creatures which are too close to loaves of bread.\n§",
					{color = 9},
					"- Ducks who eat toast will ignite, making them faster.\n§",
					{color = 9},
					"- All ducks are friends!"
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- When you eat a loaf of bread, emit a duck shockwave which does 20 damage to enemies.\n§",
					{color = 9},
					"- The shockwave does more damage if the loaf of bread is larger.",
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9},
					"- A duck follows you around, eating bread you find.\n§",
					{color = 9},
					"- Any bread eaten by the duck counts as you eating it.",
				}
			},
			{
				"stat",
				{
					"duck",
					"add",
					1
				}
			}
		}
	}
}

items.toaster = {
	{
		"data",
		{
			id = 18,
			rarity = 1,
			designation = "bread",
			image = get_image("sprites/items/toaster.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Toaster"
		}
	},
	{
		"text",
		{
			{color = 10, font = 2},
			"Not recommended for use around water."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Create an inferno aura around you, burning enemies and loaves of bread.\n§",
					{color = 9},
					"- Loaves of bread become toast, increasing their healing power by ",
					{color = 22},
					"50%",
					{color = 9},
					"."
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"movement_speed",
					"add",
					2
				}
			}
		}
	},
}

items.steel_block = {
	{
		"data",
		{
			id = 19,
			rarity = 1,
			designation = "fundamental",
			image = get_image("sprites/items/steel_block.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Steel Block",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Durable yet malleable.",
		}
	},
	{
		"big_slot",
		{
			{
				"stat",
				{
					"armor",
					"add",
					50
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"stat",
				{
					"armor",
					"add",
					25
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"armor",
					"add",
					5
				}
			}
		}
	},
}

items.sponge_with_wizard_hat = {
	{
		"data",
		{
			id = 20,
			rarity = 2,
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_wizard_hat.png"),
			box_back_effects = {
				color = 23
			}
		}
	},
	{
		"text",
		{
			{color = 19},
			"Sponge With Wizard Hat"
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Doing spells, potions; turning frogs into other things."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A sponge follows you around!\n§",
					{color = 9},
					"- The sponge lights enemies on fire.\n§",
					{color = 9},
					"- The sponge creates electrical discharges, exploding enemies if they are on fire.",
				}
			},
			{
				"stat",
				{
					"wizard_sponge",
					"add",
					1
				}
			}
		},
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A sponge follows you around!\n§",
					{color = 9},
					"- The sponge lights enemies on fire.",
				}
			},
			{
				"stat",
				{
					"wizard_sponge",
					"add",
					1
				}
			},
		}
	}
}

items.ant = {
	{
		"data",
		{
			id = 21,
			rarity = 3,
			designation = "insect",
			image = get_image("sprites/items/ant.png"),
			box_back_effects = {
				color = 32
			},
		}
	},
	{
		"text",
		{
			{color = 22},
			"Ant"
		}
	},
	{
		"text",
		{
			{color = 32, font = 2},
			"A small and humble creature, but he is still ever so full of rage.",
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Landing attacks fills up an ant bar.\n§",
					{color = 9},
					"- When the bar is full, the ant queen is called, summoning a swarm of ants.\n§",
					{color = 9},
					"- When the swarm concludes, the bar empties completely.\n§",
					{color = 9},
					"- Ants count as friends!",
				}
			}
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Landing attacks fills up an ant bar which drains over time.\n§",
					{color = 9},
					"- The bar gets harder to fill the fuller it is.\n§",
					{color = 9},
					"- Your attack speed and movement speed scale with the bar's fullness.\n§",
					{color = 9},
					"- When the bar is completely filled, ants will constantly swarm.\n§",
					{color = 9},
					"- Ants count as friends!",
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9},
					"- An ant helps you out, bringing dropped pickups to you."
				}
			},
			{
				"stat",
				{
					"armor",
					"add",
					2
				}
			},
			{
				"stat",
				{
					"ant",
					"add",
					2
				}
			}
		}
	}
}



items.bone_buddy = {
	{
		"data",
		{
			id = 22,
			rarity = 1,
			designation = "sponge_buddies",
			image = get_image("sprites/items/bone_buddy.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Bone Buddy",
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"bone_buddy",
					"add",
					1
				}
			}
		}
	}
}

items.bloodstealer_orb = {
	{
		"data",
		{
			id = 23,
			rarity = 3,
			image = get_image("sprites/items/bloodstealer_orb.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Bloodstealer Orb",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"A pearl, stolen from the heart of a Titon.",
		}
	},
	{
		"slot",
		{
			{
				"stat",
				{
					"lifesteal",
					"add",
					25
				}
			},
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"lifesteal",
					"add",
					5
				}
			},
		}
	},
}

items.white_plasmid = {
	{
		"data",
		{
			id = 24,
			rarity = 3,
			designation = "plasmid",
			image = get_image("sprites/items/white_plasmid.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"White",
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Looks kinda edible.",
		}
	},
}

items.gold_stainless_nail = {
	{
		"data",
		{
			id = 25,
			rarity = 5,
			image = get_image("sprites/items/gold_stainless_nail.png"),
			designation = "artifact",
			soundfont = "metal",
			box_line_effects = {
				color = 6,
				shader = shaders.shimmer,
			},
			box_back_effects = {
				color = 6,
			}
		}
	},
	{
		"text",
		{
			{
				color = 6,
				shader = shaders.shimmer,
				offset_y = 0,
			},
			"Gold Stainless Nail",
		}
	},
	{
		"text",
		{
			{
				color = 10,
				font = 2,
			},
			"It's been torn through the distance of man."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Pure freedom."
				}
			},
			{
				"text",
				{
					{
						color = 9,
					},
					"- Gain a buff on hit which swaps the values of your \n§   minimum and maximum attack damage. ",
					{
						color = 10,
					},
					-- modify the font to have an hourglass symbol and directional arrows
					"[Dur. 00:07] ",
					{
						color = 12,
					},
					"[Cd. 00:10]"
				}
			},
			{
				"text",
				{
					{
						color = 9,
					},
					"- Enemies under the reign of a powerful force reject purity, becoming friendly."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					2
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					200
				}
			},
			{
				"stat",
				{
					"critical_hit_chance",
					"add",
					45
				}
			},
			{
				"stat",
				{
					"critical_hit_power",
					"add",
					25
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Secrets are still held from you."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					1.8
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					100
				}
			},
			{
				"stat",
				{
					"healing_power",
					"add",
					50
				}
			},
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Going through the motions..."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					1.5
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					20
				}
			},
			{
				"stat",
				{
					"healing_power",
					"add",
					10
				}
			},
		}
	}
}

items.screeming_scamper = {
	{
		"data",
		{
			id = 26,
			rarity = 1,
			designation = "rascal",
			image = get_image("sprites/items/screeming_scamper.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Screeming Scamper",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- The scamp has attuned to you, sharing your additional movement speed.\n§",
					{color = 9},
					"- Your attack damage scales with how fast the scamp is moving.\n§",
					{color = 9},
					"- It scampers around screaming at enemies, scaring them.\n§",
					{color = 9},
					"- Each scream has a ",
					{color = 22},
					"1% ",
					{color = 9},
					"chance to give the enemy a heart attack for 1000 damage.",
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"add",
					30
				}
			},
			{
				"stat",
				{
					"screeming_scamper",
					"add",
					1
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- This fella scampers around screaming at enemies, scaring them.\n§",
					{color = 9},
					"- Each scream has a ",
					{color = 22},
					"1% ",
					{color = 9},
					"chance to give the enemy a heart attack for 1000 damage.",
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"add",
					20
				}
			},
			{
				"stat",
				{
					"screeming_scamper",
					"add",
					1
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"movement_speed",
					"add",
					5
				}
			}
		}
	}
}

items.refining_nanobot = {
	{
		"data",
		{
			id = 27,
			rarity = 3,
			designation = "Veritim",
			image = get_image("sprites/items/refining_nanobot.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Refiner Nanobot"
		}
	}
}

items.midas_chip = {
	{
		"data",
		{
			id = 28,
			rarity = 3,
			image = get_image("sprites/items/midas_chip.png"),
			box_line_effects = {
				color = 9,
				shader = shaders.shimmer,
			},
			box_back_effects = {
				color = 9,
				shader = shaders.shimmer,
			}
		}
	},
	{
		"text",
		{
			{color = 8, shader = shaders.shimmer},
			"Midas Chip"
		}
	}
}

items.red_potion = {
	{
		"data",
		{
			id = 29,
			rarity = 1,
			image = get_image("sprites/items/red_potion.png"),
			box_back_effects = {
				color = 28
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Red Potion"
		}
	},
}

items.sponge_with_cap = {
	{
		"data",
		{
			id = 30,
			rarity = 2,
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_cap.png"),
			box_back_effects = {
				color = 32
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Sponge With Cap",
		}
	},
	{
		"text",
		{
			{color = 32, font = 2},
			"Oi oi oi, you got a loicense for that sponge?",
		}
	}
}

items.sponge_with_bowler = {
	{
		"data",
		{
			id = 31,
			rarity = 2,
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_bowler.png"),
			box_back_effects = {
				color = 31
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Sponge With Bowler",
		}
	},
	{
		"text",
		{
			{color = 31, font = 2},
			"This guy's a real loon."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 22, font = 2},
					"Clip 'em, boys."
				}
			},
			{
				"text",
				{
					{color = 9},
					"- A sponge follows you around!\n§",
					{color = 9},
					"- The sponge uses a bean-shooter to light up your foes.\n§",
					{color = 9},
					"- When the sponge engages in combat, he calls in a chopper squad to take the enemy out."
				}
			},
			{
				"stat",
				{
					"gangster_sponge",
					"add",
					1
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A sponge follows you around!\n§",
					{color = 9},
					"- The sponge uses a bean-shooter to light up your foes."
				}
			},
			{
				"stat",
				{
					"gangster_sponge",
					"add",
					1
				}
			},
		}
	}
}



items.dog_chow = {
	{
		"data",
		{
			id = 32,
			rarity = 2,
			image = get_image("sprites/items/dog_chow.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Doggie Chow",
		}
	},
	{
		"text",
		{
			{color = 31, font = 2},
			"It tastes delicious!",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Duplicates your friends!",
				}
			},
			{
				"text",
				{
					{color = 22, font = 2},
					"- What are you gonna do with all these friends?"
				}
			},
			{
				"stat",
				{
					"friend_damage",
					"percent",
					25
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"friend_damage",
					"percent",
					5
				}
			}
		}
	}
}

items.red_arrow_pointing_right = {
	{
		"data",
		{
			id = 33,
			rarity = 2,
			image = get_image("sprites/items/red_arrow_pointing_right.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Red Arrow Pointing Right"
		}
	},
	{
		"text",
		{
			{color = 27, font = 2},
			"ZAMN!",
		}
	}
}

items.lute = {
	{
		"data",
		{
			id = 34,
			rarity = 3,
			designation = "instrument",
			image = get_image("sprites/items/lute.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Enchanted Lute"
		}
	},
	{
		"text",
		{
			{color = 22, font = 2},
			"Whose music was electric? What?"
		}
	},
}

items.blue_potion = {
	{
		"data",
		{
			id = 35,
			rarity = 1,
			image = get_image("sprites/items/blue_potion.png"),
			box_back_effects = {
				color = 19
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Blue Potion"
		}
	}
}



items.the_hand = {
	{
		"data",
		{
			id = 36,
			rarity = 5,
			image = get_image("sprites/items/the_hand.png"),
			box_line_effects = {
				shader = shaders.shimmer,
				color = 25
			},
			box_back_effects = {
				color = 21
			}
		}
	},
	{
		"text",
		{
			{color = 14, shader = shaders.shimmer, font = 1},
			"The Hand"
		}
	},
	{
		"text",
		{
			{color = 28, font = 2, shader = shaders.shimmer},
			"Runes are etched in its palm."
		}
	}
}

items.rusty_coin = {
	{
		"data",
		{
			id = 37,
			rarity = 2,
			image = get_image("sprites/items/rusty_coin.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Rusty Coin",
		}
	},
	{
		"text",
		{
			{color = 32, font = 2},
			"An insane teacher's old coin.",
		}
	},
}

items.old_cross = {
	{
		"data",
		{
			id = 38,
			rarity = 2,
			image = get_image("sprites/items/old_cross.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Old Cross",
		}
	},
	{
		"text",
		{
			{color = 32, font = 2},
			"A sad preacher's ruined cross.",
		}
	},
}

items.smart_goggles = {
	{
		"data",
		{
			id = 39,
			rarity = 1,
			image = get_image("sprites/items/smart_goggles.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Smart Spectacles",
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- You can see an item's designation in its tooltip.\n§",
					{color = 9},
					"- You can see enemies' health bars."
				}
			},
			{
				"stat",
				{
					"critical_hit_chance",
					"add",
					15
				}
			}
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{color = 9},
					"- You can see an item's designation in its tooltip.",
				}
			},
			{
				"stat",
				{
					"critical_hit_chance",
					"add",
					2.5
				}
			}
		}
	}
}

items.wasp = {
	{
		"data",
		{
			id = 40,
			rarity = 1,
			designation = "insect",
			image = get_image("sprites/items/wasp.png"),
			box_back_effects = {
				color = 9
			}
		}
	},
	{
		"text",
		{
			{color = 22, padding_x = 100},
			"Wasp",
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A wasp accompanies you, stinging enemies and draining their lifeforce.§",
					{color = 9},
					"- The wasp will sting and drain multiple enemies' lifeforce before returning and healing you.",
				}
			},
			{
				"stat",
				{
					"healing_power",
					"add",
					40
				}
			},
			{
				"stat",
				{
					"wasp",
					"add",
					1
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A wasp accompanies you, stinging enemies.§",
					{color = 9},
					"- After the wasp stings an enemy, it will come back to you and heal you for a portion of the damage it dealt."
				}
			},
			{
				"stat",
				{
					"healing_power",
					"add",
					25
				}
			},
			{
				"stat",
				{
					"wasp",
					"add",
					1
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"healing_power",
					"add",
					5
				}
			},
		}
	}
}

items.mog_mud = {
	{
		"data",
		{
			id = 41,
			rarity = 1,
			image = get_image("sprites/items/mog_mud.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Mud From The Mog Bog"
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_damage",
					"add",
					1
				}
			}
		}
	}
}

items.beegle_buglet = {
	{
		"data",
		{
			id = 42,
			rarity = 1,
			designation	= "insect",
			image = get_image("sprites/items/beegle_buglet.png"),
			box_back_effects = {
				color = 16
			}
		}
	},
	{
		"text",
		{
			{color = 22},
			"Beegle Buglet"
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Spray fungal spores.§",
					{color = 9},
					"- The amount of spores sprayed scales with your hyphon count.§",
					{color = 9},
					"- Spores attach to enemies, making them weaker.§",
					{color = 9},
					"- Killing afflicted enemies drops hyphons.",
				}
			},
			{
				"stat",
				{
					"max_health",
					"add",
					100
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"max_health",
					"add",
					25
				}
			}
		}
	}
}

-- items.clown_nose = {
	
-- }

items.spud = {
	{
		"data",
		{
			id = 43,
			rarity = 3,
			image = get_image("sprites/items/spud.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Spud"
		}
	},
	{
		"text",
		{
			{color = 31, font = 2},
			"Boil it, mash it, stick it in a stew!"

		}
	}
}

items.land_prawn = {
	{
		"data",
		{
			id = 44,
			rarity = 3,
			designation = "insect",
			image = get_image("sprites/items/land_prawn.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Land Prawn"
		}
	},
	{
		"text",
		{
			{color = 29, font = 2},
			"It's delicious!"
		}
	}
}

items.blue_glob = {
	{
		"data",
		{
			id = 45,
			rarity = 3,
			image = get_image("sprites/items/blue_glob.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Blue Glob"
		}
	},
	{
		"text",
		{
			{color = 10, font = 2},
			"This one is called Bim!"
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Bim blob floats in the air, preying on enemies.§",
					{color = 9},
					"- The Bim blob dissolves enemies, transforming their bodies into nutrients he can absorb.§",
					{color = 9},
					"- Touching the Bim blob grants you a dissolution effect on your shots. ",
					{color = 10},
					"[Dur. 00:30]§",
					{color = 9},
					"- If the Jim blob and Bim blob are near each other, they become more aggressive.",
				}
			},
			{
				"stat",
				{
					"bim_blob",
					"add",
					1
				}
			}
		}
	}
}

items.green_glob = {
	{
		"data",
		{
			id = 46,
			rarity = 2,
			image = get_image("sprites/items/green_glob.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Green Glob"
		}
	},
	{
		"text",
		{
			{color = 10, font = 2},
			"This one is called Jim!"
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Jim blob slides across the ground, preying on enemies.\n§",
					{color = 9},
					"- The Jim blob dissolves enemies, transforming their bodies into nutrients he can absorb.\n§",
					{color = 9},
					"- Touching the Jim blob grants you a dissolution effect on your shots. ",
					{color = 10},
					"[Dur. 00:15]\n§",
					{color = 9},
					"- If the Jim blob and Bim blob are near each other, they become more aggressive.",
				}
			},
			{
				"stat",
				{
					"jim_blob",
					"add",
					1
				}
			}
		}
	}
}

items.honeycomb = {
	{
		"data",
		{
			id = 47,
			rarity = 1,
			image = get_image("sprites/items/honeycomb.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Honeycomb"
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- A tiny wasp patches you up.\n§",
					{color = 9},
					"- The wasp's healing scales with your friend damage."
				}
			},
			{
				"stat",
				{
					"friend_damage",
					"add",
					15
				}
			},
			{
				"stat",
				{
					"health_regeneration",
					"add",
					2.5
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"health_regeneration",
					"add",
					1
				}
			}
		}
	}
}

items.fungah_drum = {
	{
		"data",
		{
			id = 48,
			rarity = 2,
			image = get_image("sprites/items/fungah_drum.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Fungah Drum"
		}
	},
}

items.old_cartridge = {
	{
		"data",
		{
			id = 49,
			rarity = 2,
			image = get_image("sprites/items/old_cartridge.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Old Cartridge"
		}
	},
}

items.odd_blue_crystal = {
	{
		"data",
		{
			id = 50,
			rarity = 1,
			image = get_image("sprites/items/odd_blue_crystal.png"),
		}
	},
	{
		"text",
		{
			{color = 22},
			"Odd Blue Crystal"
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"armor",
					"add",
					3
				}
			}
		}
	}
}

items.beegle_gauntlet = {
	{
		"data",
		{
			id = 51,
			rarity = 3,
			image = get_image("sprites/items/beegle_gauntlet.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Beegle Gauntlet"
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{color = 9},
					"- Channel the strength of a beegle!§",
					{color = 9},
					"- Chuck large boulders which pierce through enemies three times, bursting afterward."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"add",
					30
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"percent",
					10
				}
			}
		}
	},
	{
		"area",
		{
			{
				"stat",
				{
					"attack_speed",
					"add",
					5
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"percent",
					2
				}
			}
		}
	}
}

items.sun_claw = {
	{
		"data",
		{
			id = 52,
			rarity = 3,
			image = get_image("sprites/items/sun_claw.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Claw"
		}
	},
}

items.sky_shard = {
	{
		"data",
		{
			id = 53,
			rarity = 2,
			image = get_image("sprites/items/sky_shard.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Sky Shard"
		}
	},
}

items.jar_of_flesh = {
	{
		"data",
		{
			id = 54,
			rarity = 2,
			image = get_image("sprites/items/jar_of_flesh.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Jar of Flesh"
		}
	},
}

items.cog = {
	{
		"data",
		{
			id = 55,
			rarity = 2,
			image = get_image("sprites/items/cog.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Cog"
		}
	},
}

items.danger_club = {
	{
		"data",
		{
			id = 56,
			rarity = 1,
			image = get_image("sprites/items/danger_club.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Danger Club"
		}
	},
}

items.hay_fork = {
	{
		"data",
		{
			id = 57,
			rarity = 1,
			image = get_image("sprites/items/hay_fork.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Hay Fork"
		}
	},
}

items.chambaroot = {
	{
		"data",
		{
			id = 58,
			rarity = 1,
			image = get_image("sprites/items/chambaroot.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Chambaroot"
		}
	},
}

items.rudroot = {
	{
		"data",
		{
			id = 59,
			rarity = 1,
			image = get_image("sprites/items/rudroot.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Rudroot"
		}
	},
}

items.cheese = {
	{
		"data",
		{
			id = 60,
			rarity = 1,
			image = get_image("sprites/items/cheese.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Cheese"
		}
	},
}

items.diabolical_candle = {
	{
		"data",
		{
			id = 61,
			rarity = 3,
			image = get_image("sprites/items/diabolical_candle.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Diabolical Candle"
		}
	},
}

items.hoop = {
	{
		"data",
		{
			id = 62,
			rarity = 2,
			image = get_image("sprites/items/hoop.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Hoop"
		}
	},
}

items.ice_cube = {
	{
		"data",
		{
			id = 63,
			rarity = 4,
			image = get_image("sprites/items/ice_cube.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Ice Cube"
		}
	},
}

items.bronze_shears = {
	{
		"data",
		{
			id = 64,
			rarity = 2,
			image = get_image("sprites/items/bronze_shears.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Bronze Shears"
		}
	},
}

items.snowboy = {
	{
		"data",
		{
			id = 65,
			rarity = 2,
			image = get_image("sprites/items/snowboy.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Snowboy"
		}
	},
}

items.snowflake = {
	{
		"data",
		{
			id = 66,
			rarity = 1,
			image = get_image("sprites/items/snowflake.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Snowflake"
		}
	},
}

items.crisp_shard = {
	{
		"data",
		{
			id = 67,
			rarity = 2,
			image = get_image("sprites/items/crisp_shard.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Crisp Shard"
		}
	},
}

items.metal_scrap = {
	{
		"data",
		{
			id = 68,
			rarity = 1,
			image = get_image("sprites/items/metal_scrap.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Scrap"
		}
	},
}

items.sad_pod = {
	{
		"data",
		{
			id = 69,
			rarity = 3,
			image = get_image("sprites/items/sad_pod.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Sad Pod"
		}
	},
}

items.golden_lasso = {
	{
		"data",
		{
			id = 70,
			rarity = 1,
			image = get_image("sprites/items/golden_lasso.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Golden Lasso"
		}
	},
}

items.tower_brick = {
	{
		"data",
		{
			id = 71,
			rarity = 1,
			image = get_image("sprites/items/tower_brick.png"),
		}
	},

	{
		"text",
		{
			{color = 22},
			"Tower Brick"
		}
	},
}

-- more entries here
local result_m = love.timer.getTime() - start_m
print(string.format("Items loaded in %.3f milliseconds!", result_m * 1000))
return items