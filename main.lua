require 'modules/error_explorer'
local anim8 = require ('modules/anim8')
local push = require ('modules/push')
local items = require("data/item_data")
local utils = require("modules/utils")
local shaders = require("data/shaders")
local text_engine = require("modules/text_engine")
love.graphics.setNewFont("font/PressStart2P.ttf", 8)
local font_box = love.graphics.newFont("font/cozette.ttf", 8)

-- global variables
love.graphics.setDefaultFilter("nearest", "nearest")

local window_width, window_height = love.window.getDesktopDimensions()
local game_width, game_height = 960, 540
local window_scale = window_width/game_width
push:setupScreen(game_width, game_height, window_width, window_height, {windowed = true})

math.randomseed(os.time())



local GRAPHICS = {
	inventory = love.graphics.newImage("sprites/inventory/inv2.png"),
	slot1 = love.graphics.newImage("sprites/inventory/slot1.png"),
	area2 = love.graphics.newImage("sprites/inventory/area2.png"),
	bigslot1 = love.graphics.newImage("sprites/inventory/bigslot1.png"),
	bigslot2 = love.graphics.newImage("sprites/inventory/bigslot2.png"),
	charbox2 = love.graphics.newImage("sprites/inventory/charbox2.png"),
	selector = love.graphics.newImage("sprites/inventory/selector.png"),
	hover = love.graphics.newImage("sprites/inventory/hover.png"),
}

local GRAPHICS_DATA = {
	inventory = love.image.newImageData("sprites/inventory/inv2.png"),
	slot1 = love.image.newImageData("sprites/inventory/slot1.png"),
	area2 = love.image.newImageData("sprites/inventory/area2.png"),
	bigslot1 = love.image.newImageData("sprites/inventory/bigslot1.png"),
	bigslot2 = love.image.newImageData("sprites/inventory/bigslot2.png"),
	charbox2 = love.image.newImageData("sprites/inventory/charbox2.png"),
	selector = love.image.newImageData("sprites/inventory/selector.png"),
	hover = love.image.newImageData("sprites/inventory/hover.png"),
}

local DATA_TEXT_COLORS = {
	name = utils.get_color_table_from_rgb(255, 255, 255),
	lore = utils.get_color_table_from_rgb(113, 216, 101),
	note = utils.get_color_table_from_rgb(122, 122, 122),
	big_slot = utils.get_color_table_from_rgb(234, 124, 7),
	slot = utils.get_color_table_from_rgb(66, 204, 16),
	area = utils.get_color_table_from_rgb(55, 162, 239),
	attack_damage = utils.get_color_table_from_rgb(255, 255, 255),
	number = utils.get_color_table_from_rgb(255, 255, 255),
	description = utils.get_color_table_from_rgb(111, 147, 237),
}

local GLOBAL_ITEMS = {
	-- all items must receive uuid and data upon creation
	smorc_skull = love.graphics.newImage("sprites/items/smorc_skull.png"),
	mangic_ingot = love.graphics.newImage("sprites/items/mangic_ingot.png"),
	personal_wormhole = love.graphics.newImage("sprites/items/personal_wormhole.png"),
	ring_of_barley = love.graphics.newImage("sprites/items/ring_of_barley.png"),
	blast_gem = love.graphics.newImage("sprites/items/blast_gem.png"),
	weezt_bulb = love.graphics.newImage("sprites/items/weezt_bulb.png"),
	lil_gabbron = love.graphics.newImage("sprites/items/lil_gabbron.png"),
	jugg_milk_carton = love.graphics.newImage("sprites/items/jugg_milk_carton.png"),
	pink_plasmid = love.graphics.newImage("sprites/items/pink_plasmid.png"),
	blue_plasmid = love.graphics.newImage("sprites/items/blue_plasmid.png"),
	empty_jar = love.graphics.newImage("sprites/items/empty_jar.png"),
	jar_of_eyeballs = love.graphics.newImage("sprites/items/jar_of_eyeballs.png"),
	weird_mushroom = love.graphics.newImage("sprites/items/weird_mushroom.png"),
	wyrm = love.graphics.newImage("sprites/items/wyrm.png"),
	subpocket = love.graphics.newImage("sprites/items/subpocket.png"),
	wood_block = love.graphics.newImage("sprites/items/wood_block.png"),
	quacker = love.graphics.newImage("sprites/items/quacker.png"),
	toaster = love.graphics.newImage("sprites/items/toaster.png"),
	placeholder = love.graphics.newImage("sprites/items/wood_block.png"),
}

function create_item(id, x, y, data)
	local item = {}
	item.image = GLOBAL_ITEMS[id]
	item.x = x
	item.y = y
	item.snap_x = x
	item.snap_y = y
	item.storage_x = x
	item.storage_y = y
	item.uuid = utils.uuid()
	item.slot_uuid = nil
	item.data = data
	return item
end

function create_slot(id, x, y, xoff, yoff, mode)
	local slot = {}
	slot.uuid = utils.uuid()
	slot.x = x
	slot.y = y
	slot.xoff = xoff
	slot.yoff = yoff
	slot.id = id
	slot.mode = mode
	return slot
end

function create_particle(x, y, dx, dy, color)
	local particle = {}
	particle.x = x
	particle.y = y
	particle.dx = dx
	particle.dy = dy
	particle.seed = math.random()
	particle.timer = 0
	particle.color = color or {1, 1, 1, 1}
	return particle
end

function create_shockwave(x, y, dx, dy, r, dr, color)
	local shockwave = {}
	shockwave.x = x
	shockwave.y = y
	shockwave.dx = dx
	shockwave.dy = dy
	shockwave.r = r
	shockwave.dr = dr
	shockwave.seed = math.random()
	shockwave.timer = 0
	shockwave.color = color or {1, 1, 1, 0.5}
	return shockwave
end

---------------------------------------------------------

-- player inventory origin coordinates
p_inv_x = 200
p_inv_y = 100
-- display box origin coordinates
d_box = {
	x = 0,
	y = 0,
	w = 0,
	h = 0,
	text = {},
}
-- essential for logic
held_item_uuid = nil
hover_item_uuid = nil

local player_inventory = {
	{ uuid=utils.uuid(), x=p_inv_x, y=p_inv_y, xoff=0, yoff=0, id="inventory", mode="nonfunctional" },
	{ uuid=utils.uuid(), x=p_inv_x+85, y=p_inv_y+8, xoff=85, yoff=8,  id="charbox2", mode="nonfunctional" }, 
	{ uuid=utils.uuid(), x=p_inv_x+149, y=p_inv_y+8, xoff=149, yoff=8, id="bigslot2", mode="big_slot", }, 
	{ uuid=utils.uuid(), xoff=197, yoff=8, id="bigslot1", mode="big_slot", },
	{ uuid=utils.uuid(), x=p_inv_x+149, y=p_inv_y+56, xoff=149, yoff=56, id="slot1", mode="slot", },
	{ uuid=utils.uuid(), x=p_inv_x+173, y=p_inv_y+56, xoff=173, yoff=56, id="slot1", mode="slot", }, 
	{ uuid=utils.uuid(), x=p_inv_x+197, y=p_inv_y+56, xoff=197, yoff=56, id="slot1", mode="slot", }, 
	{ uuid=utils.uuid(), x=p_inv_x+221, y=p_inv_y+56, xoff=221, yoff=56, id="slot1", mode="slot", },
	{ uuid=utils.uuid(), x=p_inv_x+83, y=p_inv_y+87, xoff=83, yoff=87, id="area2", mode="area", },
}

-- items in player inventory
local bagged_items = {

}

-- items in other inventory
local foreign_items = {

}

-- array of arrays
local loaded_objects = {
	ui = {},
}

local particles = {}
local shockwaves = {}


function love.load()
	text_engine.initialize_box_data(game_width, game_height)

	table.insert(bagged_items, create_item("smorc_skull", 700, 120, items.smorc_skull))
	table.insert(bagged_items, create_item("mangic_ingot", 720, 120, items.mangic_ingot))
	table.insert(bagged_items, create_item("weezt_bulb", 740, 120, items.weezt_bulb))
	table.insert(bagged_items, create_item("ring_of_barley", 820, 100, items.ring_of_barley))
	table.insert(bagged_items, create_item("personal_wormhole", 700, 140, items.personal_wormhole))
	table.insert(bagged_items, create_item("blast_gem", 720, 140, items.blast_gem))
	table.insert(bagged_items, create_item("lil_gabbron", 720, 160, items.lil_gabbron))
	table.insert(bagged_items, create_item("jugg_milk_carton", 720, 180, items.jugg_milk_carton))
	table.insert(bagged_items, create_item("pink_plasmid", 720, 200, items.pink_plasmid))
	table.insert(bagged_items, create_item("blue_plasmid", 740, 200, items.blue_plasmid))
	table.insert(bagged_items, create_item("empty_jar", 780, 120, items.empty_jar))
	table.insert(bagged_items, create_item("jar_of_eyeballs", 780, 140, items.jar_of_eyeballs))
	table.insert(bagged_items, create_item("weird_mushroom", 760, 100, items.weird_mushroom))
	table.insert(bagged_items, create_item("wyrm", 740, 100, items.wyrm))
	table.insert(bagged_items, create_item("subpocket", 720, 100, items.subpocket))
	table.insert(bagged_items, create_item("wood_block", 800, 100, items.wood_block))
	table.insert(bagged_items, create_item("quacker", 820, 120, items.quacker))
	table.insert(bagged_items, create_item("toaster", 820, 140, items.toaster))
	table.insert(bagged_items, create_item("placeholder", 800, 40, items.sponge_with_wizard_hat))
end

function love.mousepressed(x, y, button, istouch, presses)
	local c_x = x / window_scale
	local c_y = y / window_scale
	if hover_item_uuid then return end
	for i = #player_inventory, 1, -1 do
		local slot = player_inventory[i]
		local graphic = GRAPHICS[slot.id]
		if utils.get_point_collision(c_x, c_y, slot.x, slot.y, graphic:getWidth(), graphic:getHeight()) then
			local multiplier = 1
			local imgdata = GRAPHICS_DATA[slot.id] -- this is necessary for finding the pixel color
			local r, g, b, a = imgdata:getPixel(c_x - slot.x, c_y - slot.y)
			if presses > 10 then
					multiplier = multiplier * 25
			end
			for i = 1, math.random(5 * multiplier) do
				local particle = create_particle(c_x, c_y, math.random() * 200 - 100, math.random() * 200 - 100, {r + 0.3, g + 0.3, b + 0.3, a})
				particle.timer = math.random() - 0.5
				table.insert(particles, particle)
			end
			
			break
		end
		
	end
end

function love.update(dt)
	send_shit_to_shaders()
	fps = love.timer.getFPS()
	m_x = love.mouse.getX() / window_scale
	m_y = love.mouse.getY() / window_scale
	update_inventory_coords()
	update_item_coords()
	
	
	-- get mouse hover
	for i = 1, #bagged_items do
		local item = bagged_items[i]
		hover_item_uuid = nil
		if utils.get_point_collision(m_x, m_y, item.x, item.y, item.image:getWidth(), item.image:getHeight()) then
			hover_item_uuid = item.uuid
			break
		end

	end

	-- on mouse hover over item, update display box coordinates and metadata
	if hover_item_uuid then
		--text_engine.update_box_coords(m_x, m_y)
		d_box.x = m_x
		d_box.y = m_y
		local i = nil
		local s = "nil"
		for _, item in ipairs(bagged_items) do
			if item.uuid == hover_item_uuid then
				i = item
			end
		end
		for _, slot in ipairs(player_inventory) do
			if i.slot_uuid == slot.uuid then
				s = slot
			end
		end
		
		text_engine.update_box(d_box, i, s, m_x, m_y)
	end

	if love.mouse.isDown(1) then
		hold_item()
		hover_item_uuid = nil
	else
		love.mouse.setVisible(true)
		held_item_uuid = nil
	end
	
	if love.keyboard.isDown('left') then
		p_inv_x = p_inv_x - 70 * dt
	end
	if love.keyboard.isDown('right') then
		p_inv_x = p_inv_x + 70 * dt
	end
	if love.keyboard.isDown('up') then
		p_inv_y = p_inv_y - 70 * dt
	end
	if love.keyboard.isDown('down') then
		p_inv_y = p_inv_y + 70 * dt
	end

	for i = #particles, 1, -1  do
		local particle = particles[i]
		particle.x = particle.x + particle.dx * dt
		particle.y = particle.y + particle.dy * dt
		particle.timer = particle.timer + dt
		particle.color[4] = particle.color[4] - 1 * dt
		if particle.timer > 1 then
			table.remove(particles, i)
		end
	end

	for i = #shockwaves, 1, -1  do
		local shockwave = shockwaves[i]
		shockwave.x = shockwave.x + shockwave.dx * dt
		shockwave.y = shockwave.y + shockwave.dy * dt
		shockwave.r = shockwave.r + shockwave.dr * dt
		shockwave.timer = shockwave.timer + dt
		shockwave.color[4] = shockwave.color[4] - 1 * dt
		if shockwave.timer > 1 then
			table.remove(shockwaves, i)
		end
	end
end



function love.draw()
	push:start()
		love.graphics.print(fps, 0, 0)
		love.graphics.print(m_x, 0, 12)
		love.graphics.print(m_y, 50, 12)
		love.graphics.print(tostring(held_item_uuid), 0, 24)
		love.graphics.print(tostring(hover_item_uuid), 0, 48)

		local id = nil
		if held_item_uuid then
			for i = 1, #bagged_items do
				if bagged_items[i].uuid == held_item_uuid then
					id = bagged_items[i].slot_uuid
				end
			end
		end
		love.graphics.print(tostring(id), 0, 36)
		draw_player_inventory()
		


		-- if item is being held, then render it on top of inventory (instead of in between it) and scale it up a bit for AESTHETIC
		for i = 1, #bagged_items do
			local item = bagged_items[i]
			if item.uuid == held_item_uuid then
				love.graphics.draw(item.image, math.floor(item.x) - 3, math.floor(item.y) - 3, 0, 1.35, 1.35)
			elseif not item.slot_uuid then
				love.graphics.draw(item.image, math.floor(item.x), math.floor(item.y))
			end
		end

		-- render item data display box if applicable
		if hover_item_uuid and not held_item_uuid then
			text_engine.render_box(d_box)
		end

		for _, particle in ipairs(particles) do
			love.graphics.setColor(unpack(particle.color))
			love.graphics.circle('fill', math.floor(particle.x), math.floor(particle.y), 1)
			love.graphics.setColor(1, 1, 1, 1)
		end
		for _, shockwave in ipairs(shockwaves) do
			love.graphics.setColor(unpack(shockwave.color))
			love.graphics.circle('line', math.floor(shockwave.x), math.floor(shockwave.y), math.floor(shockwave.r))
			love.graphics.setColor(1, 1, 1, 1)
		end
		
	push:finish()
end

function love.mousereleased(x, y, button)
	local function handle_item_in_slot(i)
		-- this should only be called on lmb release
		local slot_occupied = false
		local slot = player_inventory[i]
		local graphic = GRAPHICS[slot.id]
		if not utils.get_point_collision(m_x, m_y, slot.x, slot.y, graphic:getWidth(), graphic:getHeight()) then return false end
		for _, item in pairs(bagged_items) do
			if item.uuid == held_item_uuid then
				-- do different behaviors based on which type of slot the item is inserted in
				-- item origin positions (ox and oy) will have to be set to values based on the inventory's origin coordinates
				if slot.mode == "area" then
					print(item.uuid .. ": area")
					item.slot_uuid = slot.uuid
				elseif slot.mode == "slot" or slot.mode == "big_slot" then
					print(item.uuid .. ": slot")
					for i = 1, #bagged_items do
						if bagged_items[i].slot_uuid == slot.uuid and bagged_items[i].uuid ~= item.uuid then 
							slot_occupied = true 
						end
					end
					if not slot_occupied then
						item.x = slot.x + (graphic:getWidth() - item.image:getWidth()) / 2
		 				item.y = slot.y + (graphic:getHeight() - item.image:getHeight()) / 2
						item.slot_uuid = slot.uuid
					end
				end
				if slot_occupied then
					item.x = item.storage_x + p_inv_x
					item.y = item.storage_y + p_inv_y
				else
					item.snap_x = item.x - p_inv_x
					item.snap_y = item.y - p_inv_y
					item.storage_x = item.x - p_inv_x
					item.storage_y = item.y - p_inv_y
				end
				return true
			end
		end
		return false
	end

	local function handle_item_out_of_bounds()
		-- this should only be called on lmb release
		local out_of_bounds = true
		local slotted = false
		local uuid = nil
		-- first, detect if item placed out of bounds
		for i = 1, #bagged_items do
			local item = bagged_items[i]
			if item.uuid == held_item_uuid then
				uuid = item.uuid
				for j = #player_inventory, 1, -1 do
					local slot = player_inventory[j]
					local graphic = GRAPHICS[slot.id]
					if utils.get_point_collision(m_x, m_y, slot.x, slot.y, graphic:getWidth(), graphic:getHeight()) then
						out_of_bounds = false
						if slot.mode == items.SLOT_CATEGORIES[slot.mode] then
							slotted = true
						end
						break
					end
				end
				if slotted or not out_of_bounds then break end
			end
		end

		-- take action if item placed out of bounds
		if out_of_bounds then
			print(uuid .. ": out of bounds")
			for i = 1, #bagged_items do
				local item = bagged_items[i]
				if item.uuid == held_item_uuid then
					item.slot_uuid = nil
				end
			end
			return true
		end

		-- take action if item placed within inventory bounds, but in an invalid spot
		if not slotted then
			local slot_mode = nil
			print(uuid .. ": no slot")
			for i = 1, #bagged_items do
				local item = bagged_items[i]
				if item.uuid == held_item_uuid then
					-- zip item back to its last place
					if not item.slot_uuid then
						item.snap_x = 0
						item.snap_y = 0
					else
						item.x = item.storage_x + p_inv_x
						item.y = item.storage_y + p_inv_y
					end
				end
			end
			return true
		end
		return false
	end

	-- if item not placed out of bounds, take action for specific slot types
	-- loop through inventory backwards because we don't want to have behavior on the inventory background first
	if button == 1 and held_item_uuid then
		if handle_item_out_of_bounds() then return end
		for i = #player_inventory, 1, -1 do
			if handle_item_in_slot(i) then break end
		end
	end
end

function send_shit_to_shaders()
    -- this has to be called within update function
    shaders.rainbow_shader:send("time", love.timer.getTime() * 50)
    shaders.scrolling_rainbow_shader:send("time", love.timer.getTime() * 50)
    shaders.demo_shader:send("screen", {game_width, game_height})
end

function hold_item()
	for i = 1, #bagged_items do
		local item = bagged_items[i]
		if utils.get_point_collision(m_x, m_y, item.x, item.y, item.image:getWidth(), item.image:getHeight()) and not held_item_uuid then
			held_item_uuid = item.uuid
			love.mouse.setVisible(false)
		end
	end

	for i = 1, #bagged_items do
		local item = bagged_items[i]
		if held_item_uuid == item.uuid then
			item.x = m_x - item.image:getWidth() / 2
			item.y = m_y - item.image:getHeight() / 2
		end
	end
end

function update_inventory_coords()
	for i = 1, #player_inventory do
		local entry = player_inventory[i]
		entry.x = p_inv_x + entry.xoff
		entry.y = p_inv_y + entry.yoff
	end
end

function update_item_coords()
	-- make item coords slot coords unless picked up
	-- area will need special code
	for i = 1, #bagged_items do
		local item = bagged_items[i]
		if item.slot_uuid then
			for j = 1, #player_inventory do
				local slot = player_inventory[j]
				if slot.uuid == item.slot_uuid then
					item.snap_x = slot.x - p_inv_x
					item.snap_y = slot.y - p_inv_y
				end
			end
		end
		if item.slot_uuid and item.uuid ~= held_item_uuid then
			-- make sure the item is aligned correctly in the right slot
			item.x = item.storage_x + p_inv_x
			item.y = item.storage_y + p_inv_y
		end
	end
end

function draw_player_inventory()
	for _, slot in ipairs(player_inventory) do
		local graphic = GRAPHICS[slot.id]
		if not graphic then
			error("graphic id does not match!!!")
		end

		love.graphics.draw(graphic, math.floor(slot.x), math.floor(slot.y))

		if utils.get_point_collision(m_x, m_y, slot.x, slot.y, graphic:getWidth(), graphic:getHeight()) then
			local hover
			love.graphics.setColor(255, 255, 255, 0.35)
			if slot.mode == "area" and not held_item_uuid then
				hover = GRAPHICS["hover"]
				love.graphics.draw(hover, math.floor(m_x - hover:getWidth() / 2), math.floor(m_y - hover:getHeight() / 2))
			elseif slot.mode == "slot" or slot.mode == "big_slot" then
				hover = GRAPHICS["selector"]
				love.graphics.draw(hover, math.floor(slot.x + 1), math.floor(slot.y + 1), 0, graphic:getWidth() / (hover:getWidth() + 1), graphic:getHeight() / (hover:getHeight() + 1))
			end
			love.graphics.setColor(255, 255, 255, 1)
		end
	end

	-- i am now changing the bigslot mode adding it in :)
	-- make sure we are rendering items between inventory boxes and shell
	for i = #bagged_items, 1, -1 do
		local item = bagged_items[i]
		if item.uuid ~= held_item_uuid then
			for j = 1, #player_inventory do
				local slot = player_inventory[j]
				if slot.uuid == item.slot_uuid and (slot.mode == "big_slot") then
					love.graphics.draw(item.image, math.floor(item.x) - 10, math.floor(item.y) - 10, 0, 2, 2)
				elseif slot.uuid == item.slot_uuid then
					love.graphics.draw(item.image, math.floor(item.x), math.floor(item.y))
				end
			end
		end
	end
	love.graphics.draw(GRAPHICS["inventory"], math.floor(p_inv_x), math.floor(p_inv_y))
end

