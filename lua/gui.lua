
local gui_edit_robot = swr_require("dialogs/edit_robot")

local Edit_robot_dialog = {}
Edit_robot_dialog.new = function(sizeX, sizeY, imagelist, startimagekey, tooltiplist, last_row_width, down_labels)
	local self = {}
	sizeX = sizeX or 10 
	sizeY = sizeY or 10 
	tooltiplist = tooltiplist or {}
	imagelist = imagelist or {}
	startimagekey = startimagekey or 1
	local images = {}
	local is_dialog_showing = false
	local current_description_image = ""
	for  ix = 1, sizeX do
		images[ix] = {}
	end
	local down_strings= down_labels or {}
	local grid_top = gui_edit_robot.create_dialog_grid(sizeX, sizeY)
	local last_row_content = {}
	local last_grid_content = {}
	local menu_grid_content = {}
	local menu_row_content = {}

	-- creating the downer area  "toolbox"
	local toolbox_size_x = last_row_width
	local toolbox_size_y = math.ceil(#down_labels / last_row_width)
	local grid_bottom = gui_edit_robot.create_dialog_grid(toolbox_size_x, toolbox_size_y)
	local index_grid_bottom = 0
	
	for iY = 1, toolbox_size_y do
		for iX = 1, toolbox_size_x do
			if index_grid_bottom < #imagelist  then
				index_grid_bottom = index_grid_bottom + 1
				table.insert(grid_bottom.get_cell(iX, iY), gui_edit_robot.create_tooltip_field(tostring(index_grid_bottom), tooltiplist[index_grid_bottom]))
			else
				table.insert(grid_bottom.get_cell(iX, iY), gui_edit_robot.create_unused_tooltip_field(imagelist[startimagekey]))
			end
			grid_bottom.get_cell(iX, iY).vertical_grow = true
			grid_bottom.get_cell(iX, iY).horizontal_grow = true
		end
	end
	-- creating the upper area 'field'
	for iY = 1 , sizeY do
		for iX = 1 , sizeX do
			table.insert(grid_top.get_cell(iX,iY), gui_edit_robot.create_robot_field(tostring(iX) .. tostring(iY)))
		end
	end
	
	local dialog = gui_edit_robot.create(grid_top.get_grid(), grid_bottom.get_grid())
	
	self.show_dialog = function()
		local selected_index = startimagekey
		local function preshow()
			for k, v in pairs(imagelist) do 
				local f_sel = function()
					self.on_image_chosen(k)
					selected_index = k
					wesnoth.set_dialog_value(false, "down_panel" .. k)
				end
				wesnoth.set_dialog_value(v, "down_icon" .. tostring(k))
				wesnoth.set_dialog_callback(f_sel, "down_panel" .. tostring(k))
				if down_strings[k] == nil then
					wesnoth.set_dialog_value("0", "down_label" .. tostring(k))
				else
					wesnoth.set_dialog_value(down_strings[k], "down_label" .. tostring(k))
				end
			end
			for iY = 1 , sizeY do
				for iX = 1 , sizeX do
					local f_sel = function()
					wesnoth.set_dialog_value(false, "cell_panel" .. tostring(iX) .. tostring(iY))
						self.on_field_clicked({ x = iX, y = iY }, selected_index)
					end
					if images[iX][iY] == nil then
						wesnoth.set_dialog_value(imagelist[startimagekey], "cell_icon" .. tostring(iX) .. tostring(iY))
					else
						wesnoth.set_dialog_value(images[iX][iY], "cell_icon" .. tostring(iX) .. tostring(iY))
					end
					wesnoth.set_dialog_callback(f_sel, "cell_panel" .. tostring(iX) .. tostring(iY))
				end
			end
			wesnoth.set_dialog_value(current_description_image, "image_selected_item")
		end
		local function postshow()
		end
		is_dialog_showing = true
		local r = wesnoth.show_dialog(dialog, preshow, postshow)
		is_dialog_showing = false
	end
	self.set_image = function(x, y, image)
		--i want make set_image work before and afer show_dialog is called.
		images[x][y] = image
		if is_dialog_showing then
			wesnoth.set_dialog_value(image, "cell_icon" .. tostring(x) .. tostring(y))
		end
	end
	self.set_down_label = function(index, text)
		--i want make set_image work before and afer show_dialog is called.
		down_strings[index] = text
		if is_dialog_showing then
			wesnoth.set_dialog_value(text, "down_label"  .. tostring(index))
		end
	end
	self.set_selected_item_image = function(text)
		--i want make set_image work before and afer show_dialog is called.
		current_description_image = text
		if is_dialog_showing then
			wesnoth.set_dialog_value(current_description_image, "image_selected_item")
		end
	end
	return self
end

return Edit_robot_dialog