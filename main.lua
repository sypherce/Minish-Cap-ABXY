--[[ TODO LIST
done - hide (extra button) sprites (sheild, sword, bomb)
done - detect proper shield, bow, boomerang, running shoes, etc
done - fix buttons on items screen (a, b should = x, y, r)
done -	fix selection highlighted items on items screen,
		separate and redraw sword, shoes, shield
		disable selection/highlight of b, l, zr items
done - setup numbers for bows similar to bombs
done - revamp hud similar to wind waker
done - detect max arrows and bombs - change text color when we have the max

started - fix hud transitions - it goes crazy when switching screens
started - save last known x y zr items to a file and load on start
		- this is done, but probably should be put into the save state instead

Deal with folder issues. probably should check if a file exists before accessed and display an error		
polish transitions in general - example: in the item screen you can see all the items before it draws the new stuff over the top
bottles, we only have a dummy sprite
lantern issues - doesn't come out without turning on immediately
polish code
]]--

-- relative folder - global variable
base_folder = "./Lua/MinishCap/"

--this clears out any #include that might be left in memory
package.loaded[base_folder .. "addresses"] = nil
package.loaded[base_folder .. "static"] = nil
package.loaded[base_folder .. "inventory"] = nil
package.loaded[base_folder .. "config"] = nil
package.loaded[base_folder .. "draw"] = nil
package.loaded[base_folder .. "gba_memory"] = nil
package.loaded[base_folder .. "save_data"] = nil

--#include
--local addr = require(base_folder .. "addresses")
local static = require(base_folder .. "static")
local inventory = require(base_folder .. "inventory")
local config = require(base_folder .. "config")
local draw = require(base_folder .. "draw")
local gba_memory = require(base_folder .. "gba_memory")
local save_data = require(base_folder .. "save_data")

local GamepadState = {-- Current Emulated Gamepad State
	KeyboardState = 0,
	a = 0,
	b = 0,
	x = 0,
	y = 0,
	l = 0,
	zl = 0,
	r = 0,
	zr = 0,
	Update = 0--function declaration follows...
}
GamepadState.Update = function () 
	GamepadState.KeyboardState = input.get()
	GamepadState.a = GamepadState.KeyboardState[config.a]
	GamepadState.b = GamepadState.KeyboardState[config.b]
	GamepadState.x = GamepadState.KeyboardState[config.x]
	GamepadState.y = GamepadState.KeyboardState[config.y]
	GamepadState.l = GamepadState.KeyboardState[config.l]
	GamepadState.zl = GamepadState.KeyboardState[config.zl]
	GamepadState.r = GamepadState.KeyboardState[config.r]
	GamepadState.zr = GamepadState.KeyboardState[config.zr]
end

function DebugLog(text)
	if (config.debug == true) then
		console.log(text)
	end
end

function SetItemValue(zr, x, y, new_value)
	if (new_value == static.INVENTORY_ID.NONE) then
		return zr, x, y
	elseif (zr == new_value) then
		if (x == new_value) then
			x = 0
		elseif (y == new_value) then
			y = 0
		end
	elseif (x == new_value) then
		x = zr
	elseif (y == new_value) then
		y = zr
	end
	zr = new_value
	return zr, x, y
end

--[[not currently used
function IsItemSelected(selected_item)
	return ((selected_item ~= static.INVENTORY_ID.NONE) and 
			(selected_item ~= static.INVENTORY_ID.SWORD_1) and
			(selected_item ~= static.INVENTORY_ID.SWORD_2) and
			(selected_item ~= static.INVENTORY_ID.SWORD_3) and
			(selected_item ~= static.INVENTORY_ID.SWORD_4) and
			(selected_item ~= static.INVENTORY_ID.SWORD_5) and
			(selected_item ~= static.INVENTORY_ID.SHEILD_1) and
			(selected_item ~= static.INVENTORY_ID.SHEILD_2) and
			(selected_item ~= static.INVENTORY_ID.BOOTS))
end]]--

do -- main()
	-- check what game is loaded, if it's not minish cap, wait for it
	console.clear()
	if (bizstring.startswith(gameinfo.getromname(), "Legend of Zelda, The - The Minish Cap") == false) then
		console.log("No game or wrong game loaded. Please try again.")
	end
	while (bizstring.startswith(gameinfo.getromname(), "Legend of Zelda, The - The Minish Cap") == false) do
		emu.frameadvance()
	end

	-- wait for main game
	--TODO: check this. we haven't checked it in a long time and we don't even jump into the start menu anymore	
	while (gba_memory.MenuHasBeenActive() == false) do
		local SpriteB = gba_memory.ReadSpriteByTile(static.TILE_ID.B_BUTTON)
		-- if the B sprite is visible, the start menu will work
		if (SpriteB ~= nil) then
			emu.frameadvance() -- advance a frame or the next part won't work
			--joypad.set({Start=1})
			break
		-- otherwise we function like normal
		else
			GamepadState.Update()
			joypad.set({A=GamepadState.a, B=GamepadState.b, L=GamepadState.l, R=GamepadState.r})
		end

		emu.frameadvance()
	end
	--load saved buttons before entering main loop
--	save_data.load_buttons()
	while (true) do--main loop
		GamepadState.Update()
		local ItemCursor = gba_memory.handleItemCursor()

		--set main buttons
		inventory.CurrentItem.b = inventory.HasSword()
		inventory.CurrentItem.l = inventory.HasBoots()
		inventory.CurrentItem.zr = inventory.HasSheild()

		--this part takes care of the juggle work between the extra virtual buttons and the real GBA buttons
		--we are basically setting up the data here, we'll press everything in the next section
		do--setup buttons
			--if the menus are running
			if (gba_memory.MenuActive()) then
				local SelectedItem = gba_memory.GetSelectedItem()
				if GamepadState.r == true then
					inventory.CurrentItem.r, inventory.CurrentItem.x, inventory.CurrentItem.y = SetItemValue(inventory.CurrentItem.r, inventory.CurrentItem.x, inventory.CurrentItem.y, SelectedItem)
				elseif GamepadState.x == true then
					inventory.CurrentItem.x, inventory.CurrentItem.r, inventory.CurrentItem.y = SetItemValue(inventory.CurrentItem.x, inventory.CurrentItem.r, inventory.CurrentItem.y, SelectedItem)
				elseif GamepadState.y == true then
					inventory.CurrentItem.y, inventory.CurrentItem.r, inventory.CurrentItem.x = SetItemValue(inventory.CurrentItem.y, inventory.CurrentItem.r, inventory.CurrentItem.x, SelectedItem)
				end
			--or if we're in the field
			else
				-- this fixes the sword not showing on the "B" button until used
				-- and the last used "A" item showing on "A"
				inventory.SetCurrentItem(1, 0)
				inventory.SetCurrentItem(2, inventory.CurrentItem.b)

				-- here we set the current item based on the `virtual gamepad` state
				-- A is the action key now so we can skip it
				-- B and ZL don't change, so we skip them too
				if (GamepadState.x == true) then
					inventory.SetCurrentItem(1, inventory.CurrentItem.x)
				elseif (GamepadState.y == true) then
					inventory.SetCurrentItem(1, inventory.CurrentItem.y)
				elseif (GamepadState.l == true) then
					inventory.SetCurrentItem(1, inventory.CurrentItem.l)
				elseif (GamepadState.r == true) then
					inventory.SetCurrentItem(1, inventory.CurrentItem.r)
				elseif (GamepadState.zr == true) then
					inventory.SetCurrentItem(1, inventory.CurrentItem.zr)
				end
			end
		end
		
		--now we can press buttons. this part checks where we are, and which virtual buttons are going to become real buttons
		do--press buttons 
			-- item menu is active
			if (gba_memory.ItemsMenuActive()) then
				-- L and R need to work like normal, ZR works like R here as well
				joypad.set({L=GamepadState.l or GamepadState.zl, R=GamepadState.zr})

				-- Let A button function on the save button
				if(ItemCursor == static.INVENTORY_SAVE_POS) then
					joypad.set({A=GamepadState.a})
						
					if(GamepadState.a) then	--TODO: this saves the button settings as soon as we reach
											--      the save menu, this needs to be changed to when we
											--      actually write the save data
						save_data.save_buttons()
					end						
				-- Otherwise select whatever item we're on with x y or r
				else
					joypad.set({A=(GamepadState.x or GamepadState.y or GamepadState.r)})
				end
			-- dialog is active OR any menu other than the items menu
			elseif (gba_memory.DialogActive() or gba_memory.MenuActive()) then
				--gamepad works like normal here, zr and zl work like l and r
				joypad.set({A=GamepadState.a, B=GamepadState.b, L=GamepadState.l or GamepadState.zl, R=GamepadState.r or GamepadState.zr})
			-- field controls
			else
				--basically the `virtual A` button becomes our action button
				--and all the item buttons run through the `gameboy A` button
				joypad.set(
					{R=GamepadState.a,		-- action
					 A=(GamepadState.x or	-- item
						GamepadState.y or	-- item
						GamepadState.l or	-- item
						GamepadState.r or	-- item
						GamepadState.zr),	-- item
					 B=GamepadState.b,		-- sword	
					 L=GamepadState.zl})	-- kinstones
			end
		end

		--finally we draw it all. there are a bunch of checks in the drawing functions as well
		do--draw
			if (gba_memory.MenuActive()) then -- menus
				if(gba_memory.ItemsMenuActive()) then -- item menu
					--draw items hud
					--all status checks are within this function
					draw.ItemsMenuHud()
				end
			elseif(gba_memory.ItemsMenuDeactivating()) then -- if we're exiting the menu
					draw.HideRealHudItems()	--keep hiding the hud
			elseif (gba_memory.DialogActive() == false) then
				--draw normal Hud
				--all status checks are within this function
				draw.Hud()
			end
		end
		emu.frameadvance()
	end
end
