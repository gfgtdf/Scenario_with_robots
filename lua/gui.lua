
local gui_edit_robot = swr_require("dialogs/edit_robot")

EditRobotDialog = {}
EditRobotDialog.__index = EditRobotDialog
-- @a sizeX, sizeY the size of the robot field
-- @a tools the toolbox content: a array of table with the following keys; icon, label, tooltip
-- @a toolbox_width the numbner of colums of the toolbox.
function EditRobotDialog:create(size_x, size_y, tools, toolbox_width)
	local res = { }
	setmetatable(res, self)
	res.size_x = size_x or 10
	res.size_y = size_y or 10

	res.tools = tools or {}
	res.selected_index = 1
	res.empty_image = "c/empty.png"
	res.images = {}
	res.is_dialog_showing = false
	
	res.current_description_image = ""
	for  ix = 1, res.size_x do
		res.images[ix] = {}
	end
	
	local grid_top = gui_edit_robot.create_dialog_grid(size_x, size_y)

	-- creating the downer area  "toolbox"
	local toolbox_size_x = toolbox_width
	local toolbox_size_y = math.ceil(#tools / toolbox_width)
	local grid_bottom = gui_edit_robot.create_dialog_grid(toolbox_size_x, toolbox_size_y)
	local index_grid_bottom = 0
	
	for iY = 1, toolbox_size_y do
		for iX = 1, toolbox_size_x do
			if index_grid_bottom < #tools  then
				index_grid_bottom = index_grid_bottom + 1
				local tool = tools[index_grid_bottom]
				--wesnoth.set_dialog_tooltip does not exist yet
				table.insert(grid_bottom.get_cell(iX, iY), gui_edit_robot.create_tooltip_field(tostring(index_grid_bottom), tool.tooltip))
			else
				table.insert(grid_bottom.get_cell(iX, iY), gui_edit_robot.create_unused_tooltip_field())
			end
			grid_bottom.get_cell(iX, iY).vertical_grow = true
			grid_bottom.get_cell(iX, iY).horizontal_grow = true
		end
	end
	-- creating the upper area 'field'
	for iY = 1 , res.size_y do
		for iX = 1 , res.size_x do
			table.insert(grid_top.get_cell(iX,iY), gui_edit_robot.create_robot_field(tostring(iX) .. tostring(iY)))
		end
	end

	res.dialog = gui_edit_robot.create(grid_top.get_grid(), grid_bottom.get_grid())
	return res
end

function EditRobotDialog:show_dialog()
	local function preshow()
		for k, v in pairs(self.tools) do 
			local f_sel = function()
				self.on_tool_chosen(k)
				self.selected_index = k
				wesnoth.set_dialog_value(false, "down_panel" .. k)
			end
			wesnoth.set_dialog_value(v.icon, "down_icon" .. tostring(k))
			wesnoth.set_dialog_value(v.label, "down_label" .. tostring(k))
			wesnoth.set_dialog_callback(f_sel, "down_panel" .. tostring(k))
		end
		for iY = 1 , self.size_y do
			for iX = 1 , self.size_x do
				local f_sel = function()
					wesnoth.set_dialog_value(false, "cell_panel" .. tostring(iX) .. tostring(iY))
					self.on_field_clicked({ x = iX, y = iY }, self.selected_index)
				end
				if self.images[iX][iY] == nil then
					wesnoth.set_dialog_value(self.empty_image, "cell_icon" .. tostring(iX) .. tostring(iY))
				else
					wesnoth.set_dialog_value(self.images[iX][iY], "cell_icon" .. tostring(iX) .. tostring(iY))
				end
				wesnoth.set_dialog_callback(f_sel, "cell_panel" .. tostring(iX) .. tostring(iY))
			end
		end
		wesnoth.set_dialog_value(self.current_description_image, "image_selected_item")
	end
	self.is_dialog_showing = true
	local r = wesnoth.show_dialog(self.dialog, preshow)
	self.is_dialog_showing = false
end


--works before and during the dialog
function EditRobotDialog:set_image(x, y, image)
	self.images[x][y] = image
	if self.is_dialog_showing then
		wesnoth.set_dialog_value(image, "cell_icon" .. tostring(x) .. tostring(y))
	end
end

--works before and during the dialog
function EditRobotDialog:set_tool_label(index, text)
	self.tools[index].label = text
	if self.is_dialog_showing then
		wesnoth.set_dialog_value(text, "down_label"  .. tostring(index))
	end
end

--works before and during the dialog
function EditRobotDialog:set_selected_item_image(text)
	self.current_description_image = text
	if self.is_dialog_showing then
		wesnoth.set_dialog_value(self.current_description_image, "image_selected_item")
	end
end

return EditRobotDialog