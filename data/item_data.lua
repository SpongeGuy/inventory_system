-- access player stats here
local start_m = love.timer.getTime()

items = {}

items.STAT_CATEGORIES = {
	attack_damage = "attack_damage",
	max_health = "max_health",
	movement_speed = "movement_speed",
	armor = "armor",
	lil_gabbron = "lil_gabbron",
	wizard_sponge = "wizard_sponge",
	pierce = "pierce",
	attack_speed = "attack_speed",
	healing_power = "healing_power",
}

items.DESC_CATEGORIES = {
	name = "name",
	lore = "lore",
	description = "description",
	bullet = "bullet",
	note = "note",
}

items.SLOT_CATEGORIES = {
	big_slot = "big_slot",
	slot = "slot",
	area = "area",
}

items.SLOT_VANITY_NAMES = {
	big_slot = "Socketed:",
	slot = "Slotted:",
	area = "Bagged:",
}

items.smorc_skull = {
	{
		"name", 
		{
			"Smorc Skull"
		}
	},
	{
		"lore", 
		{
			"Ripped straight out of the head of a smorc."
		}
	},
	{
		"big_slot",
		{
			{
				"bullet",
				{
					"Accelerate your attack speed up to 3x while damaging enemies."
				}
			},
			{
				"attack_damage", 
				{
					"multiply",
					2
				}
			},
			{
				"description",
				{
					"Let the hate flow through you."
				}
			},
			
		}
	},
	{
		"slot",
		{
			{
				"attack_damage",
				{
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
				"attack_damage",
				{
					"add",
					5
				}
			}
		}
	}
}

items.mangic_ingot = {
	{
		"name", {
			"Mangic Ingot",
		}
	},
	{
		"lore", {
			"Real Mangic, ultraconcentrated into one ingot!",
		}
	},
	{
		"default", {
			{
				"description", {
					"It shimmers a blue hue, emitting sparks when touched.",
				}
			}
		}
	},
	{
		"big_slot", {
			{
				"bullet", {
					"Instead of bullets, fire a continuous laserbeam.",
					"On hit, shock enemies for an extra 10 damage.",
					"When an enemy is shocked, 10% chance for a bolt of lightning to arc to another enemy."
				}
			}
		}
	},
	{
		"slot", {
			{
				"bullet", {
					"If you don't already, acquire a 50 point shield at the start of every zone.",
				},
			},
			{
				"attack_damage", {
					"add",
					5
				},
			},
			{
				"movement_speed", {
					"percent", 
					-5
				},
			},
			{
				"armor", {
					"add",
					5
				}
			}
		}
	},
	{
		"area", {
			{
				"bullet", {
					"1% chance to kill non-boss enemies in one shot!",
				}
			},
			{
				"attack_damage", {
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
		"name", {
			"Weezt Bulb"
		}
	},
	{
		"lore", {
			"Something is wriggling inside it."
		}
	},
	{
		"big_slot",
		{
			{
				"description",
				{
					"It's alive!"
				}
			},
			{
				"bullet",
				{
					"The bulb has opened, summoning a Weezt Sprout to eat your foes!",
					"The plant moves faster when exposed to sunlight."
				}

			},
			{
				"movement_speed",
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
					"The bulb wriggles around violently, altering your movement.",
					"When moving fast enough, pound enemies out of the way, dealing extra damage."
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
					"percent",
					5
				}
			}
		}
	}
}

items.ring_of_barley = {
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

items.toaster = {
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
			}
			
		}
	}
}

items.sponge_with_cap = {
	{
		"name",
		{
			"Sponge With Cap"
		}
	},
	{

	}
}

items.sponge_with_bowler = {
	{
		"name",
		{
			"Sponge With Bowler",
		}
	},
	{
		"slot",
		{
			{
				"bullet",
				{
					"A sponge rides on your back.",
					"The sponge heals you for 5% of damage you take."
				}
			}
		}
	}
}

items.sponge_with_wizard_hat = {
	{
		"name",
		{
			"Sponge With Wizard Hat"
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
					"The sponge creates electrical discharges, exploding enemies on fire.",
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
		"name",
		{
			"Doggie Chow"
		}
	},
	{
		"area",
		{
			{
				"bullet",
				{
					"Friends do 20% more damage."
				}
			}
		}
	}
}

items.quacker = {
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
					"Ducks who eat toast will ignite, making them faster."
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

items.blue_plasmid = {
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
	}
}

items.empty_jar = {
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
					20
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
					15
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
			}
		}
	}
}


items.wyrm = {
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

-- more entries here
local result_m = love.timer.getTime() - start_m
print(string.format("Item data loaded in %.3f milliseconds!", result_m * 1000))
return items