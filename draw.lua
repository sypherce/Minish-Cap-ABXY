local addr = require(base_folder .. "addresses")
local static = require(base_folder .. "static")
local inventory = require(base_folder .. "inventory")
local gba_memory = require(base_folder .. "gba_memory")

local image_folder = base_folder .. "images/"

local Images = {
	[static.INVENTORY_ID.SWORD_1] = image_folder .. "sword0.png",
	[static.INVENTORY_ID.SWORD_2] = image_folder .. "sword1.png",
	[static.INVENTORY_ID.SWORD_3] = image_folder .. "sword2.png",
	[static.INVENTORY_ID.SWORD_4] = image_folder .. "sword3.png",
	[static.INVENTORY_ID.SWORD_5] = image_folder .. "sword4.png",
	[static.INVENTORY_ID.BOMB_1] = image_folder .. "bomb0.png",
	[static.INVENTORY_ID.BOMB_2] = image_folder .. "bomb1.png",
	[static.INVENTORY_ID.BOW_1] = image_folder .. "bow0.png",
	[static.INVENTORY_ID.BOW_2] = image_folder .. "bow1.png",
	[static.INVENTORY_ID.BOOMERANG_1] = image_folder .. "boomerang0.png",
	[static.INVENTORY_ID.BOOMERANG_2] = image_folder .. "boomerang1.png",
	[static.INVENTORY_ID.SHEILD_1] = image_folder .. "sheild0.png",
	[static.INVENTORY_ID.SHEILD_2] = image_folder .. "sheild1.png",
	[static.INVENTORY_ID.LANTERN_1] = image_folder .. "lantern.png",
	[static.INVENTORY_ID.LANTERN_2] = image_folder .. "lantern.png",
	[static.INVENTORY_ID.GUST_JAR] = image_folder .. "gustjar.png",
	[static.INVENTORY_ID.MAGIC_STAFF] = image_folder .. "cane.png",
	[static.INVENTORY_ID.CLAW] = image_folder .. "mitts.png",
	[static.INVENTORY_ID.WINGS] = image_folder .. "wings.png",
	[static.INVENTORY_ID.BOOTS] = image_folder .. "boots.png",
	[static.INVENTORY_ID.OCARINA] = image_folder .. "ocarina.png",
	[static.INVENTORY_ID.BOTTLE] = image_folder .. "bottle.png"
}
for i=0x00,0xff do if(Images[i] == nil) then Images[i]= image_folder .. "blank.png" end end

local draw = {
}

function draw.Digits(X, Y, Number, Max)
	if ((Number >= 0) and (Number <= 99)) then
		local max_string = ""
		if (Number >= Max) then
			max_string = "max"
		end
		X = X + 10
		Y = Y + 9
		local Digit2XOffset = 6
		local Digit1
		local Digit2
		if(Number <= 9)then
			Digit1 = "0"
			Digit2 = tostring(Number)
		else
			Digit1 = string.sub(tostring(Number), 1, 1)
			Digit2 = string.sub(tostring(Number), -1)
		end
			
		gui.drawImage(image_folder .. Digit1 .. max_string .. ".png", X,					Y)
		gui.drawImage(image_folder .. Digit2 .. max_string .. ".png", X + Digit2XOffset,	Y)
	end
end

local SavedBaseX = 0
local SavedBaseY = 0
function draw.Hud()
	local r_button_sprite_1 = gba_memory.ReadSpriteByTile(static.TILE_ID.R_BUTTON_1)
	local r_button_sprite_2 = gba_memory.ReadSpriteByTile(static.TILE_ID.R_BUTTON_2)
	if((r_button_sprite_1 ~= nil) and (r_button_sprite_2 ~= nil))then
				gba_memory.HideSprite(r_button_sprite_1)
				gba_memory.HideSprite(r_button_sprite_2)
				--TODO: this next `if` line was broken or rendered obsolete at one point. may have a bug here.
				--if(sword ~= static.INVENTORY_ID.NONE)then
				--r_button_sprite_1 = r_button_sprite_1 - 2
				--end 

				--this next part seems to help transitions
				local temp_items_or_world = memory.readbyte(addr.temp_items_or_world)
				LoopStart = 0
				LoopEnd = r_button_sprite_1 - 2
				if(temp_items_or_world ~= 2 and temp_items_or_world ~= 3) then
						local Pos = {
							BaseX		= 0,	BaseY		= 0,
							AButton_X	= 34,	AButton_Y	= 25,
							BButton_X	= 22,	BButton_Y	= 35,
							XButton_X	= 24,	XButton_Y	= 16,
							YButton_X	= 12,	YButton_Y	= 27,
							LButton_X	= 4,	LButton_Y	= 11,
							RButton_X	= 41,	RButton_Y	= 11,
							ZRButton_X	= 38,	ZRButton_Y	= 0,
						}
						Pos.AItem_X = Pos.AButton_X + 8 - 28
						Pos.AItem_Y = Pos.AButton_Y - 4
						
						Pos.BItem_X = Pos.BButton_X + 0
						Pos.BItem_Y = Pos.BButton_Y + 4
						
						Pos.LItem_X = Pos.LButton_X + 8
						Pos.LItem_Y = Pos.LButton_Y - 4

						Pos.RItem_X = Pos.RButton_X + 8
						Pos.RItem_Y = Pos.RButton_Y - 4
						
						Pos.XItem_X = Pos.XButton_X + 0
						Pos.XItem_Y = Pos.XButton_Y - 10 

						Pos.YItem_X = Pos.YButton_X - 8 
						Pos.YItem_Y = Pos.YButton_Y + 0 

						Pos.ZRItem_X = Pos.ZRButton_X - 8
						Pos.ZRItem_Y = Pos.ZRButton_Y - 4 
						
						local SpriteActionText1 = gba_memory.ReadSpriteByTile(static.TILE_ID.R_TEXT_1)
						local SpriteActionText2 = gba_memory.ReadSpriteByTile(static.TILE_ID.R_TEXT_2)
						local SpriteA = gba_memory.ReadSpriteByTile(static.TILE_ID.A_BUTTON)
						local SpriteB = gba_memory.ReadSpriteByTile(static.TILE_ID.B_BUTTON)

						local loading_menu = memory.readbyte(addr.going_to_menu)
						if(loading_menu == 0) then
							Pos.BaseX = gba_memory.GBASpritePosXRead(SpriteB) - 9
							
							--this next check keeps the screen from freaking out
							--at the end of the transition something weird happens
							--with the B sprite and in ram it jumps around for some reason
							--this probably could be fixed somehow but I'm not sure what's happening
							--so we get a hack :)
							if(Pos.BaseX ~= 169) then
								Pos.BaseX = SavedBaseX
								Pos.BaseY = SavedBaseY
							else
								Pos.BaseY = gba_memory.GBASpritePosYRead(SpriteB) - 18
								--[[debug
								if (Pos.BaseX ~= SavedBaseX) then
									console.log("BaseX " .. Pos.BaseX)
								end
								if (Pos.BaseY ~= SavedBaseY) then
									console.log("BaseY " .. Pos.BaseY)
								end]]--
							end
						else
							Pos.BaseX = SavedBaseX
							Pos.BaseY = SavedBaseY
						end
						SavedBaseX = Pos.BaseX
						SavedBaseY = Pos.BaseY

						gba_memory.GBASpritePosXWrite(SpriteA, Pos.BaseX + Pos.AButton_X)
						gba_memory.GBASpritePosYWrite(SpriteA, Pos.BaseY + Pos.AButton_Y)
						gba_memory.GBASpritePosXWrite(SpriteB, Pos.BaseX + Pos.BButton_X)
						gba_memory.GBASpritePosYWrite(SpriteB, Pos.BaseY + Pos.BButton_Y)

						--B Item
						gba_memory.GBASpritePosXWrite(LoopEnd+1, Pos.BaseX + Pos.BItem_X)
						gba_memory.GBASpritePosYWrite(LoopEnd+1, Pos.BaseY + Pos.BItem_Y)
					--	end
							
						if (SpriteActionText1 ~= nil) and (SpriteActionText2 ~= nil) then
							local SpriteActionText2_X = gba_memory.GBASpritePosXRead(SpriteActionText2) - gba_memory.GBASpritePosXRead(SpriteActionText1)
							
							gba_memory.GBASpritePosXWrite(SpriteActionText1, Pos.BaseX + Pos.AItem_X)
							gba_memory.GBASpritePosYWrite(SpriteActionText1, Pos.BaseY + Pos.AItem_Y)
							gba_memory.GBASpritePosXWrite(SpriteActionText2, Pos.BaseX + Pos.AItem_X + SpriteActionText2_X)
							gba_memory.GBASpritePosYWrite(SpriteActionText2, Pos.BaseY + Pos.AItem_Y)
						end
							
					--	if (SpriteB ~= nil) then
						for i=LoopStart,LoopEnd do 
							local spriteID = gba_memory.ReadGBASpriteID(i)
							if((spriteID ~= static.TILE_ID.R_TEXT_1) and (spriteID ~= static.TILE_ID.R_TEXT_2) and (spriteID ~= static.TILE_ID.R_BUTTON_1)) then
								gba_memory.HideSprite(i)
							end
						end

						--gui.drawImage(image_folder .. "buttons.png",	XOffset + 118, YOffset)
						gui.drawImage(image_folder .. "L.png",	Pos.BaseX + Pos.LButton_X, Pos.BaseY + Pos.LButton_Y)
						gui.drawImage(image_folder .. "R.png",	Pos.BaseX + Pos.RButton_X, Pos.BaseY + Pos.RButton_Y)
						gui.drawImage(image_folder .. "X.png",	Pos.BaseX + Pos.XButton_X, Pos.BaseY + Pos.XButton_Y)
						gui.drawImage(image_folder .. "Y.png",	Pos.BaseX + Pos.YButton_X, Pos.BaseY + Pos.YButton_Y)
						gui.drawImage(image_folder .. "zr.png",	Pos.BaseX + Pos.ZRButton_X, Pos.BaseY + Pos.ZRButton_Y)
						gui.drawImage(Images[inventory.CurrentItem.r],				Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y)
						gui.drawImage(Images[inventory.CurrentItem.l],				Pos.BaseX + Pos.LItem_X, Pos.BaseY + Pos.LItem_Y)
						gui.drawImage(Images[inventory.CurrentItem.zr],				Pos.BaseX + Pos.ZRItem_X, Pos.BaseY + Pos.ZRItem_Y)
						gui.drawImage(Images[inventory.CurrentItem.x],				Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y)
						gui.drawImage(Images[inventory.CurrentItem.y],				Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y)
							
						for Item=static.INVENTORY_ID.BOMB_1, static.INVENTORY_ID.BOMB_2 do 
							if(ItemActive(Item) == static.ACTIVE_ITEM_X) then
								draw.Digits(Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
							elseif(ItemActive(Item) == static.ACTIVE_ITEM_Y) then
								draw.Digits(Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
							elseif(ItemActive(Item) == static.ACTIVE_ITEM_R) then
								draw.Digits(Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
							end
						end
						for Item=static.INVENTORY_ID.BOW_1, static.INVENTORY_ID.BOW_2 do 
							if(ItemActive(Item) == static.ACTIVE_ITEM_X) then
								draw.Digits(Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
							elseif(ItemActive(Item) == static.ACTIVE_ITEM_Y) then
								draw.Digits(Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
							elseif(ItemActive(Item) == static.ACTIVE_ITEM_R) then
								draw.Digits(Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
							end
						end
					--end
					end
				end
end

function ItemActive(Item)
	if(inventory.CurrentItem.x == Item) then
		return static.ACTIVE_ITEM_X
	elseif(inventory.CurrentItem.y == Item) then
		return static.ACTIVE_ITEM_Y
	elseif(inventory.CurrentItem.r == Item) then
		return static.ACTIVE_ITEM_R
	else
		--DebugLog("ItemActive: Item not active #" .. Item)
		return static.ACTIVE_ITEM_NIL
	end
end

function draw.HideRealHudItems()
	local SpriteB = gba_memory.ReadSpriteByTile(static.TILE_ID.B_BUTTON)
	if (SpriteB == nil) then
		return
	end
	local menu_banner_y_position = memory.readbyte(addr.menu_banner_y_position)
	LoopStart = 4
	if (menu_banner_y_position == 16) then--if menu is hidden, sprites change
		LoopStart = 2
	end
	local LoopEnd = SpriteB
	
	for i = LoopStart, LoopEnd do 
		local spriteID = gba_memory.ReadGBASpriteID(i)
		if((spriteID ~= static.TILE_ID.R_TEXT_1) and (spriteID ~= static.TILE_ID.R_TEXT_2) and (spriteID ~= static.TILE_ID.R_BUTTON_1)) then
			gba_memory.HideSprite(i)
		end
	end
end

function draw.ItemsMenuHud()
	local Pos = {
		BaseX		= 0,	BaseY		= 0,
		XButton_X	= 180,	XButton_Y	= 13,
		YButton_X	= 156,	YButton_Y	= 13,
		RButton_X	= 204,	RButton_Y	= 15,
	}
	
	Pos.BItem_X = 61
	Pos.BItem_Y = 39
	
	Pos.XItem_X = Pos.XButton_X - 4
	Pos.XItem_Y = Pos.XButton_Y - 5 

	Pos.YItem_X = Pos.YButton_X - 4 
	Pos.YItem_Y = Pos.YButton_Y - 5 

	Pos.LItem_X = 61
	Pos.LItem_Y = 89

	Pos.RItem_X = Pos.RButton_X - 4
	Pos.RItem_Y = Pos.RButton_Y - 8
	
	Pos.ZRItem_X = 60
	Pos.ZRItem_Y = 63 

	draw.HideRealHudItems()
	
	local SpriteB = gba_memory.ReadSpriteByTile(static.TILE_ID.B_BUTTON)
	if (SpriteB == nil) then
		return
	end
	Pos.BaseX = gba_memory.GBASpritePosXRead(SpriteB) - 178
	Pos.BaseY = gba_memory.GBASpritePosYRead(SpriteB) - 11
	
	--draw buttons
	gui.drawImage(image_folder .. "R.png",	Pos.BaseX + Pos.RButton_X, Pos.BaseY + Pos.RButton_Y)
	gui.drawImage(image_folder .. "X.png",	Pos.BaseX + Pos.XButton_X, Pos.BaseY + Pos.XButton_Y)
	gui.drawImage(image_folder .. "Y.png",	Pos.BaseX + Pos.YButton_X, Pos.BaseY + Pos.YButton_Y)
	
	--draw items on buttons
	gui.drawImage(Images[inventory.CurrentItem.r],				Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y)
	gui.drawImage(Images[inventory.CurrentItem.x],				Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y)
	gui.drawImage(Images[inventory.CurrentItem.y],				Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y)
		
	--draw bomb and bow digits
	for Item=static.INVENTORY_ID.BOMB_1, static.INVENTORY_ID.BOMB_2 do 
		if(ItemActive(Item) == static.ACTIVE_ITEM_X) then
			draw.Digits(Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
		elseif(ItemActive(Item) == static.ACTIVE_ITEM_Y) then
			draw.Digits(Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
		elseif(ItemActive(Item) == static.ACTIVE_ITEM_R) then
			draw.Digits(Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y, inventory.GetBombCount(), inventory.GetMaxBombs())
		end
	end
	for Item = static.INVENTORY_ID.BOW_1, static.INVENTORY_ID.BOW_2 do 
		if(ItemActive(Item) == static.ACTIVE_ITEM_X) then
			draw.Digits(Pos.BaseX + Pos.XItem_X, Pos.BaseY + Pos.XItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
		elseif(ItemActive(Item) == static.ACTIVE_ITEM_Y) then
			draw.Digits(Pos.BaseX + Pos.YItem_X, Pos.BaseY + Pos.YItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
		elseif(ItemActive(Item) == static.ACTIVE_ITEM_R) then
			draw.Digits(Pos.BaseX + Pos.RItem_X, Pos.BaseY + Pos.RItem_Y, inventory.GetArrowCount(), inventory.GetMaxArrows())
		end
	end

	--draw set items cover
	gui.drawImage(image_folder .. "ItemCover.png",	36, 31)
	gui.drawImage(Images[inventory.CurrentItem.b],				Pos.BItem_X, Pos.BItem_Y)
	gui.drawImage(Images[inventory.CurrentItem.zr],				Pos.ZRItem_X, Pos.ZRItem_Y)
	gui.drawImage(Images[inventory.CurrentItem.l],				Pos.LItem_X, Pos.LItem_Y)

--end
end

-- Returning this module.
return draw
