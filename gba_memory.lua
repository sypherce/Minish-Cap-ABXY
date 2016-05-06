local addr = require(base_folder .. "addresses")
local static = require(base_folder .. "static")

local gba_memory = {
}

memory.usememorydomain("Combined WRAM")

function ReadBits1_9(memoryPos)
	local Pos16Bit = memory.read_u16_le(memoryPos)
	--digits 1-9              xxxxxxx987654321
	local And9Bits = tonumber(0000000111111111, 2)
	Pos16Bit = bit.band(Pos16Bit, And9Bits)
	return Pos16Bit
end

function gba_memory.GBASpritePosXRead(number)
	return ReadBits1_9(addr.GBASpritePosX(number))
end

function gba_memory.GBASpritePosYRead(number)
	return memory.read_s8(addr.GBASpritePosY(number))
end

-- no value checking, negatives may not work
function gba_memory.GBASpritePosXWrite(sprite, value)
	if (value >= 0) and (value <= 255) then
		memory.writebyte(addr.GBASpritePosX(sprite), value)
	else
		DebugLog("Invalid GBASpritePosXWrite Value ".. value .. ", (band) " .. bit.band(value, 255))
		memory.writebyte(addr.GBASpritePosX(sprite), bit.band(value, 255))
	end
end
-- no value checking, negatives may not work
function gba_memory.GBASpritePosYWrite(sprite, value)
	memory.writebyte(addr.GBASpritePosY(sprite), value)
end

function gba_memory.ReadMenuItem(number)
	return memory.readbyte(addr.item_pos_base + number)
end

function gba_memory.ReadGBASpriteID(tile_number)
	if(tile_number <0) and (tile_number > 1023) then
		DebugLog("ReadGBASpriteID: Invalid Tile Number " .. tile_number)
		return nil 
	end
	return ReadBits1_9(addr.GBASpriteID(tile_number))
end

function gba_memory.ReadSpriteByTile(tile_number, id_start, id_end)
	id_start = id_start or 0
	id_end = id_end or 1023
	for i=id_start,id_end do 
		if(gba_memory.ReadGBASpriteID(i) == tile_number) then
			return i
		end
	end
	--DebugLog("ReadSpriteByTile: Tile not found")
	return nil
end

--[[ not currently used
function gba_memory.FindSpriteAtXY(x, y)
	for i=0,127 do 
		if(GBASpritePosYRead(i) == y) then
			if(GBASpritePosXRead(i) == x) then
				return i
			end
		end
	end
end

function gba_memory.FindSpriteAtY(y)
	for i=0,127 do 
		if(GBASpritePosYRead(i) == y) then
			return i
		end
	end
end
]]--

function gba_memory.HideSprite(number)
	local sprite_address = addr.GBASprite(number)
	if (sprite_address ~= nil) then--this may have been coming up nil before.
		local sprite_data = memory.read_u16_le(sprite_address)
		sprite_data = bit.set(sprite_data, 9)
		memory.write_u16_le(sprite_address, sprite_data)
	else
		DebugLog("HideSprite: Sprite not found #" .. number)
	end
end

function gba_memory.SetItemCursor(value)
	memory.writebyte(addr.item_cursor, value)
	return value
end

function gba_memory.ItemsMenuActive()
	local current_start_page = memory.readbyte(addr.menu_state)
	if (current_start_page == static.MENU_STATUS_ITEMS) then
		return true
	elseif (current_start_page == static.MENU_STATUS_QUEST_STATUS 
	or current_start_page == static.MENU_STATUS_MAP) then
		local start_page_changing = memory.readbyte(addr.start_page_changing);
		if(start_page_changing == 0) then
			return true
		end
	else
	end

	return false
end
function gba_memory.ItemsMenuDeactivating()
	local temp_items_or_world = memory.readbyte(addr.temp_items_or_world)
	if(temp_items_or_world == 2 or temp_items_or_world == 3) then
		return true
	end

	return false
end

function gba_memory.MenuActive()
	local value_menu_state = memory.readbyte(addr.menu_state)
	if (value_menu_state ~= static.MENU_STATUS_INIT)
	and (value_menu_state ~= static.MENU_STATUS_CLOSED) then
		return true
	end

	return false
end

function gba_memory.MenuHasBeenActive()
	local value_menu_state = memory.readbyte(addr.menu_state)
	if (value_menu_state ~= static.MENU_STATUS_UNOPENED) then
		return true
	end

	return false
end

--handle the item cursor and stop from selecting the shield, sword, or boots
--TODO: when we handle the dpad this function probably will change a lot
--TODO: we also will get rid of `ItemCursor` and just read from `gba_memory`
local ItemCursor = -1
function gba_memory.handleItemCursor()
	if (gba_memory.ItemsMenuActive()) then
		local PreviousCursor = ItemCursor
		ItemCursor = memory.readbyte(addr.item_cursor)
		if (PreviousCursor == -1) then
			ItemCursor = gba_memory.SetItemCursor(1)
		elseif(ItemCursor == 0) then
			if(PreviousCursor == 1) then
				ItemCursor = gba_memory.SetItemCursor(3)
			elseif(PreviousCursor == 3) then
				ItemCursor = gba_memory.SetItemCursor(1)
			elseif(PreviousCursor == 12) then
				ItemCursor = gba_memory.SetItemCursor(12)
			end
		elseif(ItemCursor == 4) then
			if(PreviousCursor == 5) then
				ItemCursor = gba_memory.SetItemCursor(7)
			elseif(PreviousCursor == 7) then
				ItemCursor = gba_memory.SetItemCursor(5)
			end
		elseif(ItemCursor == 8) then
			if(PreviousCursor == 9) then
				ItemCursor = gba_memory.SetItemCursor(11)
			elseif(PreviousCursor == 11) then
				ItemCursor = gba_memory.SetItemCursor(9)
			elseif(PreviousCursor == 12) then
				ItemCursor = gba_memory.SetItemCursor(12)
			end
		end
	end
	return ItemCursor
end

function gba_memory.GetSelectedItem()
	if (gba_memory.MenuActive()) then -- menus
		if(gba_memory.ItemsMenuActive()) then -- item menu
			return gba_memory.ReadMenuItem(ItemCursor)
		end
	end
	return static.INVENTORY_ID.NONE
end

function gba_memory.DialogActive()
	if ((memory.readbyte(addr.dialog_active) == 1) and (gba_memory.MenuActive() == false)) then
		return true
	else
		return false
	end
end

-- Returning this module.
return gba_memory
