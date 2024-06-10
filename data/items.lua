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

items = {}

items.smorc_skull = {
	{
		"data",
		{
			id = 1,
			rarity = 1,
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

items.mangic_ingot = {
	{
		"data",
		{
			id = 2,
			rarity = 2,
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
					"Instead of bullets, fire a continuous laserbeam.\n§",
					{
						color = 9,
					},
					"On hit, shock enemies for an extra ",
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
					"When an enemy is shocked, a ",
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
					"If you don't already, acquire a ",
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
					"On hit, gain a ",
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

--§

items.weezt_bulb = {
	{
		"data",
		{
			id = 3,
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
					{
						color = 9,
					},
					"The bulb has opened, summoning a Weezt Sprout to eat your foes.\n§The plant moves faster when exposed to sunlight.",
				}
			},
			{
				"stat",
				{
					"movement_speed",
					"percent",
					20
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

items.ring_of_barley = {
	{
		"data",
		{
			id = 4,
			rarity = "common",
			image = get_image("sprites/items/ring_of_barley.png"),
		}
	},
	{
		"name", 
		{
			"Wheat Ring"
		}
	},
	{
		"lore", 
		{
			"Get ready to carbo-load."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"When an enemy is killed, 10% chance to spawn a loaf of bread.",
					"If a loaf of bread touches another loaf of bread, they will fuse.",
					"This surely can't be bad, right?" -- evil loaf if too much fusion, bread berzerks
				}
			},
			{
				"attack_speed",
				{
					"percent",
					10
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Eating a loaf of bread increases your attack speed by 10%."
				}
			}
		}
	},
	{
		"area",
		{
			{
				"bullet",
				{
					"Bread heals you for 20% more."
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
			image = get_image("sprites/items/ring_of_barley.png"),
		}
	},
	{
		"text",
		{
			{
				color = 22,
			},
			"Wheat Ring",
		}
	}
}

items.toaster = {
	{
		"data",
		{
			id = 5,
			rarity = "common",
			image = get_image("sprites/items/toaster.png"),
		}
	},
	{
		"name",
		{
			"Toaster"
		}
	},
	{
		"lore",
		{
			"Not recommended for use around water."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Create an inferno aura around you, burning enemies and loaves of bread.",
					"Loaves of bread become toast, increasing their healing power."
				}
			},
			{
				"movement_speed",
				{
					"add",
					20
				}
			}
		}
	},
	{
		"area",
		{
			{
				"movement_speed",
				{
					"add",
					2
				}
			}
		}
	}
}

items.sponge_with_cap = {
	{
		"data",
		{
			id = 33,
			rarity = "common",
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_cap.png"),
		}
	},
	{
		"name",
		{
			"Sponge With Cap"
		}
	},
	{
		"lore",
		{
			"Oi oi oi, you got a license for that?"
		}
	}
}

items.sponge_with_bowler = {
	{
		"data",
		{
			id = 34,
			rarity = "common",
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_bowler.png"),
		}
	},
	{
		"name",
		{
			"Sponge With Bowler",
		}
	},
	{
		"lore",
		{
			"This guy's a real goon."
		}
	},
	{
		"big_slot",
		{
			{
				"description",
				{
					"Clip 'em, boys."
				}
			},
			{
				"bullet",
				{
					"A sponge follows you around!",
					"The sponge uses a bean-shooter to light up his foes.",
					"When the sponge engages in combat, he calls in a chopper squad to take the enemy out."
				}
			},
			{
				"gangster_sponge",
				{
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
				"bullet",
				{
					"A sponge follows you around!",
					"The sponge uses a bean-shooter to light up his foes."
				}
			},
			{
				"gangster_sponge",
				{
					"add",
					1
				}
			}
		}
	}
}

items.sponge_with_wizard_hat = {
	{
		"data",
		{
			id = 35,
			rarity = "common",
			designation = "sponge_buddies",
			image = get_image("sprites/items/sponge_with_wizard_hat.png"),
		}
	},
	{
		"name",
		{
			"Sponge With Wizard Hat"
		}
	},
	{
		"lore",
		{
			"He's just making it up as he goes."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"A sponge follows you around!",
					"The sponge lights enemies on fire.",
					"The sponge creates electrical discharges, exploding enemies if they are on fire.",
				}
			},
			{
				"wizard_sponge",
				{
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
				"bullet",
				{
					"A sponge follows you around!",
					"The sponge lights enemies on fire.",
				}
			},
			{
				"wizard_sponge",
				{
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
				"bullet",
				{
					"A sponge rides on your back.",
				}
			},
			{
				"movement_speed",
				{
					"add",
					3
				}
			}
		}
	}
}

items.dog_chow = {
	{
		"data",
		{
			id = 9,
			rarity = "common",
			image = get_image("sprites/items/dog_chow.png"),
		}
	},
	{
		"name",
		{
			"Doggie Chow"
		}
	},
	{
		"lore",
		{
			"It tastes delicious!"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Duplicates your friends!"
				}
			},
			{
				"description",
				{
					"What am I gonna do with all these friends?"
				}
			},
			{
				"friend_damage",
				{
					"percent",
					25
				}
			},
		}
	},
	{
		"area",
		{
			{
				"friend_damage",
				{
					"percent",
					5
				}
			}
		}
	}
}

items.quacker = {
	{
		"data",
		{
			id = 10,
			rarity = "common",
			image = get_image("sprites/items/quacker.png"),
		}
	},
	{
		"name",
		{
			"Quacker"
		}
	},
	{
		"lore",
		{
			"This fella is ravenous!"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Loaves of bread attract ducks.",
					"Ducks will peck at creatures which are too close to loaves of bread.",
					"Ducks who eat toast will ignite, making them faster.",
					"Ducks count as friends."
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"When you eat a loaf of bread, emit a duck shockwave which does 20 damage to enemies.",
					"The shockwave does more damage if the loaf of bread is larger."
				}
			}
		}
	},
	{
		"area",
		{
			{
				"bullet",
				{
					"Bread heals you for 20% more."
				}
			}
		}
	}
}

items.personal_wormhole = {
	{
		"data",
		{
			id = 11,
			rarity = "legendary",
			image = get_image("sprites/items/personal_wormhole.png"),
		}
	},
	{
		"name", 
		{
			"Pocket Wormhole"
		}
	},
	{
		"lore", 
		{
			"It's a bit heavy!"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Gain a 0.1% chance to spawn an item every time you damage an enemy."
				}
			},
			{
				"pierce",
				{
					"add",
					2
				}
			},
			{
				"attack_speed",
				{
					"percent",
					20
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Spawn a random item in your bag at the start of every zone."
				}
			},
			{
				"attack_speed",
				{
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
				"description",
				{
					"You are now wearing cargo shorts."
				}
			},
			{
				"attack_speed",
				{
					"add",
					2
				}
			}
		}
	}
}



items.blast_gem = {
	{
		"data",
		{
			id = 12,
			rarity = "common",
			image = get_image("sprites/items/blast_gem.png"),
		}
	},
	{
		"name",
		{
			"Blast Gem"
		}
	},
	{
		"lore",
		{
			"Very sensitive, handle with care."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Your attacks explode on hit, dealing 25% of your total attack damage.",
					"The size of the explosion increases based on your total attack damage."
				}
			},
			{
				"attack_damage",
				{
					"add",
					15
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Enemies explode on death, dealing 10% of your total attack damage.",
					"The size of the explosion, increaes based on your total attack damage."
				}
			},
			{
				"attack_damage",
				{
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
				"attack_damage",
				{
					"add",
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
			id = 13,
			rarity = "common",
			image = get_image("sprites/items/lil_gabbron.png"),
		}
	},
	{
		"name",
		{
			"Lil Gabbron"
		}
	},
	{
		"lore",
		{
			"Primed and ready for murder!"
		}
	},
	{
		"big_slot",
		{
			{
				"description",
				{
					"It's murdering time!"
				}
			},
			{
				"bullet",
				{
					"You become an accomplice to lil gabbron, who follows you and brutally consumes prey.",
					"Lil gabbron latches onto foes, stunning them and making them weaker."
				}
			},
			{
				"lil_gabbron",
				{
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
				"bullet",
				{
					"Lil gabbron imprints on you, matching your behavior.",
					"Lil gabbron will shoot when you do, following right behind you."
				}
			},
			{
				"lil_gabbron",
				{
					"add",
					1
				}
			},
		}
	},
	{
		"area",
		{
			{
				"bullet",
				{
					"Lil gabbron becomes your accomplice, accompanying you and bumping into your enemies.",
					"Bump damage increases with lil gabbron's velocity."
				}
			},
			{
				"lil_gabbron",
				{
					"add",
					1
				}
			},
		}
	}
}


items.jugg_milk_carton = {
	{
		"data",
		{
			id = 14,
			rarity = "common",
			image = get_image("sprites/items/jugg_milk_carton.png"),
		}
	},
	{
		"name",
		{
			"Jugg Milk"
		}
	},
	{
		"lore",
		{
			"The healthiest jugg milk, grown and raised on the oceanside."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"The milk fortifies your body, granting you +2.5 Armor per zone completed."
				}
			},
			{
				"armor",
				{
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
				"armor",
				{
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
				"armor",
				{
					"add",
					1
				}
			}
		}
	},
}

items.pink_plasmid = {
	{
		"data",
		{
			id = 15,
			rarity = "epic",
			designation = "plasmid",
			image = get_image("sprites/items/pink_plasmid.png"),
		}
	},
	{
		"name",
		{
			"Pink"
		}
	},
	{
		"lore",
		{
			"It's fuzzy in some places, smooth others."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Enemies stick to you when you run into them.",
					"Gain 1 armor for every enemy stuck to you.",
					"Each enemy only sticks around to tank 100 damage.",
				}
			}
		}
	}
}

items.ant = {
	{
		"data",
		{
			id = 32,
			rarity = "common",
			designation = "sponge_buddies",
			image = get_image("sprites/items/ant.png"),
		}
	},
	{
		"name",
		{
			"Ant"
		}
	},
	{
		"lore",
		{
			"A small and humble creature, but he is still ever so full of rage."
		}
	},
	{
		"area",
		{
			{
				"bullet",
				{
					"An ant helps you out, bringing dropped pickups to you."
				}
			},
			{
				"armor",
				{
					"add",
					2
				}
			},
			{
				"ant",
				{
					"add",
					1
				}
			}
		}
	},
}

items.blue_plasmid = {
	{
		"data",
		{
			id = 17,
			rarity = "rare",
			designation = "plasmid",
			image = get_image("sprites/items/blue_plasmid.png"),
		}
	},
	{
		"name",
		{
			"Blue"
		}
	},
	{
		"lore",
		{
			"It's squishy, like gelatin."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Enemies bounce off of the top and bottom of the screen.",
					"Enemies can now bounce into each other, dealing damage.",
					"Your attacks knock enemies back."
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Your bullets now bounce off the sides of the screen.",
					"Additionally, your bullets bounce off of enemies."
				}
			},
			{
				"bounce",
				{
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
			id = 40,
			rarity = "common",
			image = get_image("sprites/items/empty_jar.png"),
		}
	},
	{
		"name",
		{
			"Empty Jar"
		}
	},
	{
		"lore",
		{
			"It's sad because it's empty."
		}
	}
}


items.jar_of_eyeballs = {
	{
		"data",
		{
			id = 41,
			rarity = "common",
			image = get_image("sprites/items/jar_of_eyeballs.png"),
		}
	},
	{
		"name",
		{
			"Jar of Eyeballs"
		}
	},
	{
		"lore",
		{
			"I think they've expired..."
		}
	}
}

items.weird_mushroom = {
	{
		"data",
		{
			id = 20,
			rarity = "common",
			image = get_image("sprites/items/weird_mushroom.png"),
		}
	},
	{
		"data",
		{
			rarity = "legendary",
		}
	},
	{
		"name",
		{
			"Weird Mushroom"
		}
	},
	{
		"lore",
		{
			"Eat this to focus your brain!"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Every item pulled will be of a random rarity."
				}
			},
			{
				"attack_speed",
				{
					"percent",
					65
				}
			},
			{
				"movement_speed",
				{
					"percent",
					-10
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Enemy spawns are random."
				}
			},
			{
				"attack_speed",
				{
					"percent",
					25
				}
			},
			{
				"movement_speed",
				{
					"percent",
					-7.5
				}
			}
		}
	},
	{
		"area",
		{
			{
				"attack_speed",
				{
					"percent",
					5
				}
			},
			{
				"movement_speed",
				{
					"percent",
					-5
				}
			}
		}
	}
}


items.wyrm = {
	{
		"data",
		{
			id = 21,
			rarity = "rare",
			image = get_image("sprites/items/wyrm.png"),
		}
	},
	{
		"name",
		{
			"Wyrm Pup"
		}
	},
	{
		"lore",
		{
			"A juvenile wyrm. Its hiss is intimidating, but it's harmless."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"On hit, poison enemies.",
					"Sometimes, your shots can burst, coating nearby enemies in venom.",
					"Poison ticks once every second for 10 damage.",
					"Venom makes poison more painful, doubling its damage.",
				}
			},
			{
				"pierce",
				{
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
				"bullet",
				{
					"On hit, poison enemies.",
					"Poison ticks once every second for 10 damage."
				}
			},
			{
				"pierce",
				{
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
				"pierce",
				{
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
			id = 22,
			rarity = "epic",
			image = get_image("sprites/items/subpocket.png"),
		}
	},
	{
		"name",
		{
			"Subpocket"
		}
	},
	{
		"lore",
		{
			"Space within your space!"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Gain 2 more big slots."
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"Gain 4 more slots."
				}
			}
		}
	}
}


items.wood_block = {
	{
		"data",
		{
			id = 23,
			rarity = "common",
			image = get_image("sprites/items/wood_block.png"),
		}
	},
	{
		"name",
		{
			"Wood Block"
		}
	},
	{
		"lore",
		{
			"Sturdy, yet flexible."
		}
		
	},
	{
		"big_slot",
		{
			{
				"max_health",
				{
					"add",
					150
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"max_health",
				{
					"add",
					75
				}
			}
		}
	},
	{
		"area",
		{
			{
				"max_health",
				{
					"add",
					10
				}
			}
		}
	}
}

items.steel_block = {
	{
		"data",
		{
			id = 24,
			rarity = "common",
			image = get_image("sprites/items/steel_block.png"),
		}
	},
	{
		"name",
		{
			"Steel Block"
		}
	},
	{
		"lore",
		{
			"Perfectly durable and malleable."
		}
	},
	{
		"big_slot",
		{
			{
				"armor",
				{
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
				"armor",
				{
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
				"armor", 
				{
					"add",
					5
				}
			}
		}
	}
}

items.bone_buddy = {
	{
		"data",
		{
			id = 25,
			rarity = "common",
			designation = "sponge_buddies",
			image = get_image("sprites/items/bone_buddy.png"),
		}
	},
	{
		"name",
		{
			"Bone Buddy"
		}
	},
	{
		"area",
		{
			{
				"bone_buddy",
				{
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
			id = 26,
			rarity = "rare",
			image = get_image("sprites/items/bloodstealer_orb.png"),
		}
	},
	{
		"name", 
		{
			"Bloodstealer Orb"
		}
	},
	{
		"lore",
		{
			"A titon's pearl."
		}
	},
	{
		"slot",
		{
			{
				"lifesteal",
				{
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
				"lifesteal",
				{
					"add",
					5
				}
			}
		}
	}
}

items.white_plasmid = {
	{
		"data",
		{
			id = 16,
			rarity = "common",
			designation = "plasmid",
			image = get_image("sprites/items/white_plasmid.png"),
		}
	},
	{
		"name",
		{
			"White"
		}
	},
	{
		"lore",
		{
			"Looks kinda edible."
		}
	}
}

items.gold_stainless_nail = {
	{
		"data",
		{
			id = 53,
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
				padding_x = 60,
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
					-2
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
					1.5
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
					1.2
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

items.rusty_coin = {
	{
		"data",
		{
			id = 29,
			rarity = "rare",
			designation = "you_and_i",
			image = get_image("sprites/items/rusty_coin.png"),
		}
	},
	{
		"name",
		{
			"Rusty Coin"
		}
	},
	{
		"lore",
		{
			"It never knew its own fruitless worth."
		}
	},
}

items.old_cross = {
	{
		"data",
		{
			id = 30,
			rarity = "rare",
			designation = "you_and_i",
			image = get_image("sprites/items/old_cross.png"),
		}
	},
	{
		"name",
		{
			"Old Cross"
		}
	},
	{
		"lore",
		{
			"It never knew its own fruitless worth."
		}
	},
}

items.screeming_scamper = {
	{
		"data",
		{
			id = 31,
			rarity = "common",
			image = get_image("sprites/items/screeming_scamper.png"),
		}
	},
	{
		"name",
		{
			"Screeming Scamper"
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"The scamp has attuned to you, sharing your additional movement speed.",
					"Your attack damage scales with how fast the scamp is moving.",
					"It scampers around screaming at enemies, scaring them.",
					"Each scream has a 1% chance to give the enemy a heart attack for 1000 damage.",
				}
			},
			{
				"movement_speed",
				{
					"add",
					25
				}
			},
			{
				"screeming_scamper",
				{
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
				"bullet",
				{
					"This fella scampers around screaming at enemies, scaring them.",
					"Each scream has a 1% chance to give the enemy a heart attack for 1000 damage."
				}
			},
			{
				"movement_speed",
				{
					"add",
					5
				}
			},
			{
				"screeming_scamper",
				{
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
				"movement_speed",
				{
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
			id = 59,
			rarity = "common",
			designation = "Ancient Veritim Technology",
			image = get_image("sprites/items/refining_nanobot.png"),
		}
	},
	{
		"name",
		{
			"Refiner Nanobot"
		}
	}
}

items.midas_chip = {
	{
		"data",
		{
			id = 80,
			rarity = "common",
			image = get_image("sprites/items/midas_chip.png"),
		}
	},
	{
		"name",
		{
			"Midas Chip"
		}
	}
}

items.red_potion = {
	{
		"data",
		{
			id = 42,
			rarity = "common",
			image = get_image("sprites/items/red_potion.png"),
		}
	},
	{
		"name",
		{
			"Red Drink"
		}
	}
}

items.blue_potion = {
	{
		"data",
		{
			id = 43,
			rarity = "common",
			image = get_image("sprites/items/blue_potion.png"),
		}
	},
	{
		"name",
		{
			"Blue Drink"
		}
	}
}

items.red_arrow_pointing_right = {
	{
		"data",
		{
			id = 48,
			rarity = "common",
			image = get_image("sprites/items/red_arrow_pointing_right.png"),
		}
	},
	{
		"name",
		{
			"Red Arrow Pointing Right"
		}
	},
	{
		"lore",
		{
			"ZAMN!"
		}
	}
}

items.lute = {
	{
		"data",
		{
			id = 50,
			rarity = "common",
			designation = "instrument",
			image = get_image("sprites/items/lute.png"),
		}
	},
	{
		"name",
		{
			"Enchanted Lute"
		}
	},
	{
		"lore",
		{
			"Who's music was electric? What?"
		}
	}
}

items.the_hand = {
	{
		"data",
		{
			id = 51,
			rarity = "common",
			image = get_image("sprites/items/the_hand.png"),
		}
	},
	{
		"name",
		{
			"The Hand"
		}
	}
}

items.smart_goggles = {
	{
		"data",
		{
			id = 52,
			rarity = "common",
			image = get_image("sprites/items/smart_goggles.png"),
		}
	},
	{
		"name",
		{
			"Smart Spectacles"
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"You can see an item's designation in its tooltip.",
					"You can see your enemies' health bars."
				}
			},
			{
				"critical_hit_chance",
				{
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
				"bullet",
				{
					"You can now see an item's designation in its tooltip."
				}
			},
			{
				"critical_hit_chance",
				{
					"add",
					2.5
				}
			}
		}
	}
}

-- more entries here
local result_m = love.timer.getTime() - start_m
print(string.format("Items loaded in %.3f milliseconds!", result_m * 1000))
return items