
local addr = {

	inventory_0 = 0x2b32,
	inventory_1 = 0x2b33,
	inventory_2 = 0x2b34,
	inventory_3 = 0x2b35,
	inventory_4 = 0x2b36,
	inventory_5 = 0x2b37,
	inventory_bottles = 0x2b39,
	inventory_bottle_1 = 0x2AF6,-- bottle contents
	inventory_bottle_2 = 0x2AF7,-- bottle contents
	inventory_bottle_3 = 0x2AF8,-- bottle contents
	inventory_bottle_4 = 0x2AF9,-- bottle contents

	bomb_count = 0x2aec,
	arrow_count = 0x2aed,
	bomb_max = 0x2aee,
	arrow_max = 0x2aef,

	dialog_active	= 0x36a39,

	-- 02002AF4 current (A) item
	current_item_1 = 0x2AF4,

	-- 02002AF5 current (B) item
	current_item_2 = 0x2AF5,

	gba_sprite_base = 0x040020,

	-- 02000090 = item pos 0
	item_pos_base = 0x0090, -- 0(90)>15(9f)

	-- 02000083 item cursor position 0-15, 16=save
	item_cursor = 0x0083,

	-- 02000095 current start menu page, 0 = items
	-- 030010D0 start menu open, 1 = true, use indicator instead

	-- 020344a4 start indicator 00 or 0E when not in start menu, start page when in menu
	menu_state = 0x0344a4,
	-- 02034491 start page, use indicator instead
	start_page = 0x034491,

	temp_items_or_world = 0x032ec0, -- 2,3 = items
	going_to_menu = 0x032ec2, -- 1 = true
}

function addr.GBASprite(number)
	if (number == nil) then return nil end
	return addr.gba_sprite_base + (number * 8)
end

function addr.GBASpriteID(number)
	return addr.GBASprite(number) + 4
end

function addr.GBASpritePosX(number)
	return addr.GBASprite(number) + 2
end

function addr.GBASpritePosY(number)
	return addr.GBASprite(number)
end

-- Returning this module.
return addr
