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

function save_data.load_buttons()
	console.log("save_data.load_buttons()")

	local file = io.open(base_folder .. "buttons.sav", "r")
		CurrentItem.x = read_button(file)
		CurrentItem.y = read_button(file)
		CurrentItem.r = read_button(file)
		-- close the open file
	file:close()
end

function save_data.save_buttons()
	console.log("save_data.save_buttons()")

	--open buttons save file
	local file = io.open(base_folder .. "buttons.sav", "w+")
		write_button(file, CurrentItem.x)
		
		write_button(file, CurrentItem.y)
		write_button(file, CurrentItem.r)
	-- close the open file
	file:close()
end

event.onloadstate(save_data.load_buttons)
event.onsavestate(save_data.save_buttons)

-- Returning this module.
return save_data
