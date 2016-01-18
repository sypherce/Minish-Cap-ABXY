--Static Values

local static = {
	-- 02000095 current start menu page, 0 = items
	-- 02034491 start page, use indicator instead
	-- 020344a4 start indicator 00 or 0E when not in start menu, start page when in menu
	-- 030010D0 start menu open, 1 = true, use indicator instead
	MENU_STATUS_UNOPENED = 0x00,
	MENU_STATUS_ITEMS = 0x01,
	MENU_STATUS_QUEST_STATUS = 0x02,
	MENU_STATUS_MAP = 0x04,
	MENU_STATUS_CLOSED = 0x0e,

	ACTIVE_ITEM_NIL = 0,
	ACTIVE_ITEM_X = 1,
	ACTIVE_ITEM_Y = 2,
	ACTIVE_ITEM_R = 3,
	
	INVENTORY_SAVE_POS = 16,

	INVENTORY_ID = {-- Inventory Selected Item IDs
		NONE = 0x00,
		SWORD_1 = 0x01,
		SWORD_2 = 0x02,
		SWORD_3 = 0x03,
		SWORD_4 = 0x04,
		SWORD_5 = 0x06,
		BOMB_1 = 0x07,
		BOMB_2 = 0x08,
		BOW_1 = 0x09,
		BOW_2 = 0x0a,
		BOOMERANG_1 = 0x0b,
		BOOMERANG_2 = 0x0c,
		SHEILD_1 = 0x0d,
		SHEILD_2 = 0x0e,
		LANTERN_1 = 0x0f,
		LANTERN_2 = 0x10,
		GUST_JAR = 0x11,
		MAGIC_STAFF = 0x12,
		CLAW = 0x13,
		WINGS = 0x14,
		BOOTS = 0x15,
		OCARINA = 0x17,
		BOTTLE = 0x1c
	},

	TILE_ID = {-- Sprite Tile IDs
		A_BUTTON = 0x100,
		B_BUTTON = 0x104,
		R_BUTTON_1 = 0x108,
		R_BUTTON_2 = 0x10a,
		R_TEXT_1 = 0x10e,
		R_TEXT_2 = 0x116,
		R_ITEM = 0x11a
	},	
}

-- Returning this module.
return static
