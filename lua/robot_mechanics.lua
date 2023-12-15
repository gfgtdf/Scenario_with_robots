-- this file gives the "edit_robot_at_xy" function with allows to change a robot by a cutom dialog defined in gui.lua
-- and the "reapply_bonuses_at_xy" that should be called if the robots variable was changed without this dialog
local robot_mechanics = {}

local wml_codes = swr.require("wml_codes")

robot_mechanics.edit_robot_at_xy = function(x, y)
	local unit = wesnoth.units.get(x, y)
	robot_mechanics.edit_robot(unit)
end

robot_mechanics.edit_robot = function(unit)
	local robot = swr.RobotEditor:create_from_unit(unit)
	robot:update_size()
	--
	local is_local_choice = false
	local inv = swr.Inventory:get_open(wesnoth.current.side, "component_inventory")

	local edit_result = wesnoth.sync.evaluate_single(function ()
		robot:init_cells()
		local inv_delta = robot_mechanics.edit_robot_dialog(robot, inv)
		-- Optimisation: If we did this choice locally then we can use the 'robot' variable 
		-- (instead of using robotstring) which saves us one deserialize call.
		is_local_choice = true
		return { robotstring = robot:get_data_str(), T.inv_delta (inv_delta)}
	end,
	function()
		error("edit robot called by ai.")
	end)
	for k, v in pairs(edit_result[1][2]) do
		inv:add_amount(k, v)
	end
	inv:close()
	if not is_local_choice then
		robot:set_data_str(edit_result.robotstring)
		robot:init_cells()
	end
	robot:save_to_robot()
	robot_mechanics.apply_bonuses(unit, robot)
end

function robot_mechanics.create_tools_list(available_components)
	local tools = {}
	table.insert(tools, {
		icon = "c/empty.png",
		label = "del",
		tooltip = "removes a component",
		preview = "misc/tpixel.png~SCALE(120,120)"
	})
	for k,v in pairs(available_components) do
		table.insert(tools, {
			icon = v.component.image,
			label = tostring(v.number),
			tooltip = v.component.tooltip,
			preview = v.component:get_full_image()
		})
	end
	return tools
end

-- shows the robot edit dialog and writes the changes into the robot variable
-- this function changes the robot variable, and returns which items are taken from the inventory (can contain negative numbers, if components were removed from the robot.)
-- this function assumes that the inventory is open but doesn't change it(because this is called in a sync_context).
function robot_mechanics.edit_robot_dialog(robot2, inv)
	local invenory_delta = {}
	local sizeX = robot2:size().x
	local sizeY = robot2:size().y
	local tools = {}
	-- later the won't be all components accessible.
	-- saving the max number of alowed comonents of 1 type in this list seems also useful to me.
	local accessible_components = robot2:available_components(inv)
	local tools = robot_mechanics.create_tools_list(accessible_components)
	local dialog = swr.EditRobotDialog:create(sizeX, sizeY, tools, 6)

	local function draw_component(item, pos, remove)
		print("draw_component item", item)
		robot2:cells_foreach_impl(pos, item, function(item, p_cell, pos_target)
			local image = "c/empty.png"
			if not remove then
				image = item.component:get_image(p_cell)
			end
			dialog:set_image(pos_target.x, pos_target.y, image)
		end)
	end

	local function comp_tool_number(comp_name)
		for k, v in ipairs(accessible_components) do
			if comp_name == v.component.name then
				return k
			end
		end
	end

	local function add_to_inv(comp_num, amount)
		local ac = accessible_components[comp_num]
		local comp_name =  ac.component.name

		ac.number = ac.number + amount
		invenory_delta[comp_name] = (invenory_delta[comp_name] or 0) + amount
		dialog:set_tool_label(comp_num + 1, tostring(ac.number))
	end


	for k,v in pairs(robot2.robot.components) do
		draw_component(v, v.pos, false)
	end

	function dialog.on_field_clicked(pos, imageid)
		local comp_info = accessible_components[imageid - 1] or {}
		local remove = imageid == 1
		if remove then
			local item, pos2 = robot2:remove_item(pos)
			if item then
				draw_component(item, pos2, true)
				local comp_num = comp_tool_number(item.component.name)
				add_to_inv(comp_num, 1)
			end
		else
			local item = { component = comp_info.component }
			if robot2:can_place_item(pos, item) then
				robot2:place_item(pos, item)
				draw_component(item, pos, false)
				add_to_inv(imageid - 1, -1)
			end
		end
	end

	dialog:show_dialog()
	--it's still not over
	local pos_of_core = nil
	for k,v in pairs(robot2.robot.components) do
		if v.component.name == "core" then
			pos_of_core = v.pos
		end
	end
	print("pos_of_core", pos_of_core.x, pos_of_core.y)
	--does this work when no core is found? (pos_of_core = nil).
	local removed_comonents = robot_mechanics.find_connected_items(robot2, pos_of_core)
	print("items not eonnected:", #removed_comonents)
	for i,v in ipairs(removed_comonents) do
		invenory_delta[v.component.name] = (invenory_delta[v.component.name] or 0) + 1
	end
	invenory_delta["core"] = nil
	--TODO:  change stats acording to the robot structure, i thought about
	--       adding an "object" or "advance" to the robot that contains all
	--       the efects and might be quite long.
	--       (is there a major diefference between "object" and "advance"?)
	--EDIT:  if i use stats.lua there IS one because some effect tags are only acceptd form 
	--       "advance" others only from "object", i could fix that but i don't have the time do to.
	--EDIT2: im changing stats.lua to make that difference disappear
	--       maybe i'll use stats.lua to ensure everythings alright.
	--EDIT3: ocf stats.lua is called (was it really me writing the comment before?), but by te caller of this method here
	--EDIT4: it is possible to have a general 'robot' effect that basicially does the calculations below,
	--       but i think that'd be rather slow since its recalculate all this stuff, but a midddle-way
	--       might be agood idea, that is have a gneral 'robot' effect that uses precalulatedinfromation
	--       from unit variales.
	return invenory_delta
end

function robot_mechanics.find_connected_items(robot, startpos)
	local removed_objects = {}
	local pos_todo = {}
	local pos_done = {}
	local sizeY = robot:size().y
	local sizeX = robot:size().x
	local distance = 0
	local open_ends_count = 0
	local rings_count = 0

	local function set_done(pos, val)
		pos_done[pos.x * sizeY + pos.y] = val
	end

	local function get_done(pos)
		return pos_done[pos.x * sizeY + pos.y]
	end

	local opp = {
		n = "s",
		s = "n",
		e = "w",
		w = "e",
	}
	local offset = {
		n = { x =  0, y = -1 },
		s = { x =  0, y =  1 },
		e = { x =  1, y =  0 },
		w = { x = -1, y =  0 },
	}

	for x = 1, robot:size().x do
		for y = 1, robot:size().y do
			robot:get_cell(x, y).distance = nil
		end
	end

	if startpos ~= nil then
		pos_todo[1] = { x = startpos.x, y = startpos.y, distance = 0 }
		set_done(startpos, "sighted")
	end

	while #pos_todo > 0 do
		local pos_now = table.remove(pos_todo, 1)
		local cell_now = robot:get_component_cell(pos_now)
		for i, dir in ipairs({"n", "e", "s", "w"}) do
			if cell_now[dir] == true then
				local off = offset[dir]
				local pos_adj = { x = pos_now.x + off.x, y = pos_now.y + off.y , distance = pos_now.distance + 1 }
				local cell_adj = robot:get_component_cell(pos_adj) or {}
				if cell_adj[opp[dir]] ~= true then
					open_ends_count = open_ends_count + 1
				elseif get_done(pos_adj) == nil then
					set_done(pos_adj, "sighted")
					table.insert(pos_todo, pos_adj)
				elseif get_done(pos_adj) == "sighted" then
					rings_count = rings_count + 1
				end
			end
		end
		robot:get_cell(pos_now).distance = pos_now.distance
		set_done(pos_now, "done")
	end
	robot.robot.open_ends_count = open_ends_count
	robot.robot.rings_count = rings_count


	for i = #robot.robot.components, 1, -1 do
		local item = robot.robot.components[i]
		item.distance = robot:get_cell(item.pos).distance
		if item.distance == nil then
			robot:remove_item(item.pos)
			table.insert(removed_objects, item)
		end
	end

	return removed_objects
end

-- this function applys the bonusses
-- returns: 
--   effects: the effects that shoudl be applied
--   advances: advances that should be applied this is to make the components requirements for advances.
function robot_mechanics.calcualte_bonuses(robot2)
	local rings_count = robot2.robot.rings_count
	local open_ends_count = math.max (1, robot2.robot.open_ends_count ) - 1
	local aggregator = {}
	local used_component_types = {}
	local used_component_types_set = {}
	local apply_functions = {}
	local apply_functions_set = {}
	aggregator.component_images = {}
	aggregator.movement = 0
	aggregator.movement_costs = {}
	-- TODO: implement resistances
	aggregator.terrain_defenses_delta = {}
	aggregator.resitances_delta = {}
	aggregator.resitances_delta.arcane = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.cold = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.fire = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.blade = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.pierce = (open_ends_count - rings_count) * 4
	aggregator.resitances_delta.impact = (open_ends_count - rings_count) * 4
	for k, v in pairs(robot2.robot.components) do
		local check = v.component.check_function
		if check == nil or check(robot2, v.pos) then
			if v.component.aggregate_function ~= nil then
				v.component.aggregate_function(robot2, v, aggregator)
			end
			if not apply_functions_set[v.component] then
				table.insert(used_component_types, v.component)
			end
			apply_functions_set[v.component] = true
		end
	end
	local all_effects = {}
	local all_advances = {}
	--todo check whether this sorts in the correct direction
	swr_h.stable_sort(used_component_types, function(c1, c2) return (c1.order_apply or 0) < (c2.order_apply or 0) end)
	for k, v in pairs(used_component_types) do
		if v.apply_function then
			local new_effects, new_advances = v.apply_function(robot2, aggregator)
			for k2, v2 in pairs(new_effects or {}) do
				table.insert(all_effects, v2)
			end
			for k2, v2 in pairs(new_advances or {}) do
				table.insert(all_advances, v2)
			end
		end
	end
	table.insert(all_effects, wml_codes.get_ad_movement_code(aggregator.movement)[1])
	table.insert(all_effects, wml_codes.get_ad_movement_costs_code(aggregator.movement_costs)[1])
	table.insert(all_effects, wml_codes.get_ad_resistances_code(aggregator.resitances_delta.arcane, aggregator.resitances_delta.cold, aggregator.resitances_delta.fire, aggregator.resitances_delta.blade, aggregator.resitances_delta.pierce, aggregator.resitances_delta.impact)[1])
	table.insert(all_effects, wml_codes.get_overlay_effect(aggregator.component_images)[1])
	return all_effects, all_advances
end

function wesnoth.wml_actions.swr_update_unit(cfg)
	local need_update = wesnoth.units.find_on_map(cfg)
	for i,unit in ipairs(need_update) do
		robot_mechanics.apply_bonuses(unit)
	end
end

function robot_mechanics.apply_bonuses(robot)
	if type(robot) == 'userdata' and getmetatable(robot) == 'unit' then
		if not robot.variables.robot then
			return
		end
		robot = swr.RobotEditor:create_from_unit(robot)
	end
	robot:init_cells()

	local pos_of_core = nil
	for k,v in pairs(robot.robot.components) do
		if v.component.name == "core" then
			pos_of_core = v.pos
		end
	end

	local removed_objects = robot_mechanics.find_connected_items(robot, pos_of_core)
	if #removed_objects ~= 0 then
		error("removed an item during robot_mechanics.apply_bonuses")
	end

	local effects, new_advancements = robot_mechanics.calcualte_bonuses(robot)
	robot_mechanics.replace_robot_advancements(robot.unit, effects, new_advancements)
end

function robot_mechanics.replace_robot_advancements(unit, effects, new_advancements)
	local modifications_cfg = wml.get_child(unit.__cfg, "modifications")
	-- NOTE: in 1.16 this only works with [advancement]
	swr_h.remove_from_array(modifications_cfg, function(a) 
		return a[2].swr_robot_mod == true
	end)
	local obj_cfg = wml_codes.get_robot_object(effects)
	table.insert(modifications_cfg, 1, obj_cfg)
	for k,v in pairs(new_advancements) do
		table.insert(modifications_cfg, 2, v)
	end
	unit:swr_replace_modifications(modifications_cfg)
end

return robot_mechanics
