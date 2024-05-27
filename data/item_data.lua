-- access player stats here
local start_m = love.timer.getTime()

items = {}

items.STAT_CATEGORIES = {
	attack_damage = "attack_damage",
	max_health = "max_health",
	movement_speed = "movement_speed",
	armor = "armor",
	lil_gabbron = "lil_gabbron",
	pierce = "pierce",
	attack_speed = "attack_speed",
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
			"Equip to guarantee large amounts of bread along your path."
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
					"This surely can't be bad, right?"
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
		"slot",
		{
			{
				"bullet",
				{
					"Spawn a random item in your bag at the start of every zone."
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
					"Your attacks explode on hit, dealing an extra 25% of your total attack damage.",
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
					5
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
					5
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
			"It's fuzzy sometimes, smooth others."
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
					50
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
					25
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