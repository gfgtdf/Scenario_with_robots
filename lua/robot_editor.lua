local RobotEditor = {}
RobotEditor.__index = RobotEditor

RobotEditor.default_string = " { components =  {} , size = { x = 0, y = 0}} "


function RobotEditor:create_from_unit(unit)
	local o = {}
	setmetatable(o, self)

	o.unit = unit
	o.robot = self:deserialize(unit.variables.robot or self.default_string)
	o.cells = nil
	return o
end

function RobotEditor:size()
	return self.robot.size
end

function RobotEditor:init_cells_empty()
	local size = self.robot.size
	self.cells = {}
	for i = 1, size.x * size.y do
		self.cells[i] = {}
	end
end

function RobotEditor:init_cells()
	self:init_cells_empty()
	for i, item in ipairs(self.robot.components) do
		self:cells_place_item(item.pos, item)
	end
end

function RobotEditor:get_cell(x, y)
	if y == nil then
		y = x.y
		x = x.x
	end
	if x < 1 or y < 1 or x > self:size().x or y > self:size().y then
		return
	end
	local i = x + (y - 1) * self:size().x
	return self.cells[i]
end

function RobotEditor:is_empty(x, y)
	return self:get_cell(x, y).item ~= nil
end
function RobotEditor:component_name_at(x, y)
	local item = (self:get_cell(x, y) or {}).item
	if item then
		return item.component.name
	end
end

function RobotEditor:get_component_cell(pos)
	local res =  self:get_cell(pos)
	if not res or not res.item then
		return
	end
	return res.item.component:get_cell(res.item_pos)
end

function RobotEditor:cells_foreach_impl(pos, item, hanlder)
	for p_cell in item.component:cells() do
		local pos_target = {
			x = pos.x + p_cell.x,
			y = pos.y + p_cell.y,
		}
		hanlder(item, p_cell, pos_target)
	end
end

function RobotEditor:cells_place_item(pos, item)
	self:cells_foreach_impl(pos, item, function(item, p_cell, pos_target)
		local cell_t = self:get_cell(pos_target)
		cell_t.item = item
		cell_t.item_pos = p_cell
	end)
end

function RobotEditor:place_item(pos, item)
	self:cells_place_item(pos, item)
	-- pos is actually stores in the item
	item.pos = { x = pos.x, y = pos.y}
	table.insert(self.robot.components, item)
end

function RobotEditor:get_center_pos(pos)
	local cell_pos = self:get_cell(pos)
	if cell_pos.item == nil then
		return
	end
	return { x = pos.x - cell_pos.item_pos.x , y = pos.y - cell_pos.item_pos.y }
end

function RobotEditor:cells_remove_item(pos)
	local cell_pos = self:get_cell(pos)
	local item = cell_pos.item
	if item == nil then
		return
	end
	local pos_center = { x = pos.x - cell_pos.item_pos.x , y = pos.y - cell_pos.item_pos.y }
	self:cells_foreach_impl(pos_center, cell_pos.item, function(item, p_cell, pos_target)
		local cell_t = self:get_cell(pos_target)
		cell_t.item = nil
		cell_t.item_pos = nil
	end)
	return item, pos_center
end

function RobotEditor:remove_item(pos)
	local item, pos_item = self:cells_remove_item(pos)
	swr_h.remove_from_array(self.robot.components, function(rcomp) return rcomp.pos.x == pos.x and rcomp.pos.y == pos.y end)
	return item, pos_item
end

function RobotEditor:can_place_item(pos, item)
	local ret = true
	self:cells_foreach_impl(pos, item, function(item, p_cell, pos_target)
		local cell_t = self:get_cell(pos_target)
		if (not cell_t) or cell_t.item then
			ret = false
		end
	end)
	return ret
end

function RobotEditor:save_to_robot()
	self.unit.variables.robot = self:get_data_str()
end

function RobotEditor:get_data_str()
	return self:serialize(self.robot)
end

function RobotEditor:set_data_str(str)
	self.unit.variables.robot = str
	self.robot = self:deserialize(unit.variables.robot)
	self.cells = nil
end

function RobotEditor:serialize(robot_data)
	local robot_to_seralize = {}
	-- copy only on first level attributes
	for k,v in pairs(robot_data) do
		robot_to_seralize[k] = v
	end
	robot_to_seralize.components = {}
	for i, comp in ipairs(robot_data.components) do
		local new_comp = {}
		robot_to_seralize.components[i] = new_comp
		for k,v in pairs(comp) do
			new_comp[k] = v
		end
		new_comp.component = comp.component.name
	end
	return swr_h.serialize_oneline(robot_to_seralize)
end

function RobotEditor:deserialize(robot_str)
	local res = swr_h.deserialize(robot_str)
	for i =1, #(res.components or {}) do
		res.components[i].component = swr.component_list.list_by_name[res.components[i].component]
	end
	return res
end

function RobotEditor:update_size()
	local unit_cfg = self.unit.__cfg
	local size = {}
	-- we check if the robot has gottten bigger for example by levelup.
	for dummy in wml.child_range(wml.get_child(unit_cfg, "abilities"), "dummy") do
		if(dummy.id == "robot_ability") then
			size.x = dummy.sizex
			size.y = dummy.sizey
		end
	end
	self:update_size_to(size.x, size.y)
end

function RobotEditor:update_size_to(x_new, y_new)
	local robot = self.robot
	robot.size = robot.size or { x= 2, y = 2}
	x_new = x_new or robot.size.x
	robot.size.x = math.max(x_new , robot.size.x)
	y_new = y_new or robot.size.y
	robot.size.y = math.max(y_new , robot.size.y)
	local size_x_delta = math.max(x_new - robot.size.x, 0)
	local size_y_delta = math.max(y_new - robot.size.y, 0)
	for i, comp in ipairs(robot.components) do
		-- in case the field grows i want to grow it to above not at down
		comp.pos.y = comp.pos.y + size_y_delta
	end
end

function RobotEditor:available_components(inv)
	local ac = {}
	local res = {}

	ac["core"] = 1
	for k,v in pairs(self.robot.components) do
		ac[v.component.name] = 0
	end
	for k,v in pairs(inv.inv_set) do
		-- note that items that were in the inventory once still have an entry there even if their number is 0
		if v ~= 0 then
			ac[k] = v
		end
	end
	for k,v in pairs(ac) do
		res[#res + 1] = {
			component = swr.component_list.list_by_name[k],
			number = v,
		}
	end

	local sorter = function(comp1, comp2)
		comp1 = comp1.component
		comp2 = comp2.component
		local order_1 = comp1.toolbox_order or 0
		local order_2 = comp2.toolbox_order or 0
		if order_1 == order_2 then
			return comp1.name < comp2.name
		else
			return order_1 < order_2
		end
	end
	table.sort(res, sorter)
	return res
end

return RobotEditor
