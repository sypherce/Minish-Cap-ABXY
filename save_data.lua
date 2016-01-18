local inventory = require(base_folder .. "inventory")
--button save data

function read_button(file)
	local button = file:read()
	button = tonumber(button)--make sure we're getting a number
	--button = inventory.HasItem(button)--check that we have this item, if not returns ITEM_NONE
	return button
end

function write_button(file, button)
	button = tonumber(button)--make sure we're getting a number
	file:write(button, "\n")
end

local save_data = {

}

--find and return the save filename
function save_data.find_save_file()
	local file = io.open(base_folder .. "buttons.sav", "r")
	if (file) then
		return base_folder .. "buttons.sav"
	else
		return "buttons.sav"
	end
end

function save_data.load_buttons()
	DebugLog("save_data.load_buttons()")

	--try to open buttons save file
	local file = io.open(save_data.find_save_file(), "r")
		--if the file is not open, abort the function
		if (file == nil) then
			do return end
		end

		inventory.CurrentItem.x = read_button(file)
		inventory.CurrentItem.y = read_button(file)
		inventory.CurrentItem.r = read_button(file)
	-- close the open file
	file:close()
end

function save_data.save_buttons()
	DebugLog("save_data.save_buttons()")

	--try to open buttons save file
	local file = io.open(save_data.find_save_file(), "w+")
		--if the file is not open, abort the function
		if (file == nil) then
			do return end
		end

		write_button(file, inventory.CurrentItem.x)
		write_button(file, inventory.CurrentItem.y)
		write_button(file, inventory.CurrentItem.r)
	-- close the open file
	file:close()
end

event.onloadstate(save_data.load_buttons)
event.onsavestate(save_data.save_buttons)

-- Returning this module.
return save_data
