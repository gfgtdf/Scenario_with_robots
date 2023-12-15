
local gui_edit_robot = wesnoth.require("./wml/edit_robot.lua")

local EditRobotDialog = {}
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
	res.dialog = nil
	
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
				table.insert(grid_bottom.get_cell(iX, iY), gui_edit_robot.create_tooltip_field(tostring(index_grid_bottom)))
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

	res.dialog_wml = gui_edit_robot.create(grid_top.get_grid(), grid_bottom.get_grid())
	return res
end

function EditRobotDialog:find(name, i1, i2)
	if i1 then
		name = name .. tostring(i1)
	end
	if i2 then
		name = name  .. tostring(i2)
	end
	return self.dialog:find(name)
end

function EditRobotDialog:show_dialog()
	local function preshow(dialog)
		self.dialog = dialog
		for k, v in pairs(self.tools) do 

			local function f_sel()
				--self.on_tool_chosen(k)
				self.selected_index = k
				self:set_selected_item_image(v.preview)
				self:find("down_panel", k).selected = false
			end
			
			self:find("down_icon", k).label = v.icon
			self:find("down_icon", k).tooltip = v.tooltip or ""
			self:find("down_label", k).label = v.label
			self:find("down_panel", k).callback = f_sel

		end
		self:set_selected_item_image(self.tools[1].preview)
		for iY = 1 , self.size_y do
			for iX = 1 , self.size_x do
				local function f_sel()

					dialog:find("cell_panel" .. tostring(iX) .. tostring(iY)).selected = false
					self.on_field_clicked({ x = iX, y = iY }, self.selected_index)
				end
				if self.images[iX][iY] == nil then
					dialog:find("cell_icon" .. tostring(iX) .. tostring(iY)).label = self.empty_image
				else
					dialog:find("cell_icon" .. tostring(iX) .. tostring(iY)).label = self.images[iX][iY]
				end
				dialog:find("cell_panel" .. tostring(iX) .. tostring(iY)).callback = f_sel
			end
		end
		dialog:find("image_selected_item").label = self.current_description_image
	end
	local r = gui.show_dialog(self.dialog_wml, preshow)
	self.dialog = nil
end


--works before and during the dialog
function EditRobotDialog:set_image(x, y, image)
	self.images[x][y] = image
	if self.dialog then
		self.dialog:find("cell_icon" .. tostring(x) .. tostring(y)).label = image
	end
end

--works before and during the dialog
function EditRobotDialog:set_tool_label(index, text)
	self.tools[index].label = text
	if self.dialog then
		self:find("down_label", index).label = text
	end
end

--works before and during the dialog
function EditRobotDialog:set_selected_item_image(text)
	self.current_description_image = text
	if self.dialog then
		self:find("image_selected_item").label = self.current_description_image
	end
end

return EditRobotDialog