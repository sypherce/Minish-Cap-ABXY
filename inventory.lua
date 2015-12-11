
local inventory = {
	PauseMenu = bit.lshift(1, 0),
	SmithsSword = bit.lshift(1, 2),
	WhiteSword = bit.lshift(1, 4),
	WhiteSword2 = bit.lshift(1, 6),

	WhiteSword3 = bit.lshift(1, 0),
	SwordLamp = bit.lshift(1, 2),
	FourSword = bit.lshift(1, 4),
	Bombs = bit.lshift(1, 6),

	RemoteBombs = bit.lshift(1, 0),
	Bow = bit.lshift(1, 2),
	Bow2 = bit.lshift(1, 4),
	Boomerang = bit.lshift(1, 6),

	Boomerang2 = bit.lshift(1, 0),
	Shield = bit.lshift(1, 2),
	MirrorShield = bit.lshift(1, 4),
	Lamp = bit.lshift(1, 6),

	Lamp2 = bit.lshift(1, 0),
	GustJar = bit.lshift(1, 2),
	CaneOfPacci = bit.lshift(1, 4),
	MoleMitts = bit.lshift(1, 6),

	RocsCape = bit.lshift(1, 0),
	PegasusBoots = bit.lshift(1, 2),
	Unknown = bit.lshift(1, 4),
	Ocarina = bit.lshift(1, 6),
}

function inventory.check(number, item)
	local address = number + addr.inventory_0
	if(address >= addr.inventory_0 and address <= addr.inventory_5)then
		local inventory_data = memory.readbyte(address)
		inventory_data = bit.band(item, inventory_data)
		return inventory_data
	else
		return nil
	end
end

function inventory.HasBoots()
	local has_boots
	has_boots = inventory.check(5, inventory.PegasusBoots)
	if(has_boots ~= 0) then
		return static.INVENTORY_ID.BOOTS
	end
	return static.INVENTORY_ID.NONE
end
function inventory.HasSheild()
	local has_sheild
	has_sheild = inventory.check(3, inventory.MirrorShield)
	if(has_sheild ~= 0) then
		return static.INVENTORY_ID.SHEILD_2
	end
	has_sheild = inventory.check(3, inventory.Shield)
	if(has_sheild ~= 0) then
		return static.INVENTORY_ID.SHEILD_1
	end
	return static.INVENTORY_ID.NONE
end
function inventory.HasSword()
	local has_sword
	has_sword = inventory.check(1, inventory.FourSword)
	if(has_sword ~= 0) then
		return static.INVENTORY_ID.SWORD_5
	end
	has_sword = inventory.check(1, inventory.WhiteSword3)
	if(has_sword ~= 0) then
		return static.INVENTORY_ID.SWORD_4
	end
	has_sword = inventory.check(0, inventory.WhiteSword2)
	if(has_sword ~= 0) then
		return static.INVENTORY_ID.SWORD_3
	end
	has_sword = inventory.check(0, inventory.WhiteSword)
	if(has_sword ~= 0) then
		return static.INVENTORY_ID.SWORD_2
	end
	has_sword = inventory.check(0, inventory.SmithsSword)
	if(has_sword ~= 0) then
		return static.INVENTORY_ID.SWORD_1
	end
	return static.INVENTORY_ID.NONE
end

function inventory.GetBombCount()
	return memory.readbyte(addr.bomb_count)
end

function inventory.GetArrowCount()
	return memory.readbyte(addr.arrow_count)
end

function inventory.GetMaxBombs()
	local bomb_max = memory.readbyte(addr.bomb_max)
	if (bomb_max == 0) then
		return 10
	elseif (bomb_max == 1) then
		return 30
	elseif (bomb_max == 2) then
		return 50
	end
	--bomb_max == 3, or higher just in case
	return 99
end

function inventory.GetMaxArrows()
	local arrow_max = memory.readbyte(addr.arrow_max)
	if (arrow_max == 0) then
		return 30
	elseif (arrow_max == 1) then
		return 50
	elseif (arrow_max == 2) then
		return 70
	end
	--arrow_max == 3, or higher just in case
	return 99
end

function inventory.GetCurrentItem(slot)
	if (slot == 1) then
		return memory.readbyte(addr.current_item_1)
	elseif (slot == 2) then
		return memory.readbyte(addr.current_item_2)
	else
		DebugLog("GetCurrentItem: Invalid Slot #" .. slot)
		return nil
	end
end

local previous_item = 0--MOVED THIS OUT OF THE FUNCTION HOPING IT'D FIX THE LANTERN ISSUE
function inventory.SetCurrentItem(slot, item)
	local addr_current_item = nil
	if (slot == 1) then
		addr_current_item = addr.current_item_1
	elseif (slot == 2) then
		addr_current_item = addr.current_item_2
	else
		DebugLog("SetCurrentItem: Invalid Slot #" .. slot)
	end

	if(addr_current_item ~= nil) then
		previous_item = inventory.GetCurrentItem(slot)
		if (((previous_item == static.INVENTORY_ID.LANTERN_1) or (previous_item == static.INVENTORY_ID.LANTERN_2)) and (item == static.INVENTORY_ID.LANTERN_1)) then
			memory.writebyte(addr_current_item, static.INVENTORY_ID.LANTERN_2)
		else
			memory.writebyte(addr_current_item, item)
		end
	end
end

-- Returning this module.
return inventory
